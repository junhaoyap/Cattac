
import SpriteKit

class Wall: Doodad {
    
    override init() {
        super.init()
        setSprite(SKSpriteNode(imageNamed: "Rock.png"))
        setName(Constants.Doodad.wallString)
    }
    
    override func effect(cat: Cat) {
        // none, cats can not move onto walls
    }
    
    override func isVisible() -> Bool {
        return true
    }
}