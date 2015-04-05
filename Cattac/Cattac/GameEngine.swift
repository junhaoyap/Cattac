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

class GameEngine {
    let catFactory = CatFactory()
    var state: GameState = GameState.Precalculation
    var gameStateListener: GameStateListener?
    var player: Cat!
    private var grid: Grid<TileNode>!
    private var graph: Graph<TileNode>!
    private var allPlayerPositions: [String:TileNode] = [:]
    private var allPlayerMoveToPositions: [String:TileNode] = [:]
    private var allPlayerActions: [String:Action] = [:]
    var reachableNodes: [Int:Node<TileNode>] = [:]
    private var events: [String:()->()] = [:]
    
    init(grid: Grid<TileNode>, graph: Graph<TileNode>) {
        self.grid = grid
        self.graph = graph
        addPlayers()
        
        self.on("puiButtonPressed") {
            self.currentPlayerAction = PuiAction()
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
            // Goes to next state for now
            nextState()
        case .StartMovesExecution:
            break
        case .MovesExecution:
            break
        case .StartActionsExecution:
            break
        case .ActionsExecution:
            nextState()
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
    
    var currentPlayerNode: TileNode {
        get {
            return allPlayerPositions[player.name]!
        }
        set {
            allPlayerPositions[player.name] = newValue
        }
    }

    func precalculate() {
        if let doodad = currentPlayerNode.doodad {
            doodad.effect(player)
        }
        reachableNodes = graph.getNodesInRange(Node(currentPlayerNode), range: player.moveRange)
        allPlayerActions = [:]
    }
    
    func postExecute() {
        player.postExecute()
    }
    
    var currentPlayerMoveToNode: TileNode {
        get {
            return allPlayerMoveToPositions[player.name]!
        }
        set {
            allPlayerMoveToPositions[player.name] = newValue
        }
    }
    
    var currentPlayerAction: Action? {
        get {
            return allPlayerActions[player.name]?
        }
        set {
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
    
    private func addPlayers() {
        let cat = catFactory.createCat(Constants.catName.nalaCat)!
        cat.position = GridIndex(0, 0)
        allPlayerPositions[cat.name] = grid[cat.position]
        player = cat
        currentPlayerMoveToNode = currentPlayerNode
    }
}