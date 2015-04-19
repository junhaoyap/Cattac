import Foundation

protocol GameStateListener {
    func onStateUpdate(state: GameState)
}

protocol EventListener {
    func onActionUpdate(action: Action?)
    func onItemObtained(item: Item, _ isCurrentPlayer: Bool)
    func addPendingPoopAnimation(target: GridIndex)
}

/// Game engine that does all the logic computation for the game.
class GameEngine {
    private let catFactory = CatFactory.sharedInstance
    
    /// Firebase reference. To be wrapped in upcoming Server Protocol.
    private let ref = Firebase(url: Constants.Firebase.baseUrl)
    
    // The game grid
    private var grid: Grid!
    
    /// Dictionary of Firebase references watching a data value.
    private var movementWatchers: [Int: Firebase] = [:]

    // The AI engine that is used when multiplayer mode is not active
    private var gameAI: GameAI!
    
    /// States to advance, initialized at 1 to rollover PostExecution state.
    private var statesToAdvance: Int = 1

    var gameManager: GameManager = GameManager()
    
    /// Player index (we should change to player-id instead).
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
    
    /// Calculated reachable nodes for currentPlayer.
    var reachableNodes: [Int:TileNode] = [:]

    /// Whether the game is currently in multiplayer mode
    var multiplayer: Bool
    
    /// The number of players that moved that the local player is listening to
    var otherPlayersMoved = 0
    
    init(grid: Grid, playerNumber: Int, multiplayer: Bool) {
        println("init GameEngine as playerNumber \(playerNumber)")
        self.playerNumber = playerNumber
        
        self.grid = grid

        self.multiplayer = multiplayer
        
        createPlayers(playerNumber)
        
        if multiplayer {
            registerMovementWatcherExcept(playerNumber)
        } else {
            self.gameAI = GameAI(grid: grid, gameManager: gameManager,
                currentPlayer: currentPlayer)
        }
    }
    
    /// Called every update by gameScene (60 times per second)
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
            updateServer()
            triggerStateAdvance()
        case .WaitForAll:
            break
        case .AICalculation:
            gameAI.calculateTurn()
            triggerStateAdvance()
        case .StartMovesExecution:
            calculateMovementPaths()
            triggerStateAdvance()
        case .MovesExecution:
            // This state waits for the movement ended event that is triggered
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
            postExecute()
            triggerStateAdvance()
        }
    }
    
    /// Releases all resources associated with this game, called
    /// when game has ended.
    func end() {
        for ref in movementWatchers.values {
            ref.removeAllObservers()
        }
    }
    
    /// Trigger state advancement in game engine.
    private func triggerStateAdvance() {
        statesToAdvance++
    }
    
    /// Effectively advances the state, GameState shall not be
    /// altered out of this method.
    private func advanceState() {
        switch state {
        case .Precalculation:
            state = .PlayerAction
        case .PlayerAction:
            if multiplayer {
                state = .ServerUpdate
            } else {
                state = .AICalculation
            }
        case .ServerUpdate:
            state = .WaitForAll
        case .WaitForAll:
            state = .StartMovesExecution
        case .AICalculation:
            state = .StartMovesExecution
        case .StartMovesExecution:
            state = .MovesExecution
        case .MovesExecution:
            state = .StartActionsExecution
        case .StartActionsExecution:
            state = .ActionsExecution
        case .ActionsExecution:
            state = .PostExecution
        case .PostExecution:
            state = .Precalculation
        }
        
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
    
    private func updateServer() {
        let playerMoveUpdateRef = ref
            .childByAppendingPath(Constants.Firebase.nodeGames)
            .childByAppendingPath(Constants.Firebase.nodeGame)
            .childByAppendingPath(Constants.Firebase.nodePlayers)
            .childByAppendingPath("\(playerNumber - 1)")
            .childByAppendingPath(Constants.Firebase.nodePlayerMovements)
            .childByAppendingPath("\(currentPlayerMoveNumber++)")

        let currentTile = gameManager[positionOf: currentPlayer]!
        let moveToTile = gameManager[moveToPositionOf: currentPlayer]!
        let action = gameManager[actionOf: currentPlayer]
        
        var moveData = [:]
        
        if action == nil {
            moveData = [
                Constants.Firebase.keyMoveFromRow: currentTile.position.row,
                Constants.Firebase.keyMoveFromCol: currentTile.position.col,
                Constants.Firebase.keyMoveToRow: moveToTile.position.row,
                Constants.Firebase.keyMoveToCol: moveToTile.position.col,
                Constants.Firebase.keyAttkType: "",
                Constants.Firebase.keyAttkDir: "",
                Constants.Firebase.keyAttkRange: "",
                Constants.Firebase.keyTargetRow: "",
                Constants.Firebase.keyTargetCol: ""
            ]
        } else {
            let targetNode = action?.targetNode
            moveData = [
                Constants.Firebase.keyMoveFromRow: currentTile.position.row,
                Constants.Firebase.keyMoveFromCol: currentTile.position.col,
                Constants.Firebase.keyMoveToRow: moveToTile.position.row,
                Constants.Firebase.keyMoveToCol: moveToTile.position.col,
                Constants.Firebase.keyAttkType: action!.actionType.description,
                Constants.Firebase.keyAttkDir: action!.direction.description,
                Constants.Firebase.keyAttkRange: action!.range,
                Constants.Firebase.keyTargetRow:
                    targetNode != nil ? targetNode!.position.row : 0,
                Constants.Firebase.keyTargetCol:
                    targetNode != nil ? targetNode!.position.col : 0
            ]
        }
        
        playerMoveUpdateRef.updateChildValues(moveData)
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
            var playerAtNode = gameManager[positionOf: player]!
            var playerMoveToNode = gameManager[moveToPositionOf: player]!
            var path = grid.shortestPathFromNode(playerAtNode,
                toNode: playerMoveToNode)
            
            if let doodad = playerMoveToNode.doodad {
                // effect non-move modifications
                doodad.postmoveEffect(player)
                if doodad is WormholeDoodad {
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
                poop.effect(player)
                playerMoveToNode.poop = nil
                
                eventListener?.addPendingPoopAnimation(playerMoveToNode.position)
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
        }
    }
    
    private func postExecute() {
        gameManager.advanceTurn()
        
        for player in gameManager.players.values {
            player.postExecute()
            let tileNode = gameManager[positionOf: player]!
            
            if let item = tileNode.item {
                gameManager[itemOf: player]?.sprite.removeFromParent()
                
                gameManager[itemOf: player] = item
                tileNode.item = nil
                
                let isCurrentPlayer = currentPlayer.name == player.name
                eventListener?.onItemObtained(item, isCurrentPlayer)
            }
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
            let targetNode = action!.targetNode!
            targetNode.poop = Poop(player, player.poopDmg)
        } else if action is ItemAction {
            let itemAction = action as ItemAction
            if !itemAction.item.canTargetSelf() &&
                gameManager.samePlayer(itemAction.targetPlayer, player) {
                    // invalidate action, item cannot effect self.
                    return nil
            }
            itemAction.targetNode =
                gameManager[moveToPositionOf: itemAction.targetPlayer]
            itemAction.item.effect(itemAction.targetPlayer)
        }
        return action
    }

    func pathOfPui(startNode: TileNode, direction: Direction) -> [TileNode] {
        let offset = grid.neighboursOffset[direction]!
        var path = [TileNode]()
        var currentNode = startNode
        while let nextNode = grid[currentNode.position, with: offset] {
            if let doodad = nextNode.doodad {
                if doodad.getName() == Constants.Doodad.wallString {
                    path.append(nextNode)
                    break
                }
            }
            path.append(nextNode)
            currentNode = nextNode
        }
        return path
    }

    func pathOfFart(startNode: TileNode, range: Int) -> [[Int:TileNode]] {
        return grid.getNodesInRangeAllDirections(startNode, range: range)
    }
    
    private func createPlayers(playerNumber: Int) {
        let cat1 = catFactory.createCat(Constants.catName.nalaCat)!
        gameManager.registerPlayer(cat1)
        gameManager[positionOf: cat1] = grid[0, 0]
        
        let cat2 = catFactory.createCat(Constants.catName.nyanCat)!
        gameManager.registerPlayer(cat2)
        gameManager[positionOf: cat2] = grid[grid.rows - 1, 0]
        
        let cat3 = catFactory.createCat(Constants.catName.grumpyCat)!
        gameManager.registerPlayer(cat3)
        gameManager[positionOf: cat3] = grid[grid.rows - 1, grid.columns - 1]
        
        let cat4 = catFactory.createCat(Constants.catName.pusheenCat)!
        gameManager.registerPlayer(cat4)
        gameManager[positionOf: cat4] = grid[0, grid.columns - 1]
        
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
    
    private func registerMovementWatcherExcept(number: Int) {
        for i in 1...4 {
            if i == number {
                continue
            }
            let playerMovementWatcherRef = ref.childByAppendingPath(Constants.Firebase.nodeGames)
                .childByAppendingPath(Constants.Firebase.nodeGame)
                .childByAppendingPath(Constants.Firebase.nodePlayers)
                .childByAppendingPath("\(i - 1)")
                .childByAppendingPath(Constants.Firebase.nodePlayerMovements)

            playerMovementWatcherRef.observeEventType(.ChildAdded, withBlock: {
                snapshot in
                
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
                
                let player = self.gameManager[Constants.catArray[i - 1]]!
                
                self.gameManager[positionOf: player] = self.grid[fromRow!, fromCol!]
                self.gameManager[moveToPositionOf: player] = self.grid[moveToRow!, moveToCol!]
                println("\(player.name)[\(i)] moving to \(moveToRow!),\(moveToCol!)")
                
                if let playerActionType = ActionType.create(attackType!) {
                    switch playerActionType {
                    case .Pui:
                        let puiDirection = Direction.create(attackDir!)!
                        self.gameManager[actionOf: player] = PuiAction(direction: puiDirection)
                    case .Fart:
                        let fartRange = attackRange!
                        self.gameManager[actionOf: player] = FartAction(range: fartRange)
                    case .Poop:
                        let targetNodeRow = snapshot.value.objectForKey(
                            Constants.Firebase.keyTargetRow) as? Int
                        let targetNodeCol = snapshot.value.objectForKey(
                            Constants.Firebase.keyTargetCol) as? Int
                        let targetNode = self.grid[targetNodeRow!, targetNodeCol!]!
                        
                        self.gameManager[actionOf: player] = PoopAction(targetNode: targetNode)
                    case .Item:
                        break
                    }
                    println("\(player.name)[\(i)] \(playerActionType.description)")
                }
                
                self.otherPlayersMoved++
                
                if self.otherPlayersMoved == 3 {
                    self.triggerAllPlayersMoved()
                    self.otherPlayersMoved = 0
                }
            })
        }
    }
    
    func getAvailablePuiDirections() -> [Direction] {
        var targetNode = gameManager[moveToPositionOf: currentPlayer]!
        if targetNode.doodad is WormholeDoodad {
            targetNode = (targetNode.doodad! as WormholeDoodad)
                .getDestinationNode()
            
        }
        return grid.getAvailableDirections(targetNode)
    }
    
    private func notifyAction() {
        eventListener?.onActionUpdate(gameManager[actionOf: currentPlayer])
    }
    
    func releaseAllListeners() {
        ref.removeAllObservers()
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
        let item = gameManager[itemOf: currentPlayer]!
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
    
    func triggerPlayerActionEnded() {
        triggerStateAdvance()
    }

    func triggerClearAction() {
        gameManager[actionOf: currentPlayer] = nil
    }

    func triggerAllPlayersMoved() {
        triggerStateAdvance()
    }

    func triggerMovementAnimationEnded() {
        if gameManager.movementsCompleted {
            triggerStateAdvance()
        }
    }

    func triggerActionAnimationEnded() {
        if gameManager.actionsCompleted {
            triggerStateAdvance()
        }
    }
}