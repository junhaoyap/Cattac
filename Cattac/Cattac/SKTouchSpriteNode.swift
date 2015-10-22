import SpriteKit

class SKTouchSpriteNode: SKSpriteNode {
    var touchBeganClosure: (() -> Void)?

    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTouchObserver(touchesBegan: (() -> Void)?) {
        touchBeganClosure = touchesBegan
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchBeganClosure?()
    }
}