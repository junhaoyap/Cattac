/*
    Cattac's Level Generator
*/
import Darwin
import SpriteKit

// simulate singleton behaviour
private let _levelGeneratorSharedInstance: LevelGenerator = LevelGenerator()

class LevelGenerator {
    
    let doodadFactory = DoodadFactory.sharedInstance
    var levelToShare: GameLevel?
    
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
        
        generateDoodadAndWalls(level)
        
        levelToShare = level
        
        return level
    }
    
    private func generateDoodadAndWalls(level: GameLevel) {
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
    
    func createBasicGameFromDictionary(aDictionaryFromFirebase: [Int: String]) -> BasicLevel {
        let level = BasicLevel()
        
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                let tileNode = TileNode(row: row, column: column)
                level.grid[row, column] = tileNode
            }
        }
        
        level.constructGraph()
        
        for key in aDictionaryFromFirebase.keys {
            let row: Int = key / 10
            let col: Int = key % 10
            
            let location = GridIndex(row, col)
            
            if !(aDictionaryFromFirebase[key] == "") {
                // if the string we get from firebase is not empty then it has
                // a doodad
                
                let theDoodad = doodadFactory.createDoodad(aDictionaryFromFirebase[key]!)
                
                if theDoodad != nil {
                    level.addDoodad(theDoodad!, atLocation: location)
                } else {
                    println("jialat fail")
                }
            }
        }
        
        return level
    }
    
    // use only after the level has been generated
    func toDictionaryForFirebase() -> [String: String] {
        var theDictionary: [String: String] = [:]
        
        for i in 0...99 {
            let row: Int = i / 10
            let col: Int = i % 10
            
            let location = GridIndex(row, col)
            
            if levelToShare!.hasDoodad(atLocation: location) {
                theDictionary[String(i)] = levelToShare!.getDoodad(atLocation: location).getName()
            } else {
                theDictionary[String(i)] = ""
                // empty string signifies that the node is empty and should
                // be read that way when read from firebase
            }
        }
        
        return theDictionary
    }
    // later when we add in the lobby part and we want to try, 
    // we should generate this and throw it into firebase
}