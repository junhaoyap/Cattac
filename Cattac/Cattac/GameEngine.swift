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
    var player: Cat!
    var playerMoveNumber: Int = 1
    private var grid: Grid<TileNode>!
    private var graph: Graph<TileNode>!
    private var allPlayer: [String:Cat] = [:]
    private var allPlayerPositions: [String:TileNode] = [:]
    private var allPlayerMoveToPositions: [String:TileNode] = [:]
    private var allPlayerActions: [String:Action] = [:]
    var reachableNodes: [Int:Node<TileNode>] = [:]
    var removedDoodads: [Int:Doodad] = [:]
    private var events: [String:()->()] = [:]
    
    init(grid: Grid<TileNode>, graph: Graph<TileNode>) {
        self.grid = grid
        self.graph = graph
        addPlayers()
        
        self.on("puiButtonPressed") {
            self.setAvailableDirections()
        }
        
        self.on("fartButtonPressed") {
            self.currentPlayerAction = FartAction(range: 2)
        }
        
        self.on("poopButtonPressed") {
            self.currentPlayerAction = PoopAction(targetNode: self.currentPlayerMoveToNode)
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
            break
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
        if let doodad = currentPlayerNode.doodad {
            doodad.effect(player)
            
            if doodad.isRemoved() {
                currentPlayerNode.doodad = nil
                removedDoodads[doodad.getSprite().hashValue] = doodad
            }
        }
        
        currentPlayerMoveToNode = currentPlayerNode
        reachableNodes = graph.getNodesInRange(Node(currentPlayerNode), range: player.moveRange)
        allPlayerActions = [:]
        
        for player in allPlayer {
            println(player.1.hp)
        }
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
    
    func postExecute() {
        player.postExecute()
    }
    
    var currentPlayerNode: TileNode {
        get {
            return allPlayerPositions[player.name]!
        }
        set {
            allPlayerPositions[player.name] = newValue
        }
    }
    
    var currentPlayerMoveToNode: TileNode {
        get {
            return allPlayerMoveToPositions[player.name]!
        }
        set {
            if allPlayerMoveToPositions[player.name] != newValue {
                currentPlayerAction = nil
            }
            allPlayerMoveToPositions[player.name] = newValue
        }
    }
    
    var currentPlayerAction: Action? {
        get {
            return allPlayerActions[player.name]?
        }
        set {
            if allPlayerActions[player.name] != newValue {
                if let listener = actionListener {
                    listener.onActionUpdate(newValue)
                }
            }
            allPlayerActions[player.name] = newValue
        }
    }
    
    func trigger(event: String) {
        if let lambda = events[event] {
            lambda()
        }
    }
    
    func on(event: String, _ lambda: ()->()) {
        events[event] = lambda
    }
    
    func pathTo(node: TileNode) -> [Edge<TileNode>] {
        let fromNode = allPlayerPositions[player.name]!
        let edges = graph.shortestPathFromNode(Node(fromNode), toNode: Node(node))
        currentPlayerNode = node
        return edges
    }
    
    func getAllPlayers() -> [String:Cat] {
        return allPlayer
    }
    
    func pathOfPui(startNode: TileNode, direction: Direction) -> [TileNode] {
        let offset = grid.neighboursOffset[direction.description]!
        var path = [TileNode]()
        var currentNode = startNode
        while let nextNode = grid[currentNode.row + offset.row,
            currentNode.column + offset.column] {
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
    
    private func addPlayers() {
        let cat = catFactory.createCat(Constants.catName.nalaCat)!
        cat.position = GridIndex(0, 0)
        allPlayerPositions[cat.name] = grid[cat.position]
        player = cat
        currentPlayerMoveToNode = currentPlayerNode
        
        let cat2 = catFactory.createCat(Constants.catName.grumpyCat)!
        cat2.position = GridIndex(9, 0)
        allPlayer[cat2.name] = cat2
        allPlayerPositions[cat2.name] = grid[cat2.position]
        
        let cat3 = catFactory.createCat(Constants.catName.nyanCat)!
        cat3.position = GridIndex(9, 9)
        allPlayer[cat3.name] = cat3
        allPlayerPositions[cat3.name] = grid[cat3.position]
        
        let cat4 = catFactory.createCat(Constants.catName.pusheenCat)!
        cat4.position = GridIndex(0, 9)
        allPlayer[cat4.name] = cat4
        allPlayerPositions[cat4.name] = grid[cat4.position]
    }
    
    private func setAvailableDirections() {
        let originNode = self.currentPlayerMoveToNode
        var directionIsSet = false
        var action: PuiAction!
        for (direction, offset) in grid.neighboursOffset {
            if let targetNode = grid[originNode.row + offset.row,
                originNode.column + offset.column] {
                    let edges = graph.edgesFromNode(Node(originNode), toNode: Node(targetNode))
                    if edges.count > 0 {
                        let dir = Direction.create(direction)!
                        if !directionIsSet {
                            action = PuiAction(direction: dir)
                            directionIsSet = true
                        }
                        action.availableDirections.append(dir)
                    }
            }
        }
        if action != nil {
            currentPlayerAction = action
        }
    }
}