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
    private var dictionaryOfNodes: Dictionary<Int, N>
    private var dictionaryOfEdges: Dictionary<Int, E>
    private var adjacencyList: Dictionary<Int, [E]>
    
    //  Construct a directed or undirected graph.
    init(isDirected: Bool) {
        self.isDirected = isDirected
        self.dictionaryOfNodes = Dictionary<Int, N>()
        self.dictionaryOfEdges = Dictionary<Int, E>()
        self.adjacencyList = Dictionary<Int, [E]>()
        
        _checkRep()
    }
    
    func addNode(addedNode: N) {
        _checkRep()
        
        if containsNode(addedNode) {
            //  do nothing
        } else {
            self.dictionaryOfNodes[addedNode.hashValue] = addedNode
            
            self.adjacencyList[addedNode.hashValue] = [E]()
        }
        
        _checkRep()
    }
    
    func removeNode(removedNode: N) {
        _checkRep()
        
        if !containsNode(removedNode) {
            //  do nothing
        } else {
            self.dictionaryOfNodes[removedNode.hashValue] = nil
            
            if let edgeList = self.adjacencyList[removedNode.hashValue] {
                for edge in edgeList {
                    removeEdge(edge)
                }
            }
            
            self.adjacencyList[removedNode.hashValue] = nil
        }
        
        _checkRep()
    }
    
    func containsNode(targetNode: N) -> Bool {
        _checkRep()
        
        if targetNode == self.dictionaryOfNodes[targetNode.hashValue] {
            return true
        } else {
            return false
        }
    }
    
    func addEdge(addedEdge: E) {
        _checkRep()
        
        if containsEdge(addedEdge) {
            //  do nothing
        } else {
            if !containsNode(addedEdge.getSource()) {
                addNode(addedEdge.getSource())
            }
            
            if !containsNode(addedEdge.getDestination()) {
                addNode(addedEdge.getDestination())
            }
            
            self.dictionaryOfEdges[addedEdge.hashValue] = addedEdge
            
            if let addedEdgeList = self.adjacencyList[addedEdge.getSource().hashValue] {
                self.adjacencyList[addedEdge.getSource().hashValue]!.append(addedEdge)
            } else {
                var newEdgeListToUse = [E]()
                
                newEdgeListToUse.append(addedEdge)
                self.adjacencyList[addedEdge.getSource().hashValue] = newEdgeListToUse
            }
            
            
            if !self.isDirected {
                var reversedAddedEdge = addedEdge.reverse()
                
                if containsEdge(reversedAddedEdge) {
                    //  do nothing
                } else {
                    dictionaryOfEdges[reversedAddedEdge.hashValue] = reversedAddedEdge
                    
                    if let reversedAddedEdgeList = self.adjacencyList[reversedAddedEdge.getSource().hashValue] {
                        self.adjacencyList[reversedAddedEdge.getSource().hashValue]!.append(reversedAddedEdge)
                    } else {
                        var newEdgeListToUse = [E]()
                        
                        newEdgeListToUse.append(reversedAddedEdge)
                        self.adjacencyList[reversedAddedEdge.getSource().hashValue] = newEdgeListToUse
                    }
                }
            }
        }
        
        _checkRep()
    }
    
    func removeEdge(removedEdge: E) {
        _checkRep()
        
        if !containsEdge(removedEdge) {
            //  do nothing
        } else {
            self.dictionaryOfEdges[removedEdge.hashValue] = nil
            
            var currentEdgeList1 = self.adjacencyList[removedEdge.getSource().hashValue]
            
            var indexToRemoveAt1 = -1
            
            if currentEdgeList1 != nil {
                for (index, edge) in enumerate(currentEdgeList1!) {
                    if edge == removedEdge {
                        indexToRemoveAt1 = index
                    }
                }
                
                if indexToRemoveAt1 != -1 {
                    currentEdgeList1!.removeAtIndex(indexToRemoveAt1)
                }
                
                if currentEdgeList1!.isEmpty {
                    self.adjacencyList[removedEdge.getSource().hashValue] = nil
                } else {
                    self.adjacencyList[removedEdge.getSource().hashValue] = currentEdgeList1
                }
            }
            
            if !self.isDirected {
                var reversedRemovedEdge = removedEdge.reverse()
                
                self.dictionaryOfEdges[reversedRemovedEdge.hashValue] = nil
                
                var currentEdgeList2 = self.adjacencyList[reversedRemovedEdge.getSource().hashValue]
                
                var indexToRemoveAt2 = -1
                
                if currentEdgeList2 != nil {
                    for (index, edge) in enumerate(currentEdgeList2!) {
                        if edge == removedEdge {
                            indexToRemoveAt2 = index
                        }
                    }
                    
                    if indexToRemoveAt2 != -1 {
                        currentEdgeList2!.removeAtIndex(indexToRemoveAt2)
                    }
                    
                    if currentEdgeList2!.isEmpty {
                        self.adjacencyList[reversedRemovedEdge.getSource().hashValue] = nil
                    } else {
                        self.adjacencyList[reversedRemovedEdge.getSource().hashValue] = currentEdgeList2
                    }
                }
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
        
        var arrayToReturn: [E] = [E]()
        
        if let edgeList = self.adjacencyList[fromNode.hashValue] {
            for edge in edgeList {
                if edge.getDestination() == toNode {
                    arrayToReturn.append(edge)
                }
            }
        }
        
        return arrayToReturn
    }
    
    func adjacentNodesFromNode(fromNode: N) -> [N] {
        _checkRep()
        
        var dictionaryOfVisitableNodes: Dictionary<Int, N> = Dictionary<Int, N>()
        
        if let edgeList = self.adjacencyList[fromNode.hashValue] {
            for edge in edgeList {
                if dictionaryOfVisitableNodes[edge.getDestination().hashValue] == nil {
                    dictionaryOfVisitableNodes[edge.getDestination().hashValue] = edge.getDestination()
                }
            }
        }
        
        var arrayToReturn: [N] = [N](dictionaryOfVisitableNodes.values)
        
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
        
        var visited: Dictionary<Int, Bool> = Dictionary<Int, Bool>()
        var sortedNodesToVisit: [(N, Double)] = [(N, Double)]()
        var distances: Dictionary<Int, Double> = Dictionary<Int, Double>()
        var prevEdge: Dictionary<Int, E> = Dictionary<Int, E>()
        var currentNode: N? = fromNode
        var currentNodeHashValue: Int? = currentNode!.hashValue
        
        distances[currentNode!.hashValue] = 0
        
        //  Relaxes from source to destination
        func relax(sourceNode: N, destinationNode: N) {
            if let edgeConnectingNodes = edgesFromNode(sourceNode, toNode: destinationNode).first {
                let destinationNodeHashValue: Int = destinationNode.hashValue
                let distanceToCurrentNode: Double = distances[currentNodeHashValue!]!
                let distanceToDestinationNode: Double? = distances[destinationNodeHashValue]
                let edgeConnectingNodesWeight: Double = edgeConnectingNodes.getWeight()
                
                if distanceToDestinationNode == nil {
                    distances[destinationNodeHashValue] = distanceToCurrentNode + edgeConnectingNodesWeight
                    prevEdge[destinationNodeHashValue] = edgeConnectingNodes
                } else {
                    if distanceToDestinationNode > distanceToCurrentNode + edgeConnectingNodesWeight {
                        distances[destinationNodeHashValue] = distanceToCurrentNode + edgeConnectingNodesWeight
                        prevEdge[destinationNodeHashValue] = edgeConnectingNodes
                    }
                }
            }
            
            visited[sourceNode.hashValue] = true
        }
        
        //  Helps insert a node with it's corresponding weight so far to keep the array sorted
        func insertNodeSorted(nodeToInsert: N, weightSoFar: Double) {
            var indexToInsertAt = 0
            
            if sortedNodesToVisit.isEmpty {
                sortedNodesToVisit.append((nodeToInsert, weightSoFar))
            } else {
                let numberOfNodesInsertedBefore = sortedNodesToVisit.count
                
                while indexToInsertAt < numberOfNodesInsertedBefore && sortedNodesToVisit[indexToInsertAt].1 > weightSoFar {
                    indexToInsertAt++
                }
                
                sortedNodesToVisit.insert((nodeToInsert, weightSoFar), atIndex: indexToInsertAt)
            }
        }
        
        while currentNode != nil {
            visited[currentNodeHashValue!] = true
            
            for nodeToRelax in adjacentNodesFromNode(currentNode!) {
                relax(currentNode!, nodeToRelax)
                
                if visited[nodeToRelax.hashValue] == nil {
                    insertNodeSorted(nodeToRelax, distances[nodeToRelax.hashValue]!)
                }
            }
            
            if sortedNodesToVisit.isEmpty {
                currentNode = nil
                currentNodeHashValue = nil
            } else {
                currentNode = sortedNodesToVisit.removeAtIndex(0).0
                currentNodeHashValue = currentNode!.hashValue
            }
        }
        
        if visited[toNode.hashValue] == nil {
            return [E]()
        } else {
            var nodeAt = toNode
            
            while nodeAt != fromNode {
                var edgeBackwards = prevEdge[nodeAt.hashValue]
                arrayToReturn.append(edgeBackwards!)
                nodeAt = edgeBackwards!.getSource()
            }
            
            return arrayToReturn.reverse()
        }
    }
}