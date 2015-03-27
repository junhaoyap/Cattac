/*
    Cattac's game scene
*/

import SpriteKit

class GameScene: SKScene {
    
    var level: BasicLevel!
    
    let tileSize: CGFloat!
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let entityLayer = SKNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        assertionFailure("Should not call this init, init with basic level please!")
    }
    
    init(_ size: CGSize, _ basicLevel: BasicLevel) {
        super.init(size: size)
        
        level = basicLevel
        
        tileSize = size.width / CGFloat(level.numColumns + 2)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -tileSize * CGFloat(level.numColumns) / 2,
            y: -tileSize * CGFloat(level.numRows) / 2)
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        entityLayer.position = layerPosition
        gameLayer.addChild(entityLayer)
        
        addTiles()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)
            
            if let node = nodeForLocation(location) {
                
                let action = SKAction.moveTo(node.sprite!.position, duration: 1)  //rushed code
                level.cats.first!.getSprite().runAction(action) //rushed code
            }
        }
    }
    
    private func pointForColumn(column: Int, _ row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * tileSize + tileSize / 2,
            y: CGFloat(row) * tileSize + tileSize / 2)
    }
    
    private func nodeForLocation(location: CGPoint) -> TileNode? {
        let col = Int((location.x + 5 * tileSize) / tileSize) // rushed code
        let row = Int((location.y + 5 * tileSize) / tileSize) // rushed code
        return level.nodes[col, row]
    }
    
    private func addTiles() {
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                if let tileNode = level.nodeAtColumn(column, row: row) {
                    drawTile(tileNode)
                }
            }
        }
    }
    
    private func drawTile(tileNode: TileNode) {
        let spriteNode = tileNode.sprite!
        spriteNode.size = CGSize(width: tileSize - 1, height: tileSize - 1)
        spriteNode.position = pointForColumn(tileNode.column, tileNode.row)
        tilesLayer.addChild(spriteNode)
        let spriteBorder = SKShapeNode(rectOfSize: spriteNode.size)
        spriteBorder.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        spriteNode.addChild(spriteBorder)
        
        if !tileNode.occupants.isEmpty {
            for entity in tileNode.occupants {
                self.drawTileEntity(spriteNode, entity)
            }
        }
    }
    
    private func drawTileEntity(spriteNode: SKSpriteNode, _ tileEntity: TileEntity) {
        let entityNode = tileEntity.getSprite()
        entityNode.size = spriteNode.size
        entityNode.position = spriteNode.position
        entityLayer.addChild(entityNode)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
