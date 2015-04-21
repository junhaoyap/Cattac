import Foundation
import SpriteKit

class SKPlayerInfoNode: SKNode, HpListener {
    private var player: Cat
    private var initialHp: Int

    private var informationLayer = SKNode()

    private var healthLabel: SKLabelNode
    private var healthBar: SKSpriteNode
    private var healthBarWidth: CGFloat = 190
    private var healthBarHeight: CGFloat = 25

    init(player: Cat, size: CGSize, playerName: String) {
        self.player = player
        self.initialHp = player.hp
        self.healthLabel = SKLabelNode(fontNamed: "BubblegumSans-Regular")
        self.healthBar = SKSpriteNode(imageNamed: "HealthBar.png")

        super.init()

        self.player.hpListener = self

        let name = SKLabelNode(text: playerName)
        name.fontName = "BubblegumSans-Regular"
        name.fontColor = UIColor.blackColor()
        name.fontSize = 20
        name.horizontalAlignmentMode = .Left
        name.verticalAlignmentMode = .Top
        name.position = CGPoint(x: -70, y: 20)
        addChild(name)

        let playerSprite = SKSpriteNode(imageNamed: player.spriteImage)
        playerSprite.size = CGSize(width: 50, height: 50)
        playerSprite.position = CGPoint(x: -100, y: 0)
        addChild(playerSprite)

        let healthBarBorder = SKSpriteNode(imageNamed: "HealthBarBorder.png")
        healthBarBorder.size = CGSize(width: healthBarWidth,
            height: healthBarHeight)
        healthBarBorder.anchorPoint = CGPoint(x: 0, y: 0)
        healthBarBorder.position = CGPoint(x: -70, y: -30)
        addChild(healthBarBorder)

        healthBar.size = CGSize(width: healthBarWidth, height: healthBarHeight)
        healthBar.anchorPoint = CGPoint(x: 0, y: 0)
        healthBar.position = CGPoint(x: 0, y: 0)
        healthBarBorder.addChild(healthBar)

        healthLabel.text = "\(initialHp)/\(initialHp)"
        healthLabel.fontColor = UIColor.blackColor()
        healthLabel.verticalAlignmentMode = .Center
        healthLabel.fontSize = 16
        healthLabel.position = CGPoint(x: healthBarWidth / 2,
            y: healthBarHeight / 2)
        healthLabel.zPosition = 10
        healthBarBorder.addChild(healthLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onHpUpdate(hp: Int) {
        if hp > 0 {
            let newWidth = CGFloat(hp) / CGFloat(initialHp)
            let shrink = SKAction.scaleXTo(newWidth, duration: 0.2)
            healthBar.runAction(shrink)
            healthLabel.text = "\(hp)/\(initialHp)"
        } else {
            let shrink = SKAction.scaleXTo(0, duration: 0.2)
            healthBar.runAction(shrink)
            healthLabel.text = "Dead"
        }
    }
}