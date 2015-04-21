
import SpriteKit

class Wall: Doodad {
    
    init() {
        super.init(sprite: SKSpriteNode(imageNamed: "Rock.png"))
        setName(Constants.Doodad.wallString)
    }
    
    override func isVisible() -> Bool {
        return true
    }
}