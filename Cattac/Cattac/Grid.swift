/*
    Stores the representation of objects in the grid using the row
    and column as reference.
*/

struct Grid<T> {
    let columns: Int
    let rows: Int
    private var grid: [GridIndex:T] = [:]
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
    }
    
    subscript(row: Int, column: Int) -> T? {
        get {
            if row >= rows || column >= columns || row < 0 || column < 0 {
                return nil
            }
            return grid[GridIndex(row, column)]
        }
        set {
            grid[GridIndex(row, column)] = newValue
        }
    }
}

struct GridIndex: Hashable {
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
    
    var hashValue: Int {
        get {
            return (UInt32(y) + UInt32(x) << 16).hashValue
        }
    }
}

func ==(lhs: GridIndex, rhs: GridIndex) -> Bool {
    return lhs.hashValue == rhs.hashValue
}