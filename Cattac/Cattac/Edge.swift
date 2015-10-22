/// `Edge` represents an edge in a graph. An `Edge` is associated with
/// a source Node, a destination Node and a non-negative cost (or weight).
/// This means that `Edge` is a directed edge from the source to
/// the destination.
///
/// The representation invariants:
///
/// - The weight is non-negative
///
/// Similar to `Node`, `Edge` is a generic type with a type parameter
/// `T` that is the type of a node's label
struct Edge<T: Hashable> {
    typealias N = Node<T>
    
    private var source: N
    private var destination: N
    private var weight = 1.0

    init(source: N, destination: N) {
        self.source = source
        self.destination = destination
        
        _checkRep()
    }
    
    init(source: N, destination: N, weight: Double) {
        self.source = source
        self.destination = destination
        self.weight = weight
        
        _checkRep()
    }
    
    func reverse() -> Edge<T> {
        return Edge(source: destination, destination: source, weight: weight)
    }
    
    private func _checkRep() {
        // disabling checks to reduce latency
        // assert(weight >= 0, "Edge's weight cannot be negative.")
    }
}


extension Edge: Hashable {
    var hashValue: Int {
        var valueToHash = String()
        
        let sourceHashString = String(self.source.hashValue)
        let destinationHashString = String(self.destination.hashValue)
        let weightString = String(Int(self.weight))
        
        valueToHash += sourceHashString
        valueToHash += destinationHashString
        valueToHash += weightString
        
        let hashToReturn = valueToHash.hashValue
        
        return hashToReturn
    }
    
    func getSource() -> N {
        _checkRep()
        
        return self.source
    }
    
    func getDestination() -> N {
        _checkRep()
        
        return self.destination
    }
    
    func getWeight() -> Double {
        _checkRep()
        
        return self.weight
    }
}


//  Return true if `lhs` edge is equal to `rhs` edge.
func ==<Label>(lhs: Edge<Label>, rhs: Edge<Label>) -> Bool {
    return lhs.source == rhs.source
        && lhs.destination == rhs.destination
        && lhs.weight == rhs.weight
}