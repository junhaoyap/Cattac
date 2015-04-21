
import SpriteKit

class WormholeDoodad: Doodad {
    private var destinationTileNode: TileNode!
    private var _spriteNode: SKSpriteNode
    private let blueTexture = SKTexture(imageNamed: "WormholeBlue.png")
    private let orangeTexture = SKTexture(imageNamed: "WormholeOrange.png")

    init() {
        _spriteNode = SKSpriteNode()
        super.init(sprite: _spriteNode)
        setName(Constants.Doodad.wormholeString)
    }

    func setColor(wormholeCount: Int) {
        if wormholeCount % 2 == 0 {
            _spriteNode.texture = blueTexture
        } else {
            _spriteNode.texture = orangeTexture
        }
    }
    
    func setDestination(dest: TileNode) {
        destinationTileNode = dest
    }
    
    func getDestinationNode() -> TileNode {
        return destinationTileNode
    }
    
    override func postmoveEffect(cat: Cat) {
        // none, effect executed on game-engine, might need to change how players position is referenced
    }
    
    override func isVisible() -> Bool {
        return true
    }
}