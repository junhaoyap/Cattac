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
    let catFactory = CatFactory.sharedInstance
    let ref = Firebase(url: "https://torrid-inferno-1934.firebaseio.com/")
    var state: GameState = GameState.Precalculation
    var gameStateListener: GameStateListener?
    var actionListener: ActionListener?
    var currentPlayer: Cat!
    var playerMoveNumber: Int = 1
    var players: [String:Cat] = [:]
    private var grid: Grid!
    private var playersPendingPaths: [String:[TileNode]] = [:]
    var reachableNodes: [Int:TileNode] = [:]
    var removedDoodads: [Int:Doodad] = [:]
    private var events: [String:()->()] = [:]
    
    init(grid: Grid) {
        self.grid = grid
        let player = catFactory.createCat(Constants.catName.nalaCat)!
        player.currNode = grid[0, 0]
        setCurrentPlayer(player)
        
        self.on("puiButtonPressed") {
            self.setAvailableDirections()
        }
        
        self.on("fartButtonPressed") {
            self.currentPlayer.action = FartAction(range: 2)
        }
        
        self.on("poopButtonPressed") {
            let targetNode = self.currentPlayer.currNode
            self.currentPlayer.action = PoopAction(targetNode: targetNode)
        }
    }
    
    func gameLoop() {
        switch state {
        case .Precalculation:
            precalculate()
            nextState()
        case .PlayerAction:
            break
        case .ServerUpdate:
            updateServer()
            nextState()
        case .StartMovesExecution:
            calculateMovementPaths()
            nextState()
        case .MovesExecution:
            break
        case .StartActionsExecution:
            break
        case .ActionsExecution:
            break
        case .PostExecution:
            postExecute()
            nextState()
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
        
        if let listener = gameStateListener {
            listener.onStateUpdate(state)
        }
    }
    
    func gameInitialise() {
        // check from firebase which player current player is
        
        // attach listener to the game movements
        let player1MoveToWatchRef = ref
            .childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("player1")
        
        let player2MoveToWatchRef = ref
            .childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("player2")
        
        let player3MoveToWatchRef = ref
            .childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("player3")
        
        let player4MoveToWatchRef = ref
            .childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("player4")
        
        player1MoveToWatchRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 1
            // and execute it in the execution phase
        })
        
        player1MoveToWatchRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 1
            // and execute it in the execution phase
        })
        
        player2MoveToWatchRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 2
            // and execute it in the execution phase
        })
        
        player2MoveToWatchRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 2
            // and execute it in the execution phase
        })
        
        player3MoveToWatchRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 3
            // and execute it in the execution phase
        })
        
        player3MoveToWatchRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 3
            // and execute it in the execution phase
        })
        
        player4MoveToWatchRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 4
            // and execute it in the execution phase
        })
        
        player4MoveToWatchRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            let move = snapshot.value.objectForKey(
                String(self.playerMoveNumber - 1)
            )
            
            // attach the movement to player 4
            // and execute it in the execution phase
        })
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
        let playerNumber = 1
        // for now let it be 1, we will check which player the player is during
        // a new phase, i.e. game initialisation
        
        let playerMoveToUpdateRef = ref
            .childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("player" + String(playerNumber) + "Movement")
            .childByAppendingPath(String(playerMoveNumber))
        
        let theMovement = [
            "player": playerNumber,
            "from": "",
            "to": "",
            "attackType": "",
            "attackFrom": "",
            "attackTo": "",
            "attackDmg": ""
        ]
        
        playerMoveToUpdateRef.updateChildValues(theMovement)
        
        playerMoveNumber++
    }
    
    func calculateMovementPaths() {
        var playerAtNode = currentPlayer.currNode
        var playerMoveToNode = currentPlayer.destNode
        var path = grid.shortestPathFromNode(playerAtNode, toNode: playerMoveToNode)
        
        if let doodad = playerMoveToNode.doodad {
            if doodad is WormholeDoodad {
                let destNode = (doodad as WormholeDoodad).getDestinationNode()
                path += [destNode]
            }
        }
        playersPendingPaths[currentPlayer.name] = path
    }
    
    func postExecute() {
        currentPlayer.postExecute()
    }
    
    func executePlayerMove(cat: Cat) -> [TileNode] {
        let path = playersPendingPaths[cat.name]!
        if let lastNode = path.last {
            cat.currNode = lastNode
        }
        return path
    }
    
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
    
    func setCurrentPlayer(player: Cat) {
        players[player.name] = player
        currentPlayer = player
        player.destNode = player.currNode
    }
    
    func addPlayer(player: Cat) {
        players[player.name] = player
        player.destNode = player.currNode
    }
    
    private func setAvailableDirections() {
        let availableDirections = grid.getAvailableDirections(currentPlayer.destNode)
        var action = PuiAction(direction: availableDirections.first!)
        action.availableDirections = availableDirections
        currentPlayer.action = action
    }
}