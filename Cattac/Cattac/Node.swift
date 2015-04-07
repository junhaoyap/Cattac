/// `Node` represents a vertex in a graph. `Node` is a generic type
/// with a type parameter `T` that is the type of the node's label.
/// For example, `Node<String>` is the type of nodes with a String label
/// and `Node<Int>` is the type of nodes with a Int Label.
///
/// Because we need to compare the node label and store them in a dictionary, 
/// the type parameter `T` needs to conform to `Hashable` protocol.
struct Node<T: Hashable> {
    private var label: T

    init(_ label: T) {
        self.label = label
    }
}


extension Node: Hashable {
    var hashValue: Int {
        return self.label.hashValue
    }

    func getLabel() -> T {
        return self.label
    }
}


//  Return true if `lhs` node is equal to `rhs` node.
func ==<T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
    return lhs.label == rhs.label
}