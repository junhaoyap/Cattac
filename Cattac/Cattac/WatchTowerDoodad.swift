
import SpriteKit

class WatchTowerDoodad: Doodad {
    let fartRangeModification = StatModification(Constants.Doodad.watchTowerActionRangeModification, life: 1)
    
    override init() {
        super.init()
        setSprite(SKLabelNode(text: "T"))
    }
    
    override func effect(cat: Cat) {
        cat.fartRangeMods += [fartRangeModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
}
