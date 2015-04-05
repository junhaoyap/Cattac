
import SpriteKit

class FortressDoodad: Doodad {
    let defenceModification = StatModification(Constants.Doodad.fortressDefenceModification, life: 1)
    
    override init() {
        super.init()
        setSprite(SKLabelNode(text: "F"))
    }
    
    override func effect(cat: Cat) {
        cat.defenceMods += [defenceModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
}