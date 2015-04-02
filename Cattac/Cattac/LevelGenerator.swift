/*
    Cattac's Level Generator
*/
import Darwin
import SpriteKit

// simulate sington behaviour
private let _levelGeneratorSharedInstance: LevelGenerator = LevelGenerator()

class LevelGenerator {
    private let catFactory: CatFactory!
    
    private init() {
        catFactory = CatFactory()
    }
    
    class var sharedInstance: LevelGenerator {
        return _levelGeneratorSharedInstance
    }
    
    //  func generate(LevelType, DoodadsMix, WhateverConfig) { ??? return profit }
    
    func generateBasic() -> BasicLevel {
        let level = BasicLevel()
        
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                let tileNode = TileNode(column: column, row: row, nodeType: .Grass)
                tileNode.sprite = SKSpriteNode(imageNamed: "Grass.jpg")
                level.grid[column, row] = tileNode
            }
        }
        
        let maxCol = UInt32(level.numColumns)
        let maxRow = UInt32(level.numRows)
        
        level.addCat(catFactory.createCat(Constants.catName.nalaCat)!, Int(arc4random_uniform(maxCol)), Int(arc4random_uniform(maxRow)))
        
        return level
    }
}