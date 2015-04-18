/*
    Cattac's Level Generator
*/
import Darwin
import SpriteKit

// simulate singleton behaviour
private let _levelGeneratorSharedInstance: LevelGenerator = LevelGenerator()

class LevelGenerator {
    
    let doodadFactory = DoodadFactory.sharedInstance
    let itemFactory = ItemFactory.sharedInstance
    
    private init() {
    }
    
    class var sharedInstance: LevelGenerator {
        return _levelGeneratorSharedInstance
    }
    
    func generateBasic() -> BasicLevel {
        let level = BasicLevel()
        
        constructLevel(level)
        
        generateDoodad(level)
        generateWalls(level)
        generateItems(level)
        
        return level
    }
    
    private func constructLevel(level: GameLevel) {
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                let tileNode = TileNode(row: row, column: column)
                level.grid[row, column] = tileNode
            }
        }
        
        level.grid.constructGraph()
    }
    
    private func generateDoodad(level: GameLevel) {
        var wormholeCount = 0
        var excludedDoodads = [DoodadType]()
        
        for i in 0...level.numDoodads {
            var hasDoodadBeenAdded = false
            let doodad = doodadFactory.randomDoodad(excludedDoodads)
            let location = getValidEntityLocation(level)
            let tileNode = level.nodeAt(location)!
            tileNode.doodad = doodad
            
            if doodad is WormholeDoodad {
                if ++wormholeCount >= Constants.Doodad.maxWormhole {
                    excludedDoodads += [.Wormhole]
                }
                
                let destDoodad = doodadFactory.createDoodad(.Wormhole)! as WormholeDoodad
                let destLocation = getValidEntityLocation(level)
                let destTileNode = level.nodeAt(destLocation)!
                destTileNode.doodad = destDoodad
                
                (doodad as WormholeDoodad).setDestination(destTileNode)
                destDoodad.setDestination(tileNode)
            }
        }
    }
    
    private func generateWalls(level: GameLevel) {
        for i in 0...level.numWalls {
            let doodad = doodadFactory.generateWall()
            let location = getValidEntityLocation(level)
            let tileNode = level.nodeAt(location)!
            tileNode.doodad = doodad
            level.grid.removeNodeFromGraph(tileNode)
        }
    }
    
    private func generateItems(level: GameLevel) {
        for i in 0...level.numItems {
            let item = itemFactory.randomItem()
            let location = getValidEntityLocation(level)
            let tileNode = level.nodeAt(location.row, location.col)!
            tileNode.item = item
        }
    }
    
    private func getValidEntityLocation(level: GameLevel) -> GridIndex {
        let maxCol = UInt32(level.numColumns)
        let maxRow = UInt32(level.numRows)
        
        var row = Int(arc4random_uniform(maxRow))
        var col = Int(arc4random_uniform(maxCol))
        
        var location = GridIndex(row, col)
        
        while contains(Constants.Level.invalidDoodadWallLocation, location) ||
            level.nodeAt(location)?.doodad != nil {
            
            row = Int(arc4random_uniform(maxRow))
            col = Int(arc4random_uniform(maxCol))
            location = GridIndex(row, col)
        }
        return location
    }
    
    func createGame(fromSnapshot data: FDataSnapshot) -> GameLevel {
        var level: GameLevel!
        let rows = data.value.objectForKey(Constants.Level.keyRows)! as Int
        let cols = data.value.objectForKey(Constants.Level.keyCols)! as Int
        let type = data.value.objectForKey(Constants.Level.keyType)! as String
        
        if type == Constants.Level.valueTypeBasic {
            level = BasicLevel(rows: rows, columns: cols)
        } else if type == Constants.Level.valueTypeMedium {
            level = MediumLevel(rows: rows, columns: cols)
        } else {
            level = HardLevel(rows: rows, columns: cols)
        }
        
        constructLevel(level)
        
        let entitiesData = data.value.objectForKey(Constants.Level.keyEntities) as [[String: AnyObject]]
        
        for entityData in entitiesData {
            let doodadName = entityData[Constants.Level.keyEntityName]! as String
            let doodadRow = entityData[Constants.Level.keyGridRow]! as Int
            let doodadCol = entityData[Constants.Level.keyGridCol]! as Int
            let doodad = doodadFactory.createDoodad(doodadName)!
            
            let tileNode = level.nodeAt(doodadRow, doodadCol)!
            tileNode.doodad = doodad
            
            if doodad is WormholeDoodad {
                let destDoodadData = entityData[Constants.Level.keyWormholeDestNode]! as [String: AnyObject]
                let destDoodadRow = destDoodadData[Constants.Level.keyGridRow]! as Int
                let destDoodadCol = destDoodadData[Constants.Level.keyGridCol]! as Int
                
                let destTileNode = level.nodeAt(destDoodadRow, destDoodadCol)!
                
                (doodad as WormholeDoodad).setDestination(destTileNode)
            } else if doodad is Wall {
                level.grid.removeNodeFromGraph(tileNode)
            }
        }
        
        return level
    }
}