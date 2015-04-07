
import SpriteKit

class WormholeDoodad: Doodad {
    private var destinationTileNode: TileNode!
    
    override init() {
        super.init()
        setSprite(SKLabelNode(text: "X"))
        setName(Constants.Doodad.wormholeString)
    }
    
    func setDestination(dest: TileNode) {
        destinationTileNode = dest
    }
    
    func getDestinationNode() -> TileNode {
        return destinationTileNode
    }
    
    override func effect(cat: Cat) {
        // none, effect executed on game-engine, might need to change how players position is referenced
    }
    
    override func isVisible() -> Bool {
        return true
    }
}