import SpriteKit

/// Holds animations for use in GameScene
struct AnimationEvent {
    let sprite: SKNode
    let action: SKAction
    
    init(_ sprite: SKNode, _ action: SKAction) {
        self.sprite = sprite
        self.action = action
    }
}