/*
    `Graph` represents a graph (unsurprisingly!) More specifically, `Graph`
    should be able to represent the following graph types with corresponding
    constraints:
    - Undirected graph
    + An undirected edge is represented by 2 directed edges
    - Directed graph
    - Simple graph
    - Multigraph
    + Edges from the same source to the same destination should have
    different cost
    - Unweighted graph
    + Edges' weights are to set to 1.0
    - Weighted graph

    Hence, the representation invariants for every Graph g:
    - g is either directed or undirected
    - All nodes in g must have unique labels
    - Multiple edges from the same source to the same destination must
    not have the same weight

    Finally, just like `Node` and `Edge`, `Graph` is a generic type with a type
    parameter `T` that defines the type of the nodes' labels.
*/

class Graph<T: Hashable> {
    typealias N = Node<T>
    typealias E = Edge<T>
    
    let isDirected: Bool
    private var dictionaryOfNodes: [Int:N]
    private var dictionaryOfEdges: [Int:E]
    private var adjacencyList: [Int:[Int:[E]]]
    
    //  Construct a directed or undirected graph.
    init(isDirected: Bool) {
        self.isDirected = isDirected
        self.dictionaryOfNodes = [:]
        self.dictionaryOfEdges = [:]
        self.adjacencyList = [:]
        
        _checkRep()
    }
    
    func addNode(addedNode: N) {
        _checkRep()
        
        if !containsNode(addedNode) {
            let addedNodeHash = addedNode.hashValue
            dictionaryOfNodes[addedNodeHash] = addedNode
            adjacencyList[addedNodeHash] = [:]
        }
        
        _checkRep()
    }
    
    func removeNode(removedNode: N) {
        _checkRep()
        
        if containsNode(removedNode) {
            let removedNodeHash = removedNode.hashValue
            
            // Remove entry from dictionary of nodes
            dictionaryOfNodes.removeValueForKey(removedNodeHash)
            
            if isDirected {
                // Remove all edges that goes to the removed node
                for (nodeKey, _) in dictionaryOfNodes {
                    adjacencyList[nodeKey]!.removeValueForKey(removedNodeHash)
                }
            } else {
                // Remove all undirected edges for the removed node
                if let outgoingEdges = adjacencyList[removedNodeHash] {
                    for (_, edges) in outgoingEdges {
                        for edge in edges {
                            removeEdge(edge)
                        }
                    }
                }
            }
            
            // Remove adjacency list entry for the removed node
            adjacencyList.removeValueForKey(removedNodeHash)
        }
    
        _checkRep()
    }
    
    func containsNode(targetNode: N) -> Bool {
        _checkRep()
        
        if targetNode == dictionaryOfNodes[targetNode.hashValue] {
            return true
        } else {
            return false
        }
    }
    
    func addEdge(addedEdge: E) {
        _checkRep()
        
        func addDirectedEdge(edge: E, sourceNodeHash: Int, destNodeHash: Int) {
            if let sourceNodeEdges = adjacencyList[sourceNodeHash] {
                if sourceNodeEdges[destNodeHash] == nil {
                    adjacencyList[sourceNodeHash]![destNodeHash] = [edge]
                } else {
                    adjacencyList[sourceNodeHash]![destNodeHash]!.append(edge)
                }
            } else {
                let edges = [destNodeHash:[edge]]
                adjacencyList[sourceNodeHash] = edges
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
            addDirectedEdge(addedEdge, sourceNodeHash, destNodeHash)
            
            if !self.isDirected {
                addDirectedEdge(addedEdge.reverse(), destNodeHash, sourceNodeHash)
            }
        }
        
        _checkRep()
    }
    
    func removeEdge(removedEdge: E) {
        _checkRep()
        
        func removeDirectedEdge(edge: E, sourceNodeHash: Int, destNodeHash: Int) {
            if let edgesFromSourceNode = adjacencyList[sourceNodeHash] {
                let edgesFromSourceNodeToDestNode = edgesFromSourceNode[destNodeHash]!
                if edgesFromSourceNodeToDestNode.count > 1 {
                    adjacencyList[sourceNodeHash]![destNodeHash] =
                        edgesFromSourceNodeToDestNode.filter() { $0 != removedEdge }
                } else {
                    adjacencyList[sourceNodeHash]!.removeValueForKey(destNodeHash)
                }
            }
        }
        
        if containsEdge(removedEdge) {
            let sourceNode = removedEdge.getSource()
            let destNode = removedEdge.getDestination()
            
            let sourceNodeHash = sourceNode.hashValue
            let destNodeHash = destNode.hashValue
            
            dictionaryOfEdges.removeValueForKey(removedEdge.hashValue)
            removeDirectedEdge(removedEdge, sourceNodeHash, destNodeHash)
            
            if !self.isDirected {
                removeDirectedEdge(removedEdge.reverse(), destNodeHash, sourceNodeHash)
            }
        }
        
        _checkRep()
    }
    
    func containsEdge(targetEdge: E) -> Bool {
        _checkRep()
        
        if targetEdge == self.dictionaryOfEdges[targetEdge.hashValue] {
            return true
        } else {
            return false
        }
    }
    
    func edgesFromNode(fromNode: N, toNode: N) -> [E] {
        _checkRep()
        
        if let edgesFromSourceNode = adjacencyList[fromNode.hashValue] {
            if let edgesFromSourceNodeToDestNode = edgesFromSourceNode[toNode.hashValue] {
                return edgesFromSourceNodeToDestNode
            }
        }
        
        return []
    }
    
    func adjacentNodesFromNode(fromNode: N) -> [N] {
        _checkRep()
        
        var arrayToReturn = [N]()
        
        if let edgesFromSourceNode = adjacencyList[fromNode.hashValue] {
            for key in edgesFromSourceNode.keys {
                arrayToReturn.append(dictionaryOfNodes[key]!)
            }
        }
        
        return arrayToReturn
    }
    
    var nodes: [N] {
        return [N](self.dictionaryOfNodes.values)
    }
    
    var edges: [E] {
        return [E](self.dictionaryOfEdges.values)
    }
    
    private func _checkRep() {
        // disabling checks to reduce latency
        // assert(isDirected == true || isDirected == false, "A graph has to be either directed or undirected")
        //
        // assert(isLabelAllUnique() == true, "A graph G must have unique labels")
        //
        // assert(isEdgesAllUnique() == true, "If there are multiples edges from the same source to the same destination, then they cannot be of the same weight")
    }
    
    func isLabelAllUnique() -> Bool {
        var numberOfNodes: Int = nodes.count
        
        for var index = 0; index < numberOfNodes; index++ {
            var labelToCheck = nodes[index]
            
            for var innerIndex = index + 1; innerIndex < numberOfNodes; innerIndex++ {
                if labelToCheck == nodes[innerIndex] {
                    return false
                }
            }
        }
        
        return true
    }
    
    func isEdgesAllUnique() -> Bool {
        var numberOfEdges: Int = self.dictionaryOfEdges.count
        
        for var index = 0; index < numberOfEdges; index++ {
            var edgeToCheck = edges[index]
            
            for var innerIndex = index + 1; innerIndex < numberOfEdges; innerIndex++ {
                if edgeToCheck == edges[innerIndex] {
                    return false
                }
            }
        }
        
        return true
    }
    
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
                    if let nodeIndex = find(queue.map( { (node,_) -> N in
                        return node} ), destNode) {
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
            queue.sort() { (T1, T2) -> Bool in
                return T1.distance > T2.distance
            }
        }
        
        // Dijkstra's algorithm
        while !queue.isEmpty {
            var (node, distance) = queue.removeLast()
            if let edgesFromSourceNode = adjacencyList[node.hashValue] {
                for (_, edges) in edgesFromSourceNode {
                    for edge in edges {
                        relax(edge, distance)
                    }
                }
            }
        }
        
        var prevNode = toNode
        
        // Construct path
        while let edge = nodeInfo[prevNode.hashValue]!.incomingEdge {
            arrayToReturn.append(edge)
            prevNode = edge.getSource()
        }
        
        return arrayToReturn.reverse()
    }
    
    func getNodesInRange(fromNode: N, range: Int) -> [Int:N] {
        var nodes: [Int:N] = [:]
        var neighbours: [N] = []
        
        if range == 0 {
            return nodes
        }
        
        if let edgesFromSourceNode = adjacencyList[fromNode.hashValue] {
            for (destNodeHash, _) in edgesFromSourceNode {
                let node = dictionaryOfNodes[destNodeHash]!
                nodes[destNodeHash] = node
                neighbours.append(node)
            }
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
}