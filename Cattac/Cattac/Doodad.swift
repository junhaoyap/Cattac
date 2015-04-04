/*
    The Doodad object
*/

import SpriteKit

class Doodad: TileEntity {
    
    private var removed = false
    
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
        // inheriting doodads to override.
        return SKSpriteNode(imageNamed: "Nala.png")
    }
    
    func isVisible() -> Bool {
        // inheriting doodads to override.
        return true
    }
}