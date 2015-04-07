
import SpriteKit

class WormholeDoodad: Doodad {
    private var destinationDoodad: WormholeDoodad!
    
    override init() {
        super.init()
        setSprite(SKLabelNode(text: "X"))
        setName(Constants.Doodad.wormholeString)
    }
    
    func setDestination(dest: WormholeDoodad) {
        destinationDoodad = dest
        dest.destinationDoodad = self
    }
    
    override func effect(cat: Cat) {
        // none, effect executed on game-engine, might need to change how players position is referenced
    }
    
    override func isVisible() -> Bool {
        return true
    }
}