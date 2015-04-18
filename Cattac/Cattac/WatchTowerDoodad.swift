
import SpriteKit

class WatchTowerDoodad: Doodad {
    let fartRangeModification = AttrModification(Constants.Doodad.watchTowerActionRangeModification, life: 1)
    
    override init() {
        super.init()
        setSprite(SKLabelNode(text: "T"))
        setName(Constants.Doodad.watchTowerString)
    }
    
    override func postmoveEffect(cat: Cat) {
        cat.fartRangeMods += [fartRangeModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
}
