
class GameLevel {
    
    let numColumns: Int
    let numRows: Int
    var numDoodads: Int = Constants.Level.defaultDoodads
    var numWalls: Int = Constants.Level.defaultWalls
    var numItems: Int = Constants.Level.defaultItems
    
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
    
    func nodeAt(location: GridIndex) -> TileNode? {
        return nodeAt(location.row, location.col)
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
                    var doodadData: [String: AnyObject] = [:]
                    
                    doodadData[Constants.Level.keyEntityName] = doodad.getName()
                    doodadData[Constants.Level.keyEntityType] = Constants.Level.valueDoodadType
                    doodadData[Constants.Level.keyGridRow] = row
                    doodadData[Constants.Level.keyGridCol] = col
                    
                    if doodad is WormholeDoodad {
                        let destTileNode = (doodad as! WormholeDoodad).getDestinationNode()
                        doodadData[Constants.Level.keyWormholeDestNode] = [
                            Constants.Level.keyGridRow: destTileNode.position.row,
                            Constants.Level.keyGridCol: destTileNode.position.col
                            ] as [String: AnyObject]
                    }
                    
                    entities += [doodadData]
                }
                
                if let item = grid[row, col]!.item {
                    var itemData: [String: AnyObject] = [:]
                    
                    itemData[Constants.Level.keyEntityName] = item.name
                    itemData[Constants.Level.keyEntityType] = Constants.Level.valueItemType
                    itemData[Constants.Level.keyGridCol] = col
                    itemData[Constants.Level.keyGridRow] = row
                    
                    entities += [itemData]
                }
            }
        }
        levelData[Constants.Level.keyEntities] = entities
        
        return levelData
    }
    
    func emptyTiles() -> [TileNode] {
        var emptyTiles: [TileNode] = []
        for tileNode in grid {
            if tileNode.doodad == nil {
                emptyTiles += [tileNode]
            }
        }
        return emptyTiles
    }
}