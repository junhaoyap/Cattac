
import SpriteKit

class FortressDoodad: Doodad {
    let defenceModification = AttrModification(Constants.Doodad.fortressDefenceModification, life: 1)
    
    override init() {
        super.init()
        setSprite(SKSpriteNode(imageNamed: "Fortress.png"))
        setName(Constants.Doodad.fortressString)
    }
    
    override func postmoveEffect(cat: Cat) {
        cat.defenceMods += [defenceModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
}