/*
    Cattac's game scene
*/

import SpriteKit

class GameScene: SKScene {
    
    var level: BasicLevel!
    
    let tileSize: CGFloat!
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    
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
        
        addTiles()
    }
    
    private func pointForColumn(column: Int, _ row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * tileSize + tileSize / 2,
            y: CGFloat(row) * tileSize + tileSize / 2)
    }
    
    private func addTiles() {
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                let tileNode = SKSpriteNode(imageNamed: "Grass.jpg")
                tileNode.size = CGSize(width: tileSize - 1, height: tileSize - 1)
                tileNode.position = pointForColumn(column, row)
                tilesLayer.addChild(tileNode)
                let tileBorder = SKShapeNode(rectOfSize: tileNode.size)
                tileBorder.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                tileNode.addChild(tileBorder)
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
