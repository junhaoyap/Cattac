import SpriteKit

/// A set of utility functions that are used together with the game scene.
class SceneUtils {

    private let numRows: Int
    private let numColumns: Int
    private let windowWidth: CGFloat
    private let tileWidth: CGFloat
    private let tileHeight: CGFloat

    /// Initializes the class with information of the current scene.
    ///
    /// - parameter windowWidth: The width of the entire view.
    /// - parameter numRows: The number of rows for the game level.
    /// - parameter numColumns: The number of columns for the game level.
    init(windowWidth: CGFloat, numRows: Int, numColumns: Int) {
        self.numRows = numRows
        self.numColumns = numColumns
        self.windowWidth = windowWidth
        self.tileWidth = windowWidth / CGFloat(max(numRows, numColumns) + 2)
        self.tileHeight = self.tileWidth
    }

    /// The size of a single tile in the grid.
    var tileSize: CGSize {
        return CGSize(width: tileWidth, height: tileHeight)
    }

    /// The position for drawing the grid.
    ///
    /// - returns: The point to draw the layers (for spritekit, the origin of 
    ///           the layer lies on the bottom left of the layer)
    func getLayerPosition() -> CGPoint {
        let x = -tileWidth * CGFloat(numColumns) / 2
        let y = -tileHeight * CGFloat(numRows) / 2
        return CGPoint(x: x, y: y)
    }

    /// Gets the point for the grid index.
    ///
    /// - parameter gridIndex: The grid index given to calculate the point in the
    ///                   the view.
    /// - returns: The point for the grid index.
    func pointFor(gridIndex: GridIndex) -> CGPoint {
        return CGPoint(
            x: CGFloat(gridIndex.col) * tileWidth + tileWidth / 2,
            y: CGFloat(gridIndex.row) * tileHeight + tileHeight / 2)
    }

    /// Gets the `TileNode` that lies on the given location based on the grid
    /// of the game level.
    ///
    /// - parameter location: The point in the view to be used to retrieve the tile
    ///                  in the grid.
    /// - parameter grid: The grid of the game level.
    /// - returns: The `TileNode` that lies on the location point.
    func nodeForLocation(location: CGPoint, grid: Grid) -> TileNode? {
        let normalizedX = location.x + (CGFloat(numColumns)/2) * tileWidth
        let normalizedY = location.y + (CGFloat(numRows)/2) * tileHeight
        let col = Int(normalizedX / tileWidth)
        let row = Int(normalizedY / tileHeight)
        return grid[row, col]
    }
    
    /// Generates a SKAction that animates the traversal of TileNodes at
    /// given duration per TileNode
    ///
    /// - parameter path: TileNode sequence to be traversed
    /// - parameter dur: Duration of animation in seconds per tile
    /// - returns: SKAction holding the sequence
    func getTraverseAnim(path: [TileNode], _ dur: NSTimeInterval) -> SKAction {
        var pathSequence: [SKAction] = []
        for node in path {
            let action = SKAction.moveTo(node.sprite.position,
                duration: dur)
            pathSequence.append(action)
        }
        return SKAction.sequence(pathSequence)
    }
    
    /// Generates a SKAction that animates the spawning of an item
    ///
    /// - returns: SKAction holding the sequence
    func getSpawnItemAnimation() -> SKAction {
        let sequence = [
            SKAction.moveByX(0, y: 200, duration: 0),
            SKAction.moveByX(0, y: -200, duration: 0.3),
            SKAction.moveByX(0, y: 60, duration: 0.2),
            SKAction.moveByX(0, y: -60, duration: 0.15),
            SKAction.moveByX(0, y: 30, duration: 0.15),
            SKAction.moveByX(0, y: -30, duration: 0.1),
            SKAction.moveByX(0, y: 10, duration: 0.1),
            SKAction.moveByX(0, y: -10, duration: 0.05),
            SKAction.moveByX(0, y: 5, duration: 0.05),
            SKAction.moveByX(0, y: -5, duration: 0.05)
        ]
        return SKAction.sequence(sequence)
    }
    
    /// Generates a poop sprite node used to animate the Poop activation.
    ///
    /// - parameter position: Location to place the poop
    /// - returns: The SKSpriteNode
    func getPoopNode(at position: CGPoint) -> SKSpriteNode {
        let poopNode = SKSpriteNode(imageNamed: "Poop.png")
        poopNode.size = tileSize
        poopNode.position = position
        poopNode.zPosition = Constants.Z.poop
        return poopNode
    }
    
    /// Generates a poop sprite node used to preview poop location.
    ///
    /// - returns: The SKSpriteNode
    func getPoopPreviewNode() -> SKSpriteNode {
        let poopPreviewNode = SKSpriteNode(imageNamed: "Poop.png")
        poopPreviewNode.size = tileSize
        poopPreviewNode.alpha = 0.5
        poopPreviewNode.zPosition = Constants.Z.poopPreview
        return poopPreviewNode
    }
    
    /// Generates a fart sprite node used to animate the Fart attack.
    ///
    /// - parameter direction: The direction of PuiAction
    /// - returns: The SKSpriteNode
    func getFartNode(at position: CGPoint) -> SKSpriteNode {
        let fartNode = SKSpriteNode(imageNamed: "Fart.png")
        fartNode.size = CGSize(width: tileWidth / 4,
            height: tileHeight / 4)
        fartNode.position = position
        fartNode.zPosition = Constants.Z.fart
        fartNode.alpha = 0
        return fartNode
    }
    
    /// Generates a SKAction that enters with fadeIn, rotateIn, and scaleUp
    /// and exits with fadeOut, rotateOut, and scaleDown
    ///
    /// - parameter timeInterval: Delay before animation starts
    /// - returns: SKAction holding the sequence
    func getFartAnimation(timeInterval: NSTimeInterval) -> SKAction {
        let wait = SKAction.waitForDuration(timeInterval)
        
        let fadeIn = SKAction.fadeInWithDuration(0.5)
        let rotateIn = SKAction.rotateToAngle(CGFloat(M_PI / 4), duration: 0.5)
        let scaleUp = SKAction.scaleBy(2.0, duration: 0.5)
        
        let fadeOut = SKAction.fadeOutWithDuration(0.5)
        let rotateOut = SKAction.rotateToAngle(CGFloat(M_PI / 2), duration: 0.5)
        let scaleDown = SKAction.scaleBy(2.0, duration: 0.5)
        
        let entryGroup = SKAction.group([fadeIn, rotateIn, scaleUp])
        let exitGroup = SKAction.group([fadeOut, rotateOut, scaleDown])
        
        let sequence = [wait, entryGroup, exitGroup]
        
        return SKAction.sequence(sequence)
    }
    
    /// Generates a SKAction that animates the non-currentPlayers obtaining an
    /// item.
    ///
    /// - returns: SKAction holding the sequence
    func getObtainItemAnimation() -> SKAction {
        let moveDistance = tileSize.height
        let actionGroup = [
            SKAction.sequence([
                SKAction.moveByX(0, y: moveDistance, duration: 0.2),
                SKAction.moveByX(0, y: -moveDistance, duration: 0.3)
                ]),
            SKAction.scaleTo(0, duration: 0.5)
        ]
        return SKAction.group(actionGroup);
    }
    
    /// Generates a SKAction that animates the aggressive item use for
    /// player on game tile
    ///
    /// - returns: SKAction holding the sequence
    func getAggressiveItemUsedAnimation(displacement: CGVector) -> SKAction {
        let dur = getAnimDuration(displacement)
        let actionSequence = [
            SKAction.scaleTo(1, duration: 0),
            SKAction.waitForDuration(0.3),
            SKAction.moveBy(displacement, duration: dur),
            SKAction.waitForDuration(0.3),
            SKAction.fadeOutWithDuration(0.3)
        ]
        return SKAction.sequence(actionSequence)
    }
    
    /// Generates a SKAction that animates the passive item use for 
    /// player on game tile
    ///
    /// - returns: SKAction holding the sequence
    func getPassiveItemUsedAnimation() -> SKAction {
        let actionSequence = [
            SKAction.scaleTo(1, duration: 0),
            SKAction.scaleTo(1.5, duration: 0.3),
            SKAction.waitForDuration(0.3),
            SKAction.group([
                SKAction.moveByX(0, y: tileHeight, duration: 0.5),
                SKAction.fadeOutWithDuration(0.2)
                ])
        ]
        return SKAction.sequence(actionSequence)
    }
    
    /// Generates a spit sprite node that represents the Pui attack.
    ///
    /// - parameter direction: The direction of PuiAction
    /// - returns: The SKSpriteNode
    func getPuiNode(direction: Direction) -> SKSpriteNode {
        let puiNode = SKSpriteNode(imageNamed: "Pui.png")
        puiNode.size = tileSize
        puiNode.zRotation = SceneUtils.zRotation(direction)
        puiNode.zPosition = Constants.Z.pui
        return puiNode
    }
    
    /// Generates a floating text indicated the damage inflicted upon a player.
    ///
    /// - parameter dmg: The damage inflicted upon player
    /// - returns: The SKSpriteNode
    func getDamageLabelNode(dmg: Int) -> SKLabelNode {
        let sign = dmg > 0 ? "-" : "+"
        let damageNode = SKLabelNode(text: "\(sign)\(abs(dmg))")
        damageNode.alpha = 0
        damageNode.fontColor = dmg > 0 ? UIColor.redColor():UIColor.cyanColor()
        damageNode.fontName = "LuckiestGuy-Regular"
        damageNode.zPosition = Constants.Z.damage
        return damageNode
    }
    
    /// Generates a SKAction that animates floating number changed label.
    ///
    /// - returns: SKAction holding the sequence
    func getNumberChangeAnimation(distance: CGFloat) -> SKAction {
        let actionSequence = [
            SKAction.group([
                SKAction.fadeAlphaTo(1, duration: 0.25),
                SKAction.moveByX(0, y: distance, duration: 0.25)
            ]),
            SKAction.waitForDuration(0.5),
            SKAction.fadeAlphaTo(0, duration: 0.25)
        ]
        return SKAction.sequence(actionSequence)
    }

    /// Generates a SKAction that animates floating damage label.
    ///
    /// - returns: SKAction holding the sequence
    func getDamageLabelAnimation() -> SKAction {
        return getNumberChangeAnimation(tileHeight)
    }
    
    /// Generates a orange crosshair used for showing targeted player.
    ///
    /// - returns: The SKSpriteNode
    func getCrosshairNode() -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "Crosshairs.png")
        node.size = CGSize(width: tileSize.width * 1.5,
            height: tileSize.height * 1.5)
        node.zPosition = Constants.Z.targetCrosshair
        return node
    }
    
    /// Generates a orange arrow sprite used for attracting user attention.
    ///
    /// - parameter pointAt: Point to which the arrow will point at.
    /// - returns: The SKSpriteNode
    func getPlayerTargetableArrow(pointAt: CGPoint) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: "OrangeArrow.png")
        let offset = tileHeight * 1.2
        sprite.position = CGPointMake(pointAt.x, pointAt.y + offset)
        sprite.size = tileSize
        sprite.runAction(getFloatingAnimation())
        sprite.zPosition = Constants.Z.targetArrow
        
        return sprite
    }
    
    /// Generates a SKAction that animates the passive item use for
    /// player on game tile
    ///
    /// - returns: SKAction holding the sequence
    func getFloatingAnimation() -> SKAction {
        let offset = tileHeight * 0.6
        let actionSequence = [
            SKAction.moveByX(0, y: offset * 0.2, duration: 0.15),
            SKAction.moveByX(0, y: offset * 0.4, duration: 0.15),
            SKAction.moveByX(0, y: offset * 0.2, duration: 0.15),
            SKAction.moveByX(0, y: -offset * 0.2, duration: 0.15),
            SKAction.moveByX(0, y: -offset * 0.4, duration: 0.15),
            SKAction.moveByX(0, y: -offset * 0.2, duration: 0.15)
        ]
        let action = SKAction.sequence(actionSequence)
        return SKAction.repeatActionForever(action)
    }
    
    /// Returns the standard animation duration for animating object movement
    /// across game playing field
    ///
    /// - parameter source: Starting point of object movement
    /// - parameter dest: Ending point of object movement
    /// - returns: duraction
    func getAnimDuration(source: CGPoint, dest: CGPoint) -> NSTimeInterval {
        let v = self.dynamicType.vector(source, dest)
        return getAnimDuration(v)
    }
    
    /// Returns the standard animation duration for animating object movement
    /// across game playing field
    ///
    /// - parameter v: The displacement vector
    /// - returns: duraction
    func getAnimDuration(v: CGVector) -> NSTimeInterval {
        let dist = self.dynamicType.distance(v)
        return NSTimeInterval(dist / tileHeight * 0.08)
    }

    /// Calculates the amount of rotation for a given direction.
    ///
    /// - parameter dir: The direction used to calculate the rotation.
    /// - returns: The rotation in radians.
    class func zRotation(dir: Direction) -> CGFloat {
        switch dir {
        case .Right:
            return CGFloat(3 * M_PI / 2.0)
        case .Bottom:
            return CGFloat(M_PI)
        case .Left:
            return CGFloat(M_PI / 2.0)
        default:
            return 0
        }
    }
    
    /// Calculates the length given a vector.
    ///
    /// - parameter v: The vector used to calculate the length.
    /// - returns: vector length.
    class func distance(v: CGVector) -> CGFloat {
        return sqrt(v.dx * v.dx + v.dy * v.dy)
    }
    
    /// Calculates the vector between points a and b.
    ///
    /// - parameter source: Source point.
    /// - parameter dest: Destination point.
    /// - returns: calculated vector from source to dest.
    class func vector(source: CGPoint, _ dest: CGPoint) -> CGVector {
        return CGVectorMake(dest.x - source.x, dest.y - source.y)
    }
}
