
import SpriteKit

class WatchTowerDoodad: Doodad {
    let actionRangeModification = StatModification(Constants.Doodad.watchTowerActionRangeModification, life: 1)
    
    override func effect(cat: Cat) {
        cat.actionRangeMods += [actionRangeModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
    
    override func getSprite() -> SKNode {
        return SKLabelNode(text: "T")
    }
}
