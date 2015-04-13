
import SpriteKit

class TrampolineDoodad: Doodad {
    let rangeModification = AttrModification(Constants.Doodad.trampolineMoveRangeModification, life: 1)
    
    override init() {
        super.init()
        setSprite(SKLabelNode(text: "O"))
        setName(Constants.Doodad.trampolineString)
    }
    
    override func effect(cat: Cat) {
        cat.moveRangeMods += [rangeModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
}
