import Foundation
import SpriteKit

/// Button for Actions.
///
/// Touch to select and unselect.
class SKDirectionButtonNode: SKNode {
    private var defaultTexture: SKTexture!
    private var activeTexture: SKTexture!
    private var buttons: [Direction:SKSpriteNode] = [:]
    private var selectedButton: SKSpriteNode?
    var selectedDirection: Direction?
    
    init(defaultButtonImage: String, activeButtonImage: String, size: CGSize,
        centerSize: CGSize, availableDirection: [Direction]) {
        
        super.init()
        
        self.defaultTexture = SKTexture(imageNamed: defaultButtonImage)
        self.activeTexture = SKTexture(imageNamed: activeButtonImage)
        
        for direction in availableDirection {
            var button = SKSpriteNode(texture: self.defaultTexture)
            button.size = size
            button.zRotation = SceneUtils.zRotation(direction)
            
            switch direction {
            case .Top:
                button.position = CGPoint(
                    x: 0,
                    y: CGFloat((centerSize.height + size.height) / 2.0)
                )
            case .Right:
                button.position = CGPoint(
                    x: CGFloat((centerSize.width + size.width) / 2.0),
                    y: 0
                )
            case .Bottom:
                button.position = CGPoint(
                    x: 0,
                    y: -CGFloat((centerSize.height + size.height) / 2.0)
                )
            case .Left:
                button.position = CGPoint(
                    x: -CGFloat((centerSize.width + size.width) / 2.0),
                    y: 0
                )
            default:
                break
            }
            
            buttons[direction] = button
            addChild(button)
        }
        
        userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectDirection(dir: Direction) {
        if selectedButton != nil {
            selectedButton!.texture = defaultTexture
        }

        if let button = buttons[dir] {
            button.texture = activeTexture
            selectedButton = button
            selectedDirection = dir
        }
    }

    func unselectDirection() {
        selectedDirection = nil

        if selectedButton != nil {
            selectedButton!.texture = defaultTexture
            selectedButton = nil
        }
    }
}
