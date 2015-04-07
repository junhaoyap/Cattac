
class GameLevel {
    
    let numColumns: Int
    let numRows: Int
    var numDoodads: Int = Constants.Level.defaultDoodads
    var numWalls: Int = Constants.Level.defaultWalls
    
    var grid: Grid!
    
    init(rows: Int, columns: Int) {
        numColumns = columns
        numRows = rows
        grid = Grid(rows: numRows, columns: numColumns)
    }
    
    func nodeAt(row: Int, _ column: Int) -> TileNode? {
        assert(column >= 0 && column < numColumns)
        assert(row >= 0 && row < numRows)
        return grid[row, column]
    }
    
    func addDoodad(doodad: Doodad, atLocation gridIndex: GridIndex) -> TileNode {
        var tileNode = grid[gridIndex]!
        tileNode.setDoodad(doodad)
        return tileNode
    }
    
    func hasDoodad(atLocation gridIndex: GridIndex) -> Bool {
        return grid[gridIndex]!.tileHasDoodad()
    }
    
    func getDoodad(atLocation gridIndex: GridIndex) -> Doodad {
        return grid[gridIndex]!.doodad!
    }
}