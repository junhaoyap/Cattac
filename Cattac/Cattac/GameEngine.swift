/*
    Cattac's Game Engine
*/

import Foundation

enum GameState {
    case Precalculation, PlayerAction, ServerUpdate, StartMovesExecution, MovesExecution, StartActionsExecution, ActionsExecution, PostExecution
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
    
    /// Dictionary of calculated player paths at the end of ServerUpdate. Cleared at Precalculation.
    private var playersPendingPaths: [String:[TileNode]] = [:]
    
    /// Dictionary of event trigger closures.
    private var events: [String:()->()] = [:]
    
    /// Dictionary of Firebase references watching a data value.
    private var movementWatchers: [Int: Firebase] = [:]
    
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
    
    /// Dictionary of all players in game.
    var players: [String:Cat] = [:]
    
    /// Calculated reachable nodes for currentPlayer.
    var reachableNodes: [Int:TileNode] = [:]
    
    /// Dictionary of removed doodads pending removal on UI
    var removedDoodads: [Int:Doodad] = [:]
    
    init(grid: Grid, playerNumber: Int) {
        self.grid = grid
        
        createPlayers(playerNumber)
        
        registerMovementWatcherExcept(playerNumber)
        
        self.on("puiButtonPressed") {
            self.setAvailablePuiDirections()
            self.notifyAction()
        }
        
        self.on("fartButtonPressed") {
            self.currentPlayer.action = FartAction(range: 2)
            self.notifyAction()
        }
        
        self.on("poopButtonPressed") {
            let targetNode = self.currentPlayer.currNode
            self.currentPlayer.action = PoopAction(targetNode: targetNode)
            self.notifyAction()
        }
    }
    
    func gameLoop() {
        //TODO check scene ready or scene notify ready before nextstate(), currently ignores scene readiness
        switch state {
        case .Precalculation:
            precalculate()
            nextState()
        case .PlayerAction:
            break
        case .ServerUpdate:
            updateServer()
            calculateMovementPaths()
            nextState()
            break
        case .StartMovesExecution:
            nextState()
            break
        case .MovesExecution:
            nextState()
            break
        case .StartActionsExecution:
            nextState()
            break
        case .ActionsExecution:
            nextState()
            break
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
        for player in players.values {
            let tileNode = player.currNode
            if let doodad = tileNode.doodad {
                doodad.effect(player)
                
                if doodad.isRemoved() {
                    tileNode.doodad = nil
                    removedDoodads[doodad.getSprite().hashValue] = doodad
                }
            }
            player.destNode = player.currNode
            player.action = nil
        }
        
        reachableNodes = grid.getNodesInRange(currentPlayer.currNode, range: currentPlayer.moveRange)
    }
    
    func updateServer() {
        
        let playerMoveUpdateRef = ref
            .childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("player" + String(playerNumber) + "Movement")
            .childByAppendingPath(String(currentPlayerMoveNumber))
        
        let currentPlayerMoveData = [
            "fromRow": currentPlayer.currNode.position.row,
            "fromCol": currentPlayer.currNode.position.col,
            "toRow": currentPlayer.destNode.position.row,
            "toCol": currentPlayer.destNode.position.col,
            "attackType": "",
            "attackDir": "",
            "attackDmg": ""
        ]
        
        playerMoveUpdateRef.updateChildValues(currentPlayerMoveData)
    }
    
    func calculateMovementPaths() {
        for player in players.values {
            var playerAtNode = player.currNode
            var playerMoveToNode = player.destNode
            var path = grid.shortestPathFromNode(playerAtNode, toNode: playerMoveToNode)
            
            if let doodad = playerMoveToNode.doodad {
                if doodad is WormholeDoodad {
                    let destNode = (doodad as WormholeDoodad).getDestinationNode()
                    path += [destNode]
                }
            }
            playersPendingPaths[player.name] = path
        }
    }
    
    func postExecute() {
        currentPlayer.postExecute()
    }
    
    /// Called by UI to notify game engine that movement is executed on UI
    /// and player position can be updated
    ///
    /// :param: cat The player's move to execute
    func executePlayerMove(player: Cat) -> [TileNode] {
        let path = playersPendingPaths[player.name]
        if let lastNode = path?.last {
            player.currNode = lastNode
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
    func executePlayerAction(cat: Cat) -> Action? {
        return cat.action
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
        cat1.currNode = grid[0, 0]
        players[cat1.name] = cat1
        addPlayer(cat1)
        
        let cat2 = catFactory.createCat(Constants.catName.grumpyCat)!
        cat2.currNode = grid[grid.rows - 1, 0]
        players[cat2.name] = cat2
        addPlayer(cat2)
        
        let cat3 = catFactory.createCat(Constants.catName.nyanCat)!
        cat3.currNode = grid[grid.rows - 1, grid.columns - 1]
        players[cat3.name] = cat3
        addPlayer(cat3)
        
        let cat4 = catFactory.createCat(Constants.catName.pusheenCat)!
        cat4.currNode = grid[0, grid.columns - 1]
        players[cat4.name] = cat4
        addPlayer(cat4)
        
        switch playerNumber {
        case 1:
            setCurrentPlayer(cat1)
        case 2:
            setCurrentPlayer(cat2)
        case 3:
            setCurrentPlayer(cat3)
        case 4:
            setCurrentPlayer(cat4)
        default:
            break
        }
    }
    
    private func setCurrentPlayer(player: Cat) {
        players[player.name] = player
        currentPlayer = player
        player.destNode = player.currNode
    }
    
    private func addPlayer(player: Cat) {
        players[player.name] = player
        player.destNode = player.currNode
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
                
                if fromRow == nil || fromCol == nil || moveToRow == nil || moveToCol == nil {
                    //ignore for now, shall be addressed together with turn sync issue
                    return
                }
                
                let player = self.players[Constants.catArray[i]]!
                player.currNode = self.grid[fromRow!, fromCol!]
                player.destNode = self.grid[moveToRow!, moveToCol!]
            })
        }
    }
    
    private func setAvailablePuiDirections() {
        let availableDirections = grid.getAvailableDirections(currentPlayer.destNode)
        var action = PuiAction(direction: availableDirections.first!)
        action.availableDirections = availableDirections
        currentPlayer.action = action
    }
    
    private func notifyAction() {
        if let action = currentPlayer.action {
            actionListener?.onActionUpdate(action)
        }
    }
}