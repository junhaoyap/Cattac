
import SpriteKit

class TrampolineDoodad: Doodad {
    let rangeModification = AttrModification(Constants.Doodad.trampolineMoveRangeModification, life: 1)
    
    override init() {
        super.init()
        setSprite(SKSpriteNode(imageNamed: "Trampoline.png"))
        setName(Constants.Doodad.trampolineString)
    }
    
    override func premoveEffect(cat: Cat) {
        cat.moveRangeMods += [rangeModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
}
