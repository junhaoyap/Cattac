/*
    Cattac's game scene
*/

import SpriteKit

class GameScene: SKScene, GameStateListener {
    
    
    let gameEngine: GameEngine!
    private let level: GameLevel!
    
    private let tileSize: CGFloat!
    
    private let gameLayer = SKNode()
    private let tilesLayer = SKNode()
    private let entityLayer = SKNode()
    
    private var previewNode: SKSpriteNode!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        assertionFailure("Should not call this init, init with basic level please!")
    }
    
    init(_ size: CGSize, _ level: GameLevel) {
        super.init(size: size)
        
        self.level = level
        gameEngine = GameEngine(grid: level.grid, graph: level.graph)
        gameEngine.gameStateListener = self
        
        // Initialize tileSize based on the number of columns
        tileSize = size.width / CGFloat(level.numColumns + 2)
        
        // Sets the anchorpoint for the scene to be the center of the screen
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addChild(gameLayer)
        
        // position of the general grid layer
        let layerPosition = CGPoint(
            x: -tileSize * CGFloat(level.numColumns) / 2,
            y: -tileSize * CGFloat(level.numRows) / 2)

        // adds tilesLayer to the grid layer
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        // adds entityLayer to the grid layer
        entityLayer.position = layerPosition
        gameLayer.addChild(entityLayer)
        
        addTiles()
        addPlayers()
        
        previewNode = SKSpriteNode(imageNamed: "Nala.png")
        previewNode.size = CGSize(width: tileSize - 1, height: tileSize - 1)
        previewNode.alpha = 0.5
        entityLayer.addChild(previewNode)
        previewNode.hidden = true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)
            
            if let node = nodeForLocation(location) {
                if gameEngine.state == GameState.PlayerAction {
                    if gameEngine.reachableNodes[Node(node).hashValue] != nil {
                        gameEngine.currentPlayerMoveToNode = node
                        previewNode.position = pointFor(node.row, node.column)
                        previewNode.hidden = false
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)
            
            if let node = nodeForLocation(location) {
                if gameEngine.state == GameState.PlayerAction {
                    if gameEngine.reachableNodes[Node(node).hashValue] != nil {
                        gameEngine.currentPlayerMoveToNode = node
                        previewNode.position = pointFor(node.row, node.column)
                        previewNode.hidden = false
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    }
    
    override func update(currentTime: CFTimeInterval) {
        gameEngine.gameLoop()
    }
    
    private func pointFor(row: Int, _ column: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * tileSize + tileSize / 2,
            y: CGFloat(row) * tileSize + tileSize / 2)
    }
    
    private func nodeForLocation(location: CGPoint) -> TileNode? {
        let col = Int((location.x + 5 * tileSize) / tileSize) // rushed code
        let row = Int((location.y + 5 * tileSize) / tileSize) // rushed code
        return level.grid[row, col]
    }
    
    private func addTiles() {
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                if let tileNode = level.nodeAt(row, column) {
                    drawTile(tileNode)
                }
            }
        }
    }
    
    private func addPlayers() {
        let spriteNode = level.grid[gameEngine.player.position]!.sprite
        let playerNode = gameEngine.player.getSprite() as SKSpriteNode
        playerNode.size = spriteNode.size
        playerNode.position = spriteNode.position
        entityLayer.addChild(playerNode)
        
        for key in gameEngine.getAllPlayers().keys {
            let theCat = gameEngine.getAllPlayers()[key]!
            let spriteNodeCat = level.grid[theCat.position]!.sprite
            let playerNodeCat = theCat.getSprite() as SKSpriteNode
            playerNodeCat.size = spriteNodeCat.size
            playerNodeCat.position = spriteNodeCat.position
            entityLayer.addChild(playerNodeCat)
        }
    }

    private func drawTile(tileNode: TileNode) {
        let spriteNode = tileNode.sprite
        spriteNode.size = CGSize(width: tileSize, height: tileSize)
        spriteNode.position = pointFor(tileNode.row, tileNode.column)
        tilesLayer.addChild(spriteNode)
        
        if let doodad = tileNode.doodad {
            self.drawTileEntity(spriteNode, doodad)
        }
    }
    
    private func drawTileEntity(spriteNode: SKSpriteNode, _ tileEntity: TileEntity) {
        let entityNode = tileEntity.getSprite()
        if entityNode is SKSpriteNode {
            (entityNode as SKSpriteNode).size = spriteNode.size
        }
        if !tileEntity.isVisible() {
            entityNode.alpha = 0.5
        }
        entityNode.position = spriteNode.position
        entityLayer.addChild(entityNode)
    }
    
    private func movePlayer() {
        let path = gameEngine.pathTo(gameEngine.currentPlayerMoveToNode)
        var pathSequence: [SKAction] = []

        for edge in path {
            let destNode = edge.getDestination().getLabel()
            let action = SKAction.moveTo(destNode.sprite.position, duration: 0.25)
            pathSequence.append(action)
        }
        
        if pathSequence.count > 0 {
            gameEngine.player.getSprite().runAction(
                SKAction.sequence(pathSequence),
                completion: {
                    self.gameEngine.currentPlayerNode = self.gameEngine.currentPlayerMoveToNode
                    self.gameEngine.nextState()
                }
            )
        } else {
            gameEngine.nextState()
        }
        
    }
    
    private func performActions() {
        if let action = gameEngine.currentPlayerAction {
            println(action)
        }
        gameEngine.nextState()
    }
    
    func onStateUpdate(state: GameState) {
        switch state {
        case .Precalculation:
            break
        case .PlayerAction:
            deleteRemovedDoodads()
            highlightReachableNodes()
            break
        case .ServerUpdate:
            removeHighlights()
            break
        case .StartMovesExecution:
            gameEngine.nextState()
            previewNode.hidden = true
            movePlayer()
        case .MovesExecution:
            break
        case .StartActionsExecution:
            gameEngine.nextState()
            performActions()
        case .ActionsExecution:
            break
        case .PostExecution:
            break
        }
    }
    
    private func highlightReachableNodes() {
        for node in gameEngine.reachableNodes.values {
            node.getLabel().highlight()
        }
    }
    
    private func removeHighlights() {
        for node in gameEngine.reachableNodes.values {
            node.getLabel().unhighlight()
        }
    }
    
    private func deleteRemovedDoodads() {
        let removedSprites = gameEngine.removedDoodads.values.map {
            (doodad) -> SKNode in
            return doodad.getSprite()
        }
        entityLayer.removeChildrenInArray([SKNode](removedSprites))
        gameEngine.removedDoodads = [:]
    }
}
