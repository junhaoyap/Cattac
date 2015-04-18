/*
    Cattac's Level Generator
*/
import Darwin
import SpriteKit

// simulate singleton behaviour
private let _levelGeneratorSharedInstance: LevelGenerator = LevelGenerator()

class LevelGenerator {
    
    let doodadFactory = DoodadFactory.sharedInstance
    
    private init() {
    }
    
    class var sharedInstance: LevelGenerator {
        return _levelGeneratorSharedInstance
    }
    
    func generateBasic() -> BasicLevel {
        let level = BasicLevel()
        
        constructLevel(level)
        
        generateDoodadAndWalls(level)
        
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
    
    private func getValidDoodadLocation(level: GameLevel) -> GridIndex {
        let maxCol = UInt32(level.numColumns)
        let maxRow = UInt32(level.numRows)
        
        var row = Int(arc4random_uniform(maxRow))
        var col = Int(arc4random_uniform(maxCol))
        
        var location = GridIndex(row, col)
        
        while contains(Constants.Level.invalidDoodadWallLocation, location) ||
            level.hasDoodad(atLocation: location) {
            
            row = Int(arc4random_uniform(maxRow))
            col = Int(arc4random_uniform(maxCol))
            location = GridIndex(row, col)
        }
        return location
    }
    
    private func generateDoodadAndWalls(level: GameLevel) {
        var wormholeCount = 0
        var excludedDoodads = [DoodadType]()
        
        for i in 0...level.numDoodads {
            var hasDoodadBeenAdded = false
            let doodad = doodadFactory.randomDoodad(excludedDoodads)
            let location = getValidDoodadLocation(level)
            let tileNode = level.addDoodad(doodad, atLocation: location)
            
            if doodad is WormholeDoodad {
                if ++wormholeCount >= Constants.Doodad.maxWormhole {
                    excludedDoodads += [.Wormhole]
                }
                
                let destDoodad = doodadFactory.createDoodad(.Wormhole)! as WormholeDoodad
                let destLocation = getValidDoodadLocation(level)
                let destTileNode = level.addDoodad(destDoodad, atLocation: destLocation)
                (doodad as WormholeDoodad).setDestination(destTileNode)
                destDoodad.setDestination(tileNode)
            }
        }
        
        for i in 0...level.numWalls {
            let doodad = doodadFactory.generateWall()
            let location = getValidDoodadLocation(level)
            let tileNode = level.addDoodad(doodad, atLocation: location)
            level.grid.removeNodeFromGraph(tileNode)
        }
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
            
            let tileNode = level.addDoodad(doodad, atLocation: GridIndex(doodadRow, doodadCol))
            
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