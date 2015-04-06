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
    
    //  func generate(LevelType, DoodadsMix, WhateverConfig) { ??? return profit }
    
    func generateBasic() -> BasicLevel {
        let level = BasicLevel()
        
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                let tileNode = TileNode(row: row, column: column)
                level.grid[row, column] = tileNode
            }
        }
        
        level.constructGraph()
        
        generateDoodad(level)
        
        return level
    }
    
    private func generateDoodad(level: GameLevel) {
        let maxCol = UInt32(level.numColumns)
        let maxRow = UInt32(level.numRows)
        
        for i in 0...level.numDoodads {
            var hasDoodadBeenAdded = false
            
            while !hasDoodadBeenAdded {
                let row = Int(arc4random_uniform(maxRow))
                let col = Int(arc4random_uniform(maxCol))
                let location = GridIndex(row, col)
                let doodad = doodadFactory.randomDoodad()
                
                if contains(Constants.Level.invalidDoodadWallLocation, location) ||
                    level.hasDoodad(atLocation: location) {
                        continue
                }
                
                
                level.addDoodad(doodad, atLocation: location)
                
                hasDoodadBeenAdded = true
            }
        }
        
        for i in 0...level.numWalls {
            var hasWallBeenAdded = false
            
            while !hasWallBeenAdded {
                let row = Int(arc4random_uniform(maxRow))
                let col = Int(arc4random_uniform(maxCol))
                let location = GridIndex(row, col)
                let doodad = doodadFactory.generateWall()
                
                if contains(Constants.Level.invalidDoodadWallLocation, location) ||
                    level.hasDoodad(atLocation: location) {
                        continue
                }
                
                let tileNode = level.addDoodad(doodad, atLocation:location)
                level.graph.removeNode((Node(tileNode)))
                
                hasWallBeenAdded = true
            }
        }
    }
}