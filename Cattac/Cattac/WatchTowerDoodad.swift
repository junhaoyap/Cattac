
import SpriteKit

class WatchTowerDoodad: Doodad {
    let fartRangeModification = AttrModification(Constants.Doodad.watchTowerActionRangeModification, life: 1)
    
    init() {
        super.init(sprite: SKSpriteNode(imageNamed: "Tower.png"))
        setName(Constants.Doodad.watchTowerString)
    }
    
    override func postmoveEffect(cat: Cat) {
        cat.fartRangeMods += [fartRangeModification]
    }
    
    override func isVisible() -> Bool {
        return true
    }
}
