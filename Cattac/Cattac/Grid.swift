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
    /// :returns: The TileNode with the given grid index or nil if it does not 
    ///           exist
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
    /// :returns: The TileNode with the given row and column or nil if it does
    ///           not exist
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
    /// :returns: The TileNode with the given row and column or nil if it does
    ///           not exist
    subscript(gridIndex: GridIndex, with offset: (row: Int, column: Int))
        -> TileNode? {
            return self[gridIndex.row + offset.row,
                gridIndex.col + offset.column]
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
    /// :param: range The range from the center node.
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

    /// Retrieves an array of dictionary of TileNodes that are reachable within
    /// the given range in all directions from the given TileNode. Each item in 
    /// the array represent the distance from the given TileNode.
    ///
    /// :param: fromNode The center TileNode to calculate the range from.
    /// :param: range The range from the center node.
    /// :returns: An array of dictionary of TileNodes that are within the range.
    func getNodesInRangeAllDirections(fromNode: TileNode, range: Int)
            -> [[Int:TileNode]] {
            var nodes: [[Int:TileNode]] = []
            let originRow = fromNode.position.row
            let originCol = fromNode.position.col
            var table: [Int:[Int:TileNode]] = [:]

            if range == 0 {
                return []
            }

            for _ in 0..<range {
                nodes.append([:])
            }

            for row in (originRow - range)...(originRow + range) {
                table[row] = [:]
            }

            table[originRow]![originCol] = fromNode

            for (dir, offset) in neighboursOffset {
                var currentNode = fromNode
                for layer in 0..<range {
                    let currentPosition = currentNode.position
                    let row = currentPosition.row + offset.row
                    let col = currentPosition.col + offset.column
                    if let node = self[row, col] {
                        if node.doodad == nil {
                            table[row]![col] = node
                            currentNode = node
                        } else if node.doodad!.getName() != "wall" {
                            table[row]![col] = node
                            currentNode = node
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
            }

            func addNodesInQuadrant(rowOffsetRange: [Int],
                colOffsetRange: [Int], checkOffset: (row: Int, col: Int)) {
                    for rowOffset in rowOffsetRange {
                        for colOffset in colOffsetRange {
                            let row = originRow + rowOffset
                            let col = originCol + colOffset
                            if table[row + checkOffset.row]![col] != nil &&
                                table[row]![col + checkOffset.col] != nil {
                                    if let node = self[row, col] {
                                        if node.doodad == nil {
                                            table[row]![col] = node
                                        } else if !(node.doodad is Wall) {
                                            table[row]![col] = node
                                        }
                                    }
                            }
                        }
                    }
            }

            for quadrant in 0..<4 {
                switch quadrant {
                case 0:
                    // top right quadrant
                    addNodesInQuadrant(Array(1...range), Array(1...range),
                        (row: -1, col: -1))
                case 1:
                    // top left quadrant
                    addNodesInQuadrant(Array(1...range), reverse(-range...(-1)),
                        (row: -1, col: 1))
                case 2:
                    // bottom left quadrant
                    addNodesInQuadrant(reverse(-range...(-1)),
                        reverse(-range...(-1)), (row: 1, col: 1))
                case 3:
                    // bottom right quadrant
                    addNodesInQuadrant(reverse(-range...(-1)), Array(1...range),
                        (row: 1, col: -1))
                default:
                    break
                }
            }

            for (rowNumber, row) in table {
                for colNumber in row.keys {
                    if rowNumber == originRow && colNumber == originCol {
                        continue
                    } else if let node = table[rowNumber]![colNumber] {
                        let rowDiff = abs(rowNumber - originRow)
                        let colDiff = abs(colNumber - originCol)
                        let layer = max(rowDiff, colDiff) - 1
                        nodes[layer][node.hashValue] = node
                    }
                }
            }
                
            while nodes.last != nil && nodes.last!.isEmpty {
                nodes.removeLast()
            }

            return nodes
    }

    /// Calculates the shortest path from one node to another.
    ///
    /// :param: fromNode The starting TileNode to be used to calculate the path.
    /// :param: toNode The ending TileNode to be used to calculate the path.
    /// :returns: An array of TileNodes that represents the shortest path. Empty 
    ///           if path does not exist.
    func shortestPathFromNode(fromNode: TileNode, toNode: TileNode)
        -> [TileNode] {
            var path = [TileNode]()

            for edge in graph.shortestPathFromNode(Node(fromNode),
                toNode: Node(toNode)) {
                    path.append(edge.getDestination().getLabel())
            }

            return path
    }
    
    /// Retrieve the largest empty region from a given origin node.
    ///
    /// :param: origin TileNode to check from
    /// :returns: Array of TileNodes representing the region
    func largestEmptyRegion(origin: TileNode) -> [TileNode] {
        var visitedNodes: [Int: TileNode] = [:]
        var enqueuedNodes: [TileNode] = []
        enqueuedNodes += [origin]
        while (enqueuedNodes.count > 0) {
            let checkNode = enqueuedNodes.removeLast()
            visitedNodes[checkNode.hashValue] = checkNode
            
            for neighbour in graph.adjacentNodesFromNode(Node(checkNode)) {
                let neighbourNode = neighbour.getLabel()
                if neighbourNode.doodad == nil
                    && visitedNodes[neighbourNode.hashValue] == nil
                    && !contains(enqueuedNodes, neighbourNode) {
                        enqueuedNodes += [neighbourNode]
                }
            }
        }
        return [TileNode] (visitedNodes.values)
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
                let edges = graph.edgesFromNode(Node(fromNode),
                    toNode: Node(toNode))
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