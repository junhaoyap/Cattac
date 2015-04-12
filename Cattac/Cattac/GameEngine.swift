/*
    Cattac's Game Engine
*/

import Foundation

enum GameState {
    case Precalculation, PlayerAction, ServerUpdate, WaitForAll, StartMovesExecution, MovesExecution, StartActionsExecution, ActionsExecution, PostExecution
}

protocol GameStateListener {
    func onStateUpdate(state: GameState)
}

protocol ActionListener {
    func onActionUpdate(action: Action?)
}

class GameEngine {
    private let catFactory = CatFactory.sharedInstance
    
    /// Firebase reference. To be wrapped in upcoming Server Protocol.
    private let ref = Firebase(url: "https://torrid-inferno-1934.firebaseio.com/")
    
    private var grid: Grid!
    
    /// Dictionary of event trigger closures.
    private var events: [String:()->()] = [:]
    
    /// Dictionary of Firebase references watching a data value.
    private var movementWatchers: [Int: Firebase] = [:]

    var gameManager: GameManager = GameManager()
    
    /// Player index (we should change to player-id instead).
    var playerNumber = 1
    
    var state: GameState = GameState.Precalculation
    
    /// GameState listener, listens for update on state change.
    var gameStateListener: GameStateListener?
    
    /// Action listener, listens for action change on currentPlayer.
    var actionListener: ActionListener?
    
    /// The local player
    var currentPlayer: Cat!
    
    /// currentPlayer's movement index, for backend use.
    var currentPlayerMoveNumber: Int = 1
    
    /// Calculated reachable nodes for currentPlayer.
    var reachableNodes: [Int:TileNode] = [:]
    
    var actionStateOver = false
    
    var otherPlayersMoved = 0
    
    init(grid: Grid, playerNumber: Int) {
        println("init GameEngine as playerNumber \(playerNumber)")
        self.playerNumber = playerNumber
        
        self.grid = grid
        
        createPlayers(playerNumber)
        
        registerMovementWatcherExcept(playerNumber)
        
        self.on("puiButtonPressed") {
            self.setAvailablePuiDirections()
            self.notifyAction()
        }
        
        self.on("fartButtonPressed") {
            self.gameManager[actionOf: self.currentPlayer] = FartAction(range: 2)
            self.notifyAction()
        }
        
        self.on("poopButtonPressed") {
            let targetNode = self.gameManager[positionOf: self.currentPlayer]!
            self.gameManager[actionOf: self.currentPlayer] = PoopAction(targetNode: targetNode)
            self.notifyAction()
        }
        
        self.on("allPlayersMoved") {
            self.nextState()
        }
        
        self.on("movementAnimationEnded") {
            if self.gameManager.movementsCompleted {
                self.nextState()
            }
        }
    }
    
    func gameLoop() {
        switch state {
        case .Precalculation:
            actionStateOver = false
            precalculate()
            nextState()
        case .PlayerAction:
            break
        case .ServerUpdate:
            updateServer()
            nextState()
        case .WaitForAll:
            calculateMovementPaths()
        case .StartMovesExecution:
            nextState()
        case .MovesExecution:
            // This state waits for the movement ended event that is triggered
            // from the scene.
            break
        case .StartActionsExecution:
            nextState()
        case .ActionsExecution:
            nextState()
        case .PostExecution:
            postExecute()
            nextState()
        }
    }
    
    func end() {
        for ref in movementWatchers.values {
            ref.removeAllObservers()
        }
    }
    
    func nextState() {
        switch state {
        case .Precalculation:
            state = GameState.PlayerAction
        case .PlayerAction:
            state = GameState.ServerUpdate
        case .ServerUpdate:
            state = GameState.WaitForAll
        case .WaitForAll:
            state = GameState.StartMovesExecution
        case .StartMovesExecution:
            state = GameState.MovesExecution
        case .MovesExecution:
            state = GameState.StartActionsExecution
        case .StartActionsExecution:
            state = GameState.ActionsExecution
        case .ActionsExecution:
            state = GameState.PostExecution
        case .PostExecution:
            state = GameState.Precalculation
        }
        
        gameStateListener?.onStateUpdate(state)
    }
    
    func precalculate() {
        gameManager.precalculate()
        
        reachableNodes = grid.getNodesInRange(
            gameManager[positionOf: currentPlayer]!,
            range: currentPlayer.moveRange
        )
    }
    
    func updateServer() {
        let playerMoveUpdateRef = ref
            .childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("player\(playerNumber)Movement")
            .childByAppendingPath("\(currentPlayerMoveNumber++)")

        let currentPlayerTileNode = gameManager[positionOf: currentPlayer]!
        let currentPlayerMoveToTileNode = gameManager[moveToPositionOf: currentPlayer]!
        
        let currentPlayerMoveData = [
            "fromRow": currentPlayerTileNode.position.row,
            "fromCol": currentPlayerTileNode.position.col,
            "toRow": currentPlayerMoveToTileNode.position.row,
            "toCol": currentPlayerMoveToTileNode.position.col,
            "attackType": "",
            "attackDir": "",
            "attackDmg": ""
        ]
        
        playerMoveUpdateRef.updateChildValues(currentPlayerMoveData)
    }

    func setCurrentPlayerMoveToPosition(node: TileNode) {
        gameManager[moveToPositionOf: currentPlayer] = node
    }
    
    func calculateMovementPaths() {
        for player in gameManager.players.values {
            var playerAtNode = gameManager[positionOf: player]!
            var playerMoveToNode = gameManager[moveToPositionOf: player]!
            var path = grid.shortestPathFromNode(playerAtNode,
                toNode: playerMoveToNode)
            
            if let doodad = playerMoveToNode.doodad {
                if doodad is WormholeDoodad {
                    let destNode = (doodad as WormholeDoodad).getDestinationNode()
                    gameManager[moveToPositionOf: player]! = destNode
                    path += [destNode]
                }
            }
            gameManager[movementPathOf: player] = path
        }
    }
    
    func postExecute() {
        gameManager.advanceTurn()
        currentPlayer.postExecute()
        actionStateOver = true
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
        return gameManager[actionOf: player]
    }
    
    func trigger(event: String) {
        if let lambda = events[event] {
            lambda()
        }
    }
    
    func on(event: String, _ lambda: ()->()) {
        events[event] = lambda
    }
    
    func pathOfPui(startNode: TileNode, direction: Direction) -> [TileNode] {
        let offset = grid.neighboursOffset[direction]!
        var path = [TileNode]()
        var currentNode = startNode
        while let nextNode = grid[currentNode.position, with: offset] {
            if let doodad = nextNode.doodad {
                if doodad.getName() == "wall" {
                    path.append(nextNode)
                    break
                }
            }
            path.append(nextNode)
            currentNode = nextNode
        }
        return path
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
            let playerMovementWatcherRef = ref.childByAppendingPath("games")
                .childByAppendingPath("game0")
                .childByAppendingPath("player\(i)Movement")

            playerMovementWatcherRef.observeEventType(.ChildAdded, withBlock: {
                snapshot in
                
                let fromRow = snapshot.value.objectForKey("fromRow") as? Int
                let fromCol = snapshot.value.objectForKey("fromCol") as? Int
                let moveToRow = snapshot.value.objectForKey("toRow") as? Int
                let moveToCol = snapshot.value.objectForKey("toCol") as? Int
                
                let player = self.gameManager[Constants.catArray[i - 1]]!
                self.gameManager[positionOf: player] = self.grid[fromRow!, fromCol!]
                self.gameManager[moveToPositionOf: player] = self.grid[moveToRow!, moveToCol!]
                println("\(player.name)[\(i)] moving to \(moveToRow!),\(moveToCol!)")
                
                self.otherPlayersMoved++
                println(self.otherPlayersMoved)
                
                if self.otherPlayersMoved == 3 {
                    self.trigger("allPlayersMoved")
                    self.otherPlayersMoved = 0
                }
            })
        }
    }
    
    private func setAvailablePuiDirections() {
        let targetNode = gameManager[moveToPositionOf: currentPlayer]!
        let availableDirections = grid.getAvailableDirections(targetNode)
        var action = PuiAction(direction: availableDirections.first!)
        action.availableDirections = availableDirections
        gameManager[actionOf: currentPlayer] = action
    }
    
    private func notifyAction() {
        if let action = gameManager[actionOf: currentPlayer] {
            actionListener?.onActionUpdate(action)
        }
    }
}