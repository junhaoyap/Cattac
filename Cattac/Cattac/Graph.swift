/// `Graph` represents a graph (unsurprisingly!) More specifically, `Graph`
/// should be able to represent the following graph types with corresponding
/// constraints:
///
/// - Undirected graph
/// - An undirected edge is represented by 2 directed edges
/// - Directed graph
/// - Simple graph
/// - Multigraph
/// - Edges from the same source to the same destination should have different 
///   cost
/// - Unweighted graph
/// - Edges' weights are to set to 1.0
/// - Weighted graph
///
/// Hence, the representation invariants for every Graph g:
///
/// - g is either directed or undirected
/// - All nodes in g must have unique labels
/// - Multiple edges from the same source to the same destination must not have 
///   the same weight
///
/// Finally, just like `Node` and `Edge`, `Graph` is a generic type with a type
/// parameter `T` that defines the type of the nodes' labels.
///
class Graph<T: Hashable> {
    typealias N = Node<T>
    typealias E = Edge<T>

    /// Whether the graph is a directed or undirected graph.
    let isDirected: Bool

    /// A dictionary of all the nodes in the graph for fast retrieval of nodes.
    private var dictionaryOfNodes: [Int:N]

    /// A dictionary of all the edges in the graph for fast retrieval of edges.
    private var dictionaryOfEdges: [Int:E]

    /// Graph is represented using this matrix, each entry in this matrix will
    /// contain an array of different edges (i.e. different weights since they
    /// have the same source and destination node)
    private var matrix: [Int:[Int:[E]]]
    
    /// Constructs a directed or undirected graph.
    ///
    /// - parameter isDirected: Whether to construct a directed or undirected graph.
    init(isDirected: Bool) {
        self.isDirected = isDirected
        self.dictionaryOfNodes = [:]
        self.dictionaryOfEdges = [:]
        self.matrix = [:]
        
        _checkRep()
    }

    /// Adds a node into the graph.
    ///
    /// - parameter addedNode: The node to be added.
    func addNode(addedNode: N) {
        _checkRep()
        
        if !containsNode(addedNode) {
            let addedNodeHash = addedNode.hashValue
            dictionaryOfNodes[addedNodeHash] = addedNode
            matrix[addedNodeHash] = [:]
        }
        
        _checkRep()
    }

    /// Removes a node from the graph and all its incoming and outgoing edges.
    ///
    /// - parameter removedNode: The node to be removed.
    func removeNode(removedNode: N) {
        _checkRep()
        
        if containsNode(removedNode) {
            let removedNodeHash = removedNode.hashValue
            
            // Remove entry from dictionary of nodes
            dictionaryOfNodes.removeValueForKey(removedNodeHash)
            
            if isDirected {
                // Remove all edges that goes to the removed node
                for (nodeKey, _) in dictionaryOfNodes {
                    matrix[nodeKey]!.removeValueForKey(removedNodeHash)
                }
            } else {
                // Remove all undirected edges for the removed node
                if let outgoingEdges = matrix[removedNodeHash] {
                    for (_, edges) in outgoingEdges {
                        for edge in edges {
                            removeEdge(edge)
                        }
                    }
                }
            }
            
            // Remove adjacency list entry for the removed node
            matrix.removeValueForKey(removedNodeHash)
        }
    
        _checkRep()
    }

    /// Checks whether the node exists in the graph.
    ///
    /// - parameter targetNode: The node to check.
    /// - returns: true if it exists, false if it doesn't.
    func containsNode(targetNode: N) -> Bool {
        _checkRep()
        
        if targetNode == dictionaryOfNodes[targetNode.hashValue] {
            return true
        } else {
            return false
        }
    }

    /// Adds an edge into the graph. Creates the source and destination nodes
    /// if they do not exist.
    ///
    /// - parameter addedEdge: The edge to be added.
    func addEdge(addedEdge: E) {
        _checkRep()

        /// Adds a directed edge into the graph.
        func addDirectedEdge(edge: E, sourceNodeHash: Int, destNodeHash: Int) {
            if let sourceNodeEdges = matrix[sourceNodeHash] {
                if sourceNodeEdges[destNodeHash] == nil {
                    matrix[sourceNodeHash]![destNodeHash] = [edge]
                } else {
                    matrix[sourceNodeHash]![destNodeHash]!.append(edge)
                }
            } else {
                let edges = [destNodeHash:[edge]]
                matrix[sourceNodeHash] = edges
            }
        }
        
        if !containsEdge(addedEdge) {
            let sourceNode = addedEdge.getSource()
            let destNode = addedEdge.getDestination()
            
            let sourceNodeHash = sourceNode.hashValue
            let destNodeHash = destNode.hashValue
            
            if !containsNode(sourceNode) {
                addNode(sourceNode)
            }
            
            if !containsNode(destNode) {
                addNode(destNode)
            }
            
            dictionaryOfEdges[addedEdge.hashValue] = addedEdge
            addDirectedEdge(addedEdge, sourceNodeHash: sourceNodeHash, destNodeHash: destNodeHash)
            
            if !self.isDirected {
                let reversedEdge = addedEdge.reverse()
                dictionaryOfEdges[reversedEdge.hashValue] = reversedEdge
                addDirectedEdge(reversedEdge, sourceNodeHash: destNodeHash, destNodeHash: sourceNodeHash)
            }
        }
        
        _checkRep()
    }

    /// Removes an edge from the graph.
    ///
    /// - parameter removedEdge: The edge to be removed.
    func removeEdge(removedEdge: E) {
        _checkRep()

        /// Removes an directed edge from the graph.
        func removeDirectedEdge(edge: E, source: Int, dest: Int) {
            if let edgesFromSourceNode = matrix[source] {
                let edgesFromSourceNodeToDestNode = edgesFromSourceNode[dest]!

                if edgesFromSourceNodeToDestNode.count > 1 {
                    matrix[source]![dest] =
                        edgesFromSourceNodeToDestNode.filter() {
                            $0 != removedEdge
                        }
                } else {
                    matrix[source]!.removeValueForKey(dest)
                }
            }
        }
        
        if containsEdge(removedEdge) {
            let sourceNode = removedEdge.getSource()
            let destNode = removedEdge.getDestination()
            
            let sourceNodeHash = sourceNode.hashValue
            let destNodeHash = destNode.hashValue
            
            dictionaryOfEdges.removeValueForKey(removedEdge.hashValue)
            removeDirectedEdge(removedEdge, source: sourceNodeHash, dest: destNodeHash)
            
            if !self.isDirected {
                let reversedEdge = removedEdge.reverse()
                dictionaryOfEdges.removeValueForKey(reversedEdge.hashValue)
                removeDirectedEdge(reversedEdge, source: destNodeHash, dest: sourceNodeHash)
            }
        }
        
        _checkRep()
    }

    /// Checks whether the edge exists in the graph.
    ///
    /// - parameter targetEdge: The edge to check.
    /// - returns: true if it exists, false if it doesn't.
    func containsEdge(targetEdge: E) -> Bool {
        _checkRep()
        
        if targetEdge == self.dictionaryOfEdges[targetEdge.hashValue] {
            return true
        } else {
            return false
        }
    }

    /// Retrieves all edges that points from the fromNode to toNode.
    ///
    /// - parameter fromNode: The source node of the edges.
    /// - parameter toNode: The destination node of the edges.
    /// - returns: An array of edges, empty if none found.
    func edgesFromNode(fromNode: N, toNode: N) -> [E] {
        _checkRep()

        // Retrieve from matrix.
        if let edgesFromSourceNode = matrix[fromNode.hashValue] {
            if let edgesFromSourceNodeToDestNode =
                edgesFromSourceNode[toNode.hashValue] {
                    return edgesFromSourceNodeToDestNode
            }
        }
        
        return []
    }

    /// Retrieves all neighbours of the given node.
    ///
    /// - parameter fromNode: The node to grab neighbours from.
    /// - returns: An array of nodes, empty if none found.
    func adjacentNodesFromNode(fromNode: N) -> [N] {
        _checkRep()
        
        var arrayToReturn = [N]()

        // Retrieve from matrix.
        if let edgesFromSourceNode = matrix[fromNode.hashValue] {
            for key in edgesFromSourceNode.keys {
                arrayToReturn.append(dictionaryOfNodes[key]!)
            }
        }
        
        return arrayToReturn
    }

    /// An array of all the nodes in the graph.
    var nodes: [N] {
        return [N](self.dictionaryOfNodes.values)
    }

    /// An array of all the edges in the graph.
    var edges: [E] {
        return [E](self.dictionaryOfEdges.values)
    }

    /// Disabled to improve performance.
    private func _checkRep() {
//         assert(isDirected == true || isDirected == false,
//            "A graph has to be either directed or undirected")
//        
//         assert(isLabelAllUnique() == true,
//            "A graph G must have unique labels")
//        
//         assert(isEdgesAllUnique() == true,
//            "If there are multiples edges from the same source to the same " +
//            "destination, then they cannot be of the same weight")
    }
    
    func isLabelAllUnique() -> Bool {
        let numberOfNodes: Int = nodes.count
        
        for var index = 0; index < numberOfNodes; index++ {
            let labelToCheck = nodes[index]
            
            for var innerIndex = index + 1; innerIndex < numberOfNodes;
                innerIndex++ {
                    if labelToCheck == nodes[innerIndex] {
                        return false
                    }
            }
        }
        
        return true
    }
    
    func isEdgesAllUnique() -> Bool {
        let numberOfEdges: Int = self.dictionaryOfEdges.count
        
        for var index = 0; index < numberOfEdges; index++ {
            let edgeToCheck = edges[index]
            
            for var innerIndex = index + 1; innerIndex < numberOfEdges;
                innerIndex++ {
                    if edgeToCheck == edges[innerIndex] {
                        return false
                    }
            }
        }
        
        return true
    }

    /// Find the shortest path from fromNode to toNode.
    ///
    /// - parameter fromNode: The starting node for the path.
    /// - parameter toNode: The ending node for the path.
    /// - returns: An array of edges that forms the shortest path, empty if path
    ///           not found.
    func shortestPathFromNode(fromNode: N, toNode: N) -> [E] {
        _checkRep()
        
        var arrayToReturn: [E] = [E]()
        
        // The shortest path function uses Dijkstra's Algorithm, the priority 
        // queue is simply a sorted array here. It will need to be implemented 
        // properly in the future to improve the performance of the algorithm.
        var queue: [(node: N, distance: Double)] = [(fromNode, 0)]
        var nodeInfo: [Int:(incomingEdge: E?, distance: Double)] = [:]
        
        nodeInfo[fromNode.hashValue] = (incomingEdge: nil, distance: 0)
        
        func relax(edge: E, sourceNodeDistance: Double) {
            let destNode = edge.getDestination()
            let destNodeHash = destNode.hashValue
            
            // Calculate the new estimate to destination node using this edge
            let estimateDistance = sourceNodeDistance + edge.getWeight()
            
            if let destNodeInfo = nodeInfo[destNodeHash] {
                // Updates the entry in the queue if the new estimated distance
                // exists and is shorter than the existing estimate
                let destNodeDistance = destNodeInfo.distance
                if estimateDistance < destNodeDistance {
                    nodeInfo[destNodeHash] =
                        (incomingEdge: edge, distance: estimateDistance)
                    
                    // Updates the existing queue entry by finding the queue
                    // index
                    if let nodeIndex = queue.map( { (node,_) -> N in
                        return node} ).indexOf(destNode) {
                        queue[nodeIndex].distance = estimateDistance
                    }
                }
            } else {
                // Add a new entry into the queue if there are no previous 
                // estimates for this destination node
                nodeInfo[destNodeHash] =
                    (incomingEdge: edge, distance: estimateDistance)
                queue.append(node: destNode, distance: estimateDistance)
                
            }
            
            // The priority queue must be sorted at all times.
            // It is in descending order to make it easy to extract the
            // smallest element by removing from the end
            queue.sortInPlace() { (T1, T2) -> Bool in
                return T1.distance > T2.distance
            }
        }
        
        // Dijkstra's algorithm
        while !queue.isEmpty {
            let (node, distance) = queue.removeLast()
            if let edgesFromSourceNode = matrix[node.hashValue] {
                for (_, edges) in edgesFromSourceNode {
                    for edge in edges {
                        relax(edge, sourceNodeDistance: distance)
                    }
                }
            }
        }

        // Adds the edges only if a path to toNode is found
        if nodeInfo[toNode.hashValue] != nil {
            var prevNode = toNode
            
            // Construct path
            while let edge = nodeInfo[prevNode.hashValue]!.incomingEdge {
                arrayToReturn.append(edge)
                prevNode = edge.getSource()
            }
        }
        
        return Array(arrayToReturn.reverse())
    }
}