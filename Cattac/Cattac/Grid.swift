/// A Dictionary based square grid that stores all the tiles using GridIndex.
///
/// The Grid is designed to make it easy to retrieve TileNodes given the row
/// and column. It is able to perform calculations such as:
///
/// - Path between any two TileNodes
/// - All TileNodes within range of a given TileNode
/// - All available directions of a given TileNode
class Grid {

    /// The number of columns in the grid
    let columns: Int

    /// The number of rows in the grid
    let rows: Int

    private var tileNodes: [GridIndex:TileNode] = [:]
    private var graph: Graph<TileNode>
    
    /// Mapping of directions to the respective row and column offsets
    let neighboursOffset: [Direction:(row: Int, column: Int)] = [
        .Top: (1, 0),
        .Right: (0, 1),
        .Bottom: (-1, 0),
        .Left: (0, -1)
    ]

    /// Initialises the grid to the given rows and columns.
    ///
    /// The grid needs to have a graph constructed after setting all the
    /// tileNodes by calling `constructGraph()`, in order to utilize all the
    /// functionalities.
    ///
    /// :param: rows The number of rows in the grid
    /// :param: columns The number of columns in the grid
    init(rows: Int, columns: Int) {
        self.columns = columns
        self.rows = rows
        self.graph = Graph<TileNode>(isDirected: true)
    }

    /// TileNode with the given grid index.
    ///
    /// :param: gridIndex The GridIndex of the TileNode
    /// :returns: The TileNode with the given grid index or nil if it does not exist
    subscript(gridIndex: GridIndex) -> TileNode? {
        get {
            return tileNodes[gridIndex]
        }
        set {
            tileNodes[gridIndex] = newValue
        }
    }

    /// TileNode of the given row and column
    ///
    /// :throws: KeyError exception if trying to set to an invalid grid index
    ///
    /// :param: row The row index of the TileNode
    /// :param: column The column index of the TileNode
    /// :returns: The TileNode with the given row and column or nil if it does not exist
    subscript(row: Int, column: Int) -> TileNode? {
        get {
            if row >= rows || column >= columns || row < 0 || column < 0 {
                return nil
            }
            return tileNodes[GridIndex(row, column)]
        }
        set {
            if row >= rows || column >= columns || row < 0 || column < 0 {
                NSException(
                    name: "KeyError",
                    reason: "Unable to add to Grid[\(row), \(column)]",
                    userInfo: nil
                ).raise()
            }
            tileNodes[GridIndex(row, column)] = newValue
        }
    }

    /// TileNode with the given offset from the base TileNode of the given
    /// row and column.
    ///
    /// :throws: KeyError exception if trying to set to an invalid grid index
    ///
    /// :param: gridIndex The grid index of the base TileNode
    /// :param: offset The offset from the base TileNode
    /// :returns: The TileNode with the given row and column or nil if it does not exist
    subscript(gridIndex: GridIndex, with offset: (row: Int, column: Int))
        -> TileNode? {
            return self[gridIndex.row + offset.row, gridIndex.col + offset.column]
    }
    
    /// Constructs the inner graph data structure of the grid so as to utilise
    /// the advance functionalities.
    func constructGraph() {
        // Add all the nodes to the graph first
        for node in self {
            graph.addNode(Node(node))
        }
        
        // Adds the edges by finding the neighbours of each node
        for sourceNode in self {
            for (direction, offset) in neighboursOffset {
                if let destNode =
                    self[sourceNode.position, with: offset] {
                        graph.addEdge(Edge(source: Node(sourceNode),
                            destination: Node(destNode)))
                }
            }
        }
    }

    /// Removes a TileNode from the inner graph data structure, basically 
    /// TileNodes that you do not want to be reachable from the rest of the 
    /// TileNodes (stuff like TileNodes with walls)
    ///
    /// :param: removedNode The TileNode to be removed.
    func removeNodeFromGraph(removedNode: TileNode) {
        graph.removeNode(Node(removedNode))
    }

    /// Retrieves a Dictionary of TileNodes that are reachable within the given
    /// range from the given TileNode.
    ///
    /// :param: fromNode The center TileNode to calculate the range from.
    /// :returns: A Dictionary of TileNodes that are within range.
    func getNodesInRange(fromNode: TileNode, range: Int) -> [Int:TileNode] {
        var nodes: [Int:TileNode] = [:]
        var neighbours: [TileNode] = []
        
        if range == 0 {
            return nodes
        }

        // Add neighbours
        for node in graph.adjacentNodesFromNode(Node(fromNode)) {
            nodes[node.hashValue] = node.getLabel()
            neighbours.append(node.getLabel())
        }
        
        // Add neighbours of neighbours
        for node in neighbours {
            let nodeNeighbours = getNodesInRange(node, range: range - 1)
            for (hash, nodeNeighbour) in nodeNeighbours {
                // Only add those that has not been added
                if nodes[hash] == nil {
                    nodes[hash] = nodeNeighbour
                }
            }
        }
        
        return nodes
    }

    /// Calculates the shortest path from one node to another.
    ///
    /// :param: fromNode The starting TileNode to be used to calculate the path.
    /// :param: toNode The ending TileNode to be used to calculate the path.
    /// :returns: An array of TileNodes that represents the shortest path. Empty if path does not exist.
    func shortestPathFromNode(fromNode: TileNode, toNode: TileNode) -> [TileNode] {
        var path = [TileNode]()
        for edge in graph.shortestPathFromNode(Node(fromNode), toNode: Node(toNode)) {
            path.append(edge.getDestination().getLabel())
        }
        return path
    }

    /// Get all the available directions of a given TileNode. Available
    /// directions being directions where another reachable TileNode exists.
    ///
    /// :param: fromNode The TileNode to be used to find available directions.
    /// :returns: An array of available directions.
    func getAvailableDirections(fromNode: TileNode) -> [Direction] {
        var directions = [Direction]()
        
        for (dir, offset) in neighboursOffset {
            if let toNode = self[fromNode.position, with: offset] {
                let edges = graph.edgesFromNode(Node(fromNode), toNode: Node(toNode))
                if edges.count > 0 {
                    directions.append(dir)
                }
            }
        }
        
        return directions
    }
}

extension Grid: SequenceType {
    /// Generator for Grid to allow it to be iterable.
    ///
    /// :returns: A generator of TileNodes.
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
            return self.tileNodes[GridIndex(nextRow, nextColumn++)]
        }
    }
}