/// A structure to encapsulate the row and column information of a TileNode.
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