
import SpriteKit

class LandMineDoodad: Doodad {
    override func effect(cat: Cat) {
        cat.inflict(Constants.Doodad.landMineDamage)
    }
    
    override func isVisible() -> Bool {
        return false
    }
    
    override func getSprite() -> SKNode {
        return SKLabelNode(text: "M")
    }
}