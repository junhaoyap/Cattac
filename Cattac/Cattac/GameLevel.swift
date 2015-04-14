
class GameLevel {
    
    let numColumns: Int
    let numRows: Int
    var numDoodads: Int = Constants.Level.defaultDoodads
    var numWalls: Int = Constants.Level.defaultWalls
    
    var grid: Grid!
    
    var levelType: String {
        if self is BasicLevel {
            return "basic"
        } else if self is MediumLevel {
            return "medium"
        } else {
            return "hard"
        }
    }
    
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
    
    func compress() -> [String: AnyObject] {
        var levelData:[String: AnyObject] = [:]
        var entities: [[String: AnyObject]] = []
        levelData[Constants.Level.keyRows] = numRows
        levelData[Constants.Level.keyCols] = numColumns
        levelData[Constants.Level.keyType] = levelType
        
        for row in 0..<numRows {
            for col in 0..<numColumns {
                if let doodad = grid[row, col]!.doodad {
                    let doodadData = [
                        Constants.Level.keyEntityName: doodad.getName(),
                        Constants.Level.keyGridRow: row,
                        Constants.Level.keyGridCol: col
                    ] as [String: AnyObject]
                    
                    entities += [doodadData]
                }
            }
        }
        levelData[Constants.Level.keyEntities] = entities
        
        return levelData
        // later when we add in the lobby part and we want to try,
        // we should generate this and throw it into firebase
    }
}