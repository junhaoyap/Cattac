/*
    Stores the representation of objects in the grid using the row
    and column as reference.
*/

class Grid {
    let columns: Int
    let rows: Int
    private var grid: [GridIndex:TileNode] = [:]
    private var graph: Graph<TileNode>
    
    let neighboursOffset: [String:(row: Int, column: Int)] = [
        "top direction": (1, 0),
        "right direction": (0, 1),
        "bottom direction": (-1, 0),
        "left direction": (0, -1)
    ]
    
    init(rows: Int, columns: Int) {
        self.columns = columns
        self.rows = rows
        self.graph = Graph<TileNode>(isDirected: true)
    }
    
    subscript(gridIndex: GridIndex) -> TileNode? {
        get {
            return grid[gridIndex]
        }
        set {
            grid[gridIndex] = newValue
        }
    }
    
    subscript(row: Int, column: Int) -> TileNode? {
        get {
            if row >= rows || column >= columns || row < 0 || column < 0 {
                return nil
            }
            return grid[GridIndex(row, column)]
        }
        set {
            if row >= rows || column >= columns || row < 0 || column < 0 {
                print("KeyError: Unable to add (row:\(row), column:\(column)) to grid")
            }
            grid[GridIndex(row, column)] = newValue
        }
    }
    
    subscript(row: Int, column: Int, with offset: (row: Int, column: Int)) -> TileNode? {
        return self[row + offset.row, column + offset.column]
    }
    
    func constructGraph() {
        // Add all the nodes to the graph first
        for node in self {
            graph.addNode(Node(node))
        }
        
        // Adds the edges by finding the neighbours of each node
        for sourceNode in self {
            for (direction, offset) in neighboursOffset {
                if let destNode = self[sourceNode.row, sourceNode.column, with: offset] {
                        graph.addEdge(Edge(source: Node(sourceNode), destination: Node(destNode)))
                }
            }
        }
    }
    
    func removeNodeFromGraph(removedNode: TileNode) {
        graph.removeNode(Node(removedNode))
    }
    
    func getNodesInRange(fromNode: TileNode, range: Int) -> [Int:TileNode] {
        var nodes: [Int:TileNode] = [:]
        var neighbours: [TileNode] = []
        
        if range == 0 {
            return nodes
        }
        
        for node in graph.adjacentNodesFromNode(Node(fromNode)) {
            nodes[node.hashValue] = node.getLabel()
            neighbours.append(node.getLabel())
        }
        
        // Add neighbours of neighbours
        for node in neighbours {
            let nodeNeighbours = getNodesInRange(node, range: range - 1)
            for (hash, nodeNeighbour) in nodeNeighbours {
                if nodes[hash] == nil {
                    nodes[hash] = nodeNeighbour
                }
            }
        }
        
        return nodes
    }
    
    func shortestPathFromNode(fromNode: TileNode, toNode: TileNode) -> [TileNode] {
        var path = [TileNode]()
        for edge in graph.shortestPathFromNode(Node(fromNode), toNode: Node(toNode)) {
            path.append(edge.getDestination().getLabel())
        }
        return path
    }
    
    func getAvailableDirections(fromNode: TileNode) -> [Direction] {
        var directions = [Direction]()
        
        for (dir, offset) in neighboursOffset {
            if let toNode = self[fromNode.row, fromNode.column, with: offset] {
                let edges = graph.edgesFromNode(Node(fromNode), toNode: Node(toNode))
                if edges.count > 0 {
                    directions.append(Direction.create(dir)!)
                }
            }
        }
        
        return directions
    }
}

extension Grid: SequenceType {
    func generate() -> GeneratorOf<TileNode> {
        var nextRow = 0
        var nextColumn = 0
        
        return GeneratorOf<TileNode> {
            if nextRow == self.rows && nextColumn == self.columns {
                return nil
            } else if nextColumn == self.columns {
                nextColumn = 0
                nextRow++
            }
            return self.grid[GridIndex(nextRow, nextColumn++)]
        }
    }
}

struct GridIndex {
    private var x: Int
    private var y: Int
    
    init(_ row: Int, _ col: Int) {
        self.x = row
        self.y = col
    }
    
    var row: Int {
        return self.x
    }
    
    var col: Int {
        return self.y
    }
}

extension GridIndex: Hashable {
    var hashValue: Int {
        get {
            return (UInt32(y) + UInt32(x) << 16).hashValue
        }
    }
}

func ==(lhs: GridIndex, rhs: GridIndex) -> Bool {
    return lhs.hashValue == rhs.hashValue
}