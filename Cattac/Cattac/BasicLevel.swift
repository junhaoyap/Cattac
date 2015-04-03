/*
    Cattac's Basic Level
*/

import Foundation

class BasicLevel {
    
    let numColumns = Constants.BasicLevel.numColumns
    let numRows = Constants.BasicLevel.numRows
    
    var grid: Grid<TileNode>!
    var graph: Graph<TileNode>!
    
    init() {
        grid = Grid<TileNode>(columns: numColumns, rows: numRows)
        graph = Graph(isDirected: true)
    }
    
    func constructGraph() {
        // Add all the nodes to the graph first
        for node in grid {
            graph.addNode(Node(node))
        }
        
        // Adds the edges by finding the neighbours of each node
        for sourceNode in grid {
            for (direction, offset) in grid.neighboursOffset {
                if let destNode = grid[sourceNode.row + offset.row,
                    sourceNode.column + offset.column] {
                        graph.addEdge(Edge(source: Node(sourceNode), destination: Node(destNode)))
                }
            }
        }
    }
    
    func nodeAtColumn(column: Int, row: Int) -> TileNode? {
        assert(column >= 0 && column < numColumns)
        assert(row >= 0 && row < numRows)
        return grid[row, column]
    }
}