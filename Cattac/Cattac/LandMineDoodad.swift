
import SpriteKit

class LandMineDoodad: Doodad {
    
    init() {
        super.init(sprite: SKLabelNode(text: "M"))
        getSprite().zPosition = Constants.Z.backDoodad
        setName(Constants.Doodad.landMineString)
    }
    
    override func postmoveEffect(cat: Cat) {
        cat.inflict(Constants.Doodad.landMineDamage)
        setRemoved()
    }
    
    override func isVisible() -> Bool {
        return false
    }
}