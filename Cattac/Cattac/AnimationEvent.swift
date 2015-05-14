import SpriteKit

/// Holds animations for use in GameScene
struct AnimationEvent {
    let sprite: SKNode
    let action: SKAction
    var completion: (()->())?
    
    init(_ sprite: SKNode, _ action: SKAction) {
        self.sprite = sprite
        self.action = action
    }

    init(_ sprite: SKNode, _ action: SKAction, completion: ()->()) {
        self.sprite = sprite
        self.action = action
        self.completion = completion
    }
}