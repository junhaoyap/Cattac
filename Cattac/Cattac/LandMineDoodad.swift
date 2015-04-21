
import SpriteKit

class LandMineDoodad: Doodad {
    
    init() {
        super.init(sprite: SKSpriteNode(imageNamed: "Poop.png"))
        getSprite().zPosition = Constants.Z.backDoodad
        setName(Constants.Doodad.landMineString)
    }
    
    override func postmoveEffect(cat: Cat) {
        setRemoved()
    }
    
    override func isVisible() -> Bool {
        return false
    }
}