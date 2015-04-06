/*
    The Doodad object
*/

import SpriteKit

class Doodad: TileEntity {
    
    private var dictionaryName = ""
    private var removed = false
    private var sprite: SKNode = SKSpriteNode(imageNamed: "Nala.png")
    
    func effect(cat: Cat) {
        // inheriting doodads to implement effect, if any.
    }
    
    func isRemoved() -> Bool {
        return removed
    }
    
    func setRemoved() {
        removed = true
    }
    
    func getSprite() -> SKNode {
        return sprite
    }
    
    func setSprite(sprite: SKNode) {
        self.sprite = sprite
    }
    
    func isVisible() -> Bool {
        // inheriting doodads to override.
        return true
    }
    
    func getName() -> String {
        return dictionaryName
    }
    
    func setName(newName: String) {
        dictionaryName = newName
    }
}