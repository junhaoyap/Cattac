
import SpriteKit

class TrampolineDoodad: Doodad {
    let rangeModification = StatModification(Constants.Doodad.trampolineMoveRangeModification, life: 1)
    
    override func effect(cat: Cat) {
        cat.moveRangeMods += [rangeModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
    
    override func getSprite() -> SKNode {
        return SKLabelNode(text: "P")
    }
}
