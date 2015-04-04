/*
    Cattac's Game Engine
*/

import Foundation

enum GameState {
    case Precalculation, PlayerAction, ServerUpdate,
    StartMovesExecution, MovesExecution, ActionsExecution, PostExecution
}

class GameEngine {
    let catFactory = CatFactory()
    var state: GameState = GameState.Precalculation
    var player: Cat!
    private var grid: Grid<TileNode>!
    private var graph: Graph<TileNode>!
    private var allPlayerPositions: [String:TileNode] = [:]
    var reachableNodes: [Int:Node<TileNode>] = [:]
    var currentPlayerMoveToNode: TileNode!
    
    init(grid: Grid<TileNode>, graph: Graph<TileNode>) {
        self.grid = grid
        self.graph = graph
        addPlayers()
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
            state = GameState.ActionsExecution
        case .ActionsExecution:
            state = GameState.PostExecution
        case .PostExecution:
            state = GameState.Precalculation
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
        for doodad in currentPlayerNode.doodads {
            doodad.effect(player)
        }
        reachableNodes = graph.getNodesInRange(Node(currentPlayerNode), range: player.moveRange)
    }
    
    func postExecute() {
        player.postExecute()
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