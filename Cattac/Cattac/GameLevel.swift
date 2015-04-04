
class GameLevel {
    
    let numColumns: Int
    let numRows: Int
    var numDoodads: Int = Constants.Level.defaultDoodads
    
    var grid: Grid<TileNode>!
    var graph: Graph<TileNode>!
    
    init(columns: Int, rows: Int) {
        numColumns = columns
        numRows = rows
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
    
    func nodeAt(column: Int, row: Int) -> TileNode? {
        assert(column >= 0 && column < numColumns)
        assert(row >= 0 && row < numRows)
        return grid[row, column]
    }
    
    func addDoodad(doodad: Doodad, atLocation gridIndex: GridIndex) {
        grid[gridIndex]!.setDoodad(doodad)
    }
}