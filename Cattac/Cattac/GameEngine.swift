import Foundation

protocol GameStateListener {
    func onStateUpdate(state: GameState)
}

protocol EventListener {
    func onActionUpdate(action: Action?)
    func onItemSpawned(node: TileNode)
    func onItemObtained(item: Item, _ isCurrentPlayer: Bool)
    func onPlayerDied(players: [Cat])
    func addPendingPoopAnimation(poop: Poop, target: TileNode)
}

/// Game engine that does all the logic computation for the game.
class GameEngine {
    private let catFactory = CatFactory.sharedInstance
    private let itemFactory = ItemFactory.sharedInstance
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
    // The game grid
    private var grid: Grid!

    // The AI engine that is used when multiplayer mode is not active
    private var gameAI: GameAI!
    
    /// States to advance, initialized at 1 to rollover PostExecution state.
    private var statesToAdvance: Int = 1

    /// Game Manager to help manage player movement and actions
    var gameManager: GameManager = GameManager()
    
    /// Player index (TODO: we should change to player-id instead).
    var playerNumber = 1
    
    // The initial game state is to be set at PostExecution
    var state: GameState = .PostExecution
    
    /// GameState listener, listens for update on state change.
    var gameStateListener: GameStateListener?
    
    /// Action listener, listens for action change on currentPlayer.
    var eventListener: EventListener?
    
    /// The local player
    var currentPlayer: Cat!
    
    /// currentPlayer's movement index, for backend use.
    var currentPlayerMoveNumber: Int = 1
    
    /// item spawn index, for backend use.
    var itemSpawned: Int = 0
    
    /// item spawned, pending addition to game in PostExecute
    var pendingItemSpawned: [TileNode: String] = [:]
    
    /// Calculated reachable nodes for currentPlayer.
    var reachableNodes: [Int:TileNode] = [:]
    
    /// Whether the game is currently in multiplayer mode
    var multiplayer: Bool
    
    /// Whether the game is currently the host
    var host: Bool
    
    /// For wait countdown to drop player
    var countDownTimer: NSTimer?
    
    /// The number of players that moved that the local player is listening to
    var otherPlayersMoved = 0

    /// The node positions mapped to the player on that node.
    var playerMoveToNodes = [GridIndex:Cat]()
    
    init(grid: Grid, playerNumber: Int, multiplayer: Bool) {
        println("init GameEngine as playerNumber \(playerNumber)")
        
        self.playerNumber = playerNumber
        self.grid = grid
        self.host = playerNumber == 4
        self.multiplayer = multiplayer
        
        createPlayers(playerNumber)
        
        if multiplayer {
            registerMovementWatcherExcept(playerNumber)
            registerSpawnedItemWatcher()
        }
        
        self.gameAI = GameAI(grid: grid, gameEngine: self,
            currentPlayer: currentPlayer)
    }
    
    /// Set this game as host game. Host will be incharge of dealing with player
    /// drops.
    func setHost() {
        host = true
    }
    
    /// Called every update by gameScene (1 time per frame)
    func gameLoop() {
        if statesToAdvance > 0 {
            advanceState()
        } else {
            // No need to execute state methods if state unchanged
            return
        }
        
        switch state {
        case .Precalculation:
            precalculate()
            triggerStateAdvance()
        case .PlayerAction:
            break
        case .ServerUpdate:
            updateServer(playerNumber)
            triggerStateAdvance()
        case .WaitForAll:
            countDownForDrop()
            gameAI.calculateTurn()
            spawnItem()
        case .StartMovesExecution:
            calculateMovementPaths()
            generatePlayerMoveToNodes()
            triggerStateAdvance()
        case .MovesExecution:
            // This state waits for the movement ended event that is triggered
            // from the scene.
            break
        case .DeconflictExecution:
            deconflictUpdate()
            // This state waits for the deconflict that is triggered
            // from the scene.
            break
        case .StartActionsExecution:
            calculationActions()
            triggerStateAdvance()
        case .ActionsExecution:
            // This state waits for the action ended event that is triggered
            // from the scene.
            break
        case .PostExecution:
            checkItemSpawned()
            postExecute()
            triggerStateAdvance()
        case .GameEnded:
            println(gameManager.playerRanks)
        }
    }
    
    /// Trigger state advancement in game engine.
    private func triggerStateAdvance() {
        statesToAdvance++
    }
    
    /// Effectively advances the state, GameState should not be
    /// altered outside of this method.
    private func advanceState() {
        switch state {
        case .Precalculation:
            state = .PlayerAction
        case .PlayerAction:
            if multiplayer {
                state = .ServerUpdate
            } else {
                state = .WaitForAll
            }
        case .ServerUpdate:
            state = .WaitForAll
        case .WaitForAll:
            state = .StartMovesExecution
        case .StartMovesExecution:
            state = .MovesExecution
        case .MovesExecution:
            state = .DeconflictExecution
        case .DeconflictExecution:
            state = .StartActionsExecution
        case .StartActionsExecution:
            state = .ActionsExecution
        case .ActionsExecution:
            state = .PostExecution
        case .PostExecution:
            if gameManager.gameEnded {
                state = .GameEnded
            } else {
                state = .Precalculation
            }
        case .GameEnded:
            break
        }
        
        println(state.description)
        gameStateListener?.onStateUpdate(state)
        statesToAdvance--
    }
    
    private func precalculate() {
        gameManager.precalculate()
        
        reachableNodes = grid.getNodesInRange(
            gameManager[positionOf: currentPlayer]!,
            range: currentPlayer.moveRange
        )
    }
    
    private func countDownForDrop() {
        if !host || gameManager.allTurnsCompleted
            || gameManager.aiPlayers.count == 3 {
            return
        }
        
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(
            Constants.Firebase.maxDelayBeforeDrop,
            target: self, selector: Selector("onCountDownForDrop"),
            userInfo: nil, repeats: false)
        
    }
    
    @objc func onCountDownForDrop() {
        println("Initiate drop inactive players")
        if !gameManager.allTurnsCompleted {
            var playersToDrop: [Cat] = []
            for (name, player) in gameManager.players {
                if gameManager.samePlayer(player, currentPlayer) {
                    continue
                }
                if gameManager.playersTurnCompleted[name] == nil {
                    let playerNum = gameManager[playerNumFor: player]!
                    gameConnectionManager.dropPlayer(playerNum)
                    gameManager[aiFor: player] = true
                }
            }
            gameAI.calculateTurn()
        }
    }

    func setCurrentPlayerMoveToPosition(node: TileNode) {
        if node != gameManager[moveToPositionOf: currentPlayer] {
            gameManager[moveToPositionOf: currentPlayer] = node
        }
    }
    
    /// Precalculate movement paths, not effected until executePlayerMove
    /// is called.
    private func calculateMovementPaths() {
        for player in gameManager.players.values {
            var shouldContinue = false
            var playerAtNode = gameManager[positionOf: player]!
            var playerMoveToNode = gameManager[moveToPositionOf: player]!
            var path = grid.shortestPathFromNode(playerAtNode,
                toNode: playerMoveToNode)
            
            for otherPlayer in gameManager.players.values {
                if player.name == otherPlayer.name {
                    continue
                } else {
                    var otherPlayerNode = gameManager[positionOf: otherPlayer]!
                    var otherPlayerMoveToNode = gameManager[moveToPositionOf: otherPlayer]!
                    
                    if playerMoveToNode == otherPlayerMoveToNode {
                        if path.count == 0 {
                            println("a cat moving onto another cat, no backward movement")
                        } else {
                            var reversedPath = reverse(path)
                            reversedPath.removeAtIndex(0)
                            reversedPath.append(playerAtNode)
                            
                            gameManager[deconflictPathOf: player] = reversedPath
                            gameManager[movementPathOf: player] = path
                            
                            shouldContinue = true
                        }
                    }
                }
            }
            
            if shouldContinue {
                continue
            }
            
            if let doodad = playerMoveToNode.doodad {
                // effect non-move modifications
                doodad.postmoveEffect(player)
                if doodad is LandMineDoodad {
                    let poop = Poop(nil, Constants.Doodad.landMineDamage)
                    poop.victim = player
                    eventListener?.addPendingPoopAnimation(poop,
                        target: playerMoveToNode)
                } else if doodad is WormholeDoodad {
                    let destNode = (doodad as WormholeDoodad).getDestinationNode()
                    gameManager[moveToPositionOf: player]! = destNode
                    playerMoveToNode = destNode
                    path += [destNode]
                } else if doodad.isRemoved() {
                    playerMoveToNode.doodad = nil
                    gameManager.doodadsToRemove[doodad.getSprite().hashValue] = doodad
                }
            }
            
            if let poop = playerMoveToNode.poop {
                playerMoveToNode.poop = nil
                
                poop.victim = player
                eventListener?.addPendingPoopAnimation(poop,
                    target: playerMoveToNode)
            }
            
            gameManager[movementPathOf: player] = path
        }
    }
    
    private func calculationActions() {
        for player in gameManager.players.values {
            if let action = gameManager[actionOf: player] {
                switch action.actionType {
                case .Pui:
                    break
                case .Fart:
                    (action as FartAction).resetRange(player.fartRange)
                case .Poop:
                    break
                case .Item:
                    break
                }
            }
            println("\(player.name) \(gameManager[actionOf: player])")
        }
    }
    
    private func postExecute() {
        gameManager.advanceTurn()

        if !gameManager.dyingPlayers.isEmpty {
            eventListener?.onPlayerDied(gameManager.dyingPlayers)
        }
        
        for player in gameManager.players.values {
            player.postExecute()
            let tileNode = gameManager[positionOf: player]!
            
            if let item = tileNode.item {
                gameManager[inventoryOf: player]!.addItem(item)
                tileNode.item = nil
                
                let isCurrentPlayer = currentPlayer.name == player.name
                eventListener?.onItemObtained(item, isCurrentPlayer)
            }
        }
    }
    
    private func spawnItem() {
        if multiplayer && !host {
            return
        }
        
        let randValue = Int(arc4random_uniform(UInt32(10))) + 1
        if randValue >= Constants.Level.itemSpawnProbability {
            return
        }
        
        let item = itemFactory.randomItem()
        let row = Int(arc4random_uniform(UInt32(grid.rows)))
        let col = Int(arc4random_uniform(UInt32(grid.columns)))
        let tileNode = grid[row, col]!
        
        if tileNode.item == nil && tileNode.doodad == nil {
            tileNode.item = item
            if multiplayer {
                gameConnectionManager.sendSpawnedItem(itemSpawned++,
                    item: item, node: tileNode)
            } else {
                pendingItemSpawned[tileNode] = item.name
            }
        }
    }
    
    private func checkItemSpawned() {
        if let node = pendingItemSpawned.keys.first {
            node.item = itemFactory.createItem(pendingItemSpawned[node]!)
            eventListener?.onItemSpawned(node)
            pendingItemSpawned.removeAll(keepCapacity: false)
        }
    }

    private func generatePlayerMoveToNodes() {
        playerMoveToNodes.removeAll(keepCapacity: true)

        for player in gameManager.players.values {
            let node = gameManager[moveToPositionOf: player]!
            playerMoveToNodes[node.position] = player
        }
    }
    
    /// Called by UI to notify game engine that movement is executed on UI
    /// and player position can be updated
    ///
    /// :param: cat The player's move to execute
    func executePlayerMove(player: Cat) -> [TileNode] {
        let path = gameManager[movementPathOf: player]
        if path != nil {
            return path!
        } else {
            return []
        }
    }
    
    func executePlayerDeconflict(player: Cat) -> [TileNode] {
        let path = gameManager[deconflictPathOf: player]
        if path != nil {
            return path!
        } else {
            return []
        }
    }
    
    func deconflictUpdate() {
        for player in gameManager.players.values {
            let path = gameManager[deconflictPathOf: player]
            
            if path != nil {
                if path!.count != 0 {
                    gameManager[moveToPositionOf: player] = path!.last
                }
            }
        }
    }
    
    /// Called by UI to notify game engine that action is executed on UI
    /// and action effects can be effected (note that some effects does 
    /// not occur directly in this method, but during a callback from UI
    /// e.g. when collision detection is required to determine effects, 
    /// or when pre-calculation of effects is not possible
    ///
    /// :param: cat The player's action to execute
    func executePlayerAction(player: Cat) -> Action? {
        let action = gameManager[actionOf: player]
        if action is PoopAction {
            let node = action!.targetNode!
            let poop = Poop(player, player.poopDmg)
            
            var poopActivated = false
            for player in gameManager.players.values {
                if gameManager[moveToPositionOf: player] == node {
                    poop.victim = player
                    eventListener?.addPendingPoopAnimation(poop, target: node)
                    poopActivated = true
                }
            }
            
            node.poop = poopActivated ? nil : poop
        } else if action is ItemAction {
            let itemAction = action as ItemAction
            if !itemAction.item.canTargetSelf() &&
                gameManager.samePlayer(itemAction.targetPlayer, player) {
                    // invalidate action, item cannot effect self.
                    return nil
            } else if itemAction.item.shouldTargetAll() {
                for player in gameManager.players.values {
                    itemAction.item.effect(player)
                }
            } else if itemAction.item.canTargetOthers() ||
                itemAction.item.canTargetSelf() {
                    itemAction.item.effect(itemAction.targetPlayer)
            }
            itemAction.targetNode =
                gameManager[moveToPositionOf: itemAction.targetPlayer]
            gameManager[inventoryOf: player]!.useItem(itemAction.item)
        }
        return action
    }

    func pathOfPui(startNode: TileNode, direction: Direction) -> [TileNode] {
        let offset = grid.neighboursOffset[direction]!
        var path = [TileNode]()
        var currentNode = startNode

        while let nextNode = grid[currentNode.position, with: offset] {
            path.append(nextNode)

            if nextNode.doodad is Wall {
                break
            } else if playerMoveToNodes[nextNode.position] != nil {
                break
            }

            currentNode = nextNode
        }

        return path
    }

    func pathOfFart(startNode: TileNode, range: Int) -> [[Int:TileNode]] {
        return grid.getNodesInRangeAllDirections(startNode, range: range)
    }
    
    private func createPlayers(playerNumber: Int) {
        let cat1 = catFactory.createCat(Constants.cat.grumpyCat)!
        gameManager.registerPlayer(cat1, playerNum: 1)
        gameManager[positionOf: cat1] = grid[0, 0]
        
        let cat2 = catFactory.createCat(Constants.cat.nyanCat)!
        gameManager.registerPlayer(cat2, playerNum: 2)
        gameManager[positionOf: cat2] = grid[grid.rows - 1, 0]
        
        let cat3 = catFactory.createCat(Constants.cat.kittyCat)!
        gameManager.registerPlayer(cat3, playerNum: 3)
        gameManager[positionOf: cat3] = grid[grid.rows - 1, grid.columns - 1]
        
        let cat4 = catFactory.createCat(Constants.cat.octoCat)!
        gameManager.registerPlayer(cat4, playerNum: 4)
        gameManager[positionOf: cat4] = grid[0, grid.columns - 1]
        
        if !multiplayer {
            var bots = [cat1, cat2, cat3, cat4]
            bots.removeAtIndex(playerNumber - 1)
            gameManager.registerAIPlayers(bots)
        }
        
        switch playerNumber {
        case 1:
            currentPlayer = cat1
        case 2:
            currentPlayer = cat2
        case 3:
            currentPlayer = cat3
        case 4:
            currentPlayer = cat4
        default:
            break
        }
    }
    
    func getAvailablePuiDirections(player: Cat) -> [Direction] {
        var targetNode = gameManager[moveToPositionOf: player]!
        if targetNode.doodad is WormholeDoodad {
            targetNode = (targetNode.doodad! as WormholeDoodad)
                .getDestinationNode()
            
        }
        return grid.getAvailableDirections(targetNode)
    }
    
    private func notifyAction() {
        eventListener?.onActionUpdate(gameManager[actionOf: currentPlayer])
    }
    
    private func updateServer(playerNum: Int) {
        let player = gameManager[playerWithNum: playerNum]!
        let currentTile = gameManager[positionOf: player]!
        let moveToTile = gameManager[moveToPositionOf: player]!
        let action = gameManager[actionOf: player]
        
        // use movementNumber - 1 for multiplayer AI movements
        let movementNumber = playerNumber == playerNum
            ? currentPlayerMoveNumber : currentPlayerMoveNumber - 1
        
        gameConnectionManager.updateServer(playerNum,
            currentTile: currentTile,
            moveToTile: moveToTile,
            action: action,
            number: movementNumber
        )
        
        if playerNumber == playerNum {
            currentPlayerMoveNumber++
        }
    }
    
    private func checkAllTurns() {
        if gameManager.allTurnsCompleted {
            countDownTimer?.invalidate()
            triggerStateAdvance()
            println("turn all completed")
            gameManager.clearPlayerTurns()
        }
    }
    
    private func registerMovementWatcherExcept(number: Int) {
        for i in 1...4 {
            if i == number {
                continue
            }
            
            gameConnectionManager.registerPlayerWatcher(i,
                completion: movementUpdate
            )
        }
    }
    
    private func registerSpawnedItemWatcher() {
        gameConnectionManager.registerSpawnedItemWatcher({
            (snapshot) in
            let nodeRow = snapshot.value.objectForKey(
                Constants.Firebase.keyItemRow) as? Int
            let nodeCol = snapshot.value.objectForKey(
                Constants.Firebase.keyItemCol) as? Int
            let itemName = snapshot.value.objectForKey(
                Constants.Firebase.keyItemName) as? String
            let node = self.grid[nodeRow!, nodeCol!]!
            self.pendingItemSpawned[node] = itemName!
        })
    }
    
    private func movementUpdate(snapshot: FDataSnapshot, _ playerNum: Int) {
        let fromRow = snapshot.value.objectForKey(
            Constants.Firebase.keyMoveFromRow) as? Int
        let fromCol = snapshot.value.objectForKey(
            Constants.Firebase.keyMoveFromCol) as? Int
        let moveToRow = snapshot.value.objectForKey(
            Constants.Firebase.keyMoveToRow) as? Int
        let moveToCol = snapshot.value.objectForKey(
            Constants.Firebase.keyMoveToCol) as? Int
        
        let attackType = snapshot.value.objectForKey(
            Constants.Firebase.keyAttkType) as? String
        let attackDir = snapshot.value.objectForKey(
            Constants.Firebase.keyAttkDir) as? String
        let attackDmg = snapshot.value.objectForKey(
            Constants.Firebase.keyAttkDmg) as? Int
        let attackRange = snapshot.value.objectForKey(
            Constants.Firebase.keyAttkRange) as? Int
        
        let player = gameManager[playerWithNum: playerNum]!
        let dest = grid[moveToRow!, moveToCol!]!
        var action: Action?
        
        gameManager[positionOf: player] = grid[fromRow!, fromCol!]
        println("\(player.name)[\(playerNum)]" +
            " moving to \(moveToRow!),\(moveToCol!)"
        )
        
        if let playerActionType = ActionType.create(attackType!) {
            switch playerActionType {
            case .Pui:
                let puiDirection = Direction.create(attackDir!)!
                action = PuiAction(direction: puiDirection)
            case .Fart:
                let fartRange = attackRange!
                action = FartAction(range: fartRange)
            case .Poop:
                let targetNodeRow = snapshot.value.objectForKey(
                    Constants.Firebase.keyTargetRow) as? Int
                let targetNodeCol = snapshot.value.objectForKey(
                    Constants.Firebase.keyTargetCol) as? Int
                let targetNode = grid[targetNodeRow!,
                    targetNodeCol!]!
                
                action = PoopAction(targetNode: targetNode)
            case .Item:
                break
            }
            println("\(player.name)[\(playerNumber)]" +
                " \(playerActionType.description)"
            )
        }
        
        gameManager.playerTurn(player, moveTo: dest, action: action)
        checkAllTurns()
    }

    func getGrid() -> Grid {
        return self.grid
    }
    
    func getPlayer() -> Cat {
        return self.currentPlayer
    }
}

extension GameEngine {
    func triggerPuiButtonPressed(direction: Direction) {
        var action = PuiAction(direction: direction)
        gameManager[actionOf: self.currentPlayer] = action
        notifyAction()
    }

    func triggerFartButtonPressed() {
        gameManager[actionOf: self.currentPlayer] =
            FartAction(range: self.currentPlayer.fartRange)
        notifyAction()
    }

    func triggerPoopButtonPressed() {
        let targetNode = gameManager[positionOf: currentPlayer]!
        gameManager[actionOf: currentPlayer] =
            PoopAction(targetNode: targetNode)
        notifyAction()
    }
    
    func triggerItemButtonPressed() {
        let targetNode = gameManager[positionOf: currentPlayer]!
        let inventory = gameManager[inventoryOf: currentPlayer]!
        let item = inventory.getItem(inventory.selectedItem!)
        gameManager[actionOf: currentPlayer] =
            ItemAction(item: item, targetNode: targetNode,
                targetPlayer: currentPlayer)
        notifyAction()
    }

    func triggerTargetPlayerChanged(targetPlayer: Cat) {
        if let action = gameManager[actionOf: currentPlayer] as? ItemAction {
            action.targetPlayer = targetPlayer
            action.targetNode = gameManager[positionOf: targetPlayer]
        }
    }
    
    func triggerAIPlayerMove(player: Cat, dest: TileNode, action: Action?) {
        gameManager.playerTurn(player, moveTo: dest, action: action)
        if multiplayer {
            updateServer(gameManager[playerNumFor: player]!)
        } else {
            checkAllTurns()
        }
    }
    
    func triggerPlayerActionEnded() {
        triggerStateAdvance()
    }

    func triggerClearAction() {
        gameManager[actionOf: currentPlayer] = nil
    }

    func triggerMovementAnimationEnded() {
        if gameManager.movementsCompleted {
            triggerStateAdvance()
        }
    }
    
    func triggerDeconflictAnimationEnded() {
        if gameManager.deconflictsCompleted {
            triggerStateAdvance()
        }
    }

    func triggerActionAnimationEnded() {
        if gameManager.actionsCompleted {
            triggerStateAdvance()
        }
    }
}