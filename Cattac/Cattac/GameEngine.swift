/*
    Cattac's Game Engine
*/

import Foundation

enum GameState {
    case Precalculation, PlayerAction, ServerUpdate, StartMovesExecution, MovesExecution, ActionsExecution
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
        case GameState.Precalculation:
            reachableNodes = graph.getNodesInRange(Node(currentPlayerNode), range: 2)
            nextState()
        case GameState.PlayerAction:
            break
        case GameState.ServerUpdate:
            // Goes to next state for now
            nextState()
        case GameState.StartMovesExecution:
            break
        case GameState.MovesExecution:
            break
        case GameState.ActionsExecution:
            nextState()
        }
    }
    
    func nextState() {
        switch state {
        case GameState.Precalculation:
            state = GameState.PlayerAction
        case GameState.PlayerAction:
            state = GameState.ServerUpdate
        case GameState.ServerUpdate:
            state = GameState.StartMovesExecution
        case GameState.StartMovesExecution:
            state = GameState.MovesExecution
        case GameState.MovesExecution:
            state = GameState.ActionsExecution
        case GameState.ActionsExecution:
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
    
    func pathTo(node: TileNode) -> [Edge<TileNode>] {
        let fromNode = allPlayerPositions[player.name]!
        let edges = graph.shortestPathFromNode(Node(fromNode), toNode: Node(node))
        currentPlayerNode = node
        return edges
    }
    
    private func addPlayers() {
        let cat = catFactory.createCat(Constants.catName.nalaCat)!
        grid[0,0]!.occupants.append(cat)
        allPlayerPositions[cat.name] = grid[0,0]!
        player = cat
        currentPlayerMoveToNode = currentPlayerNode
    }
}