
import SpriteKit

class FortressDoodad: Doodad {
    override func effect(cat: Cat) {
        
    }
    
    override func isVisible() -> Bool {
        return false
    }
    
    override func getSprite() -> SKNode {
        return SKLabelNode(text: "F")
    }
}