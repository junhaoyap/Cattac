/*
    Cattac's Game Engine
*/

import Foundation

enum GameState {
    case PlayerAction, ServerUpdate, MovesExecution
}

class GameEngine {
    let catFactory = CatFactory()
    var state: GameState = GameState.PlayerAction
    private var grid: Grid<TileNode>!
    private var graph: Graph<TileNode>!
    private var allPlayerPositions: [String:TileNode] = [:]
    var player: Cat!
    
    init(grid: Grid<TileNode>, graph: Graph<TileNode>) {
        self.grid = grid
        self.graph = graph
        addPlayers()
    }
    
    func gameLoop() {
        switch state {
        case GameState.PlayerAction:
            break
        case GameState.ServerUpdate:
            // Goes to next state for now
            nextState()
        case GameState.MovesExecution:
            break
        }
    }
    
    func nextState() -> GameState {
        switch state {
        case GameState.PlayerAction:
            return GameState.ServerUpdate
        case GameState.ServerUpdate:
            return GameState.MovesExecution
        case GameState.MovesExecution:
            return GameState.PlayerAction
        }
    }
    
    func pathTo(node: TileNode) -> [Edge<TileNode>] {
        let fromNode = allPlayerPositions[player.name]!
        let edges = graph.shortestPathFromNode(Node(fromNode), toNode: Node(node))
        allPlayerPositions[player.name] = node
        return edges
    }
    
    private func addPlayers() {
        let cat = catFactory.createCat(Constants.catName.nalaCat)!
        grid[0,0]!.occupants.append(cat)
        allPlayerPositions[cat.name] = grid[0,0]!
        player = cat
    }
}