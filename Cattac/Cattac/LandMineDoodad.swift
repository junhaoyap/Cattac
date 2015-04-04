
import SpriteKit

class LandMineDoodad: Doodad {
    
    var removed = false
    
    override func effect(cat: Cat) {
        cat.inflict(Constants.Doodad.landMineDamage)
    }
    
    override func isVisible() -> Bool {
        return false
    }
    
    override func getSprite() -> SKSpriteNode {
        return SKSpriteNode(imageNamed: "Grumpy.png")
    }
}