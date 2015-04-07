/*
    Cattac's game scene
*/

import SpriteKit

class GameScene: SKScene, GameStateListener, ActionListener {
    
    
    let gameEngine: GameEngine!
    private let level: GameLevel!
    
    private let tileSize: CGFloat!
    
    private let gameLayer = SKNode()
    private let tilesLayer = SKNode()
    private let entityLayer = SKNode()
    
    private let buttonLayer = SKNode()
    
    private var puiButton: SKActionButtonNode!
    private var fartButton: SKActionButtonNode!
    private var poopButton: SKActionButtonNode!
    
    private var previewNode: SKSpriteNode!
    private var previewDirectionNodes: SKNode!
    
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
        gameEngine.actionListener = self
        
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
        
        buttonLayer.position = CGPoint(x: -220, y: layerPosition.y - 90)
        gameLayer.addChild(buttonLayer)
        
        puiButton = SKActionButtonNode(
            defaultButtonImage: "PuiButton.png",
            activeButtonImage: "PuiButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("puiButtonPressed") })
        puiButton.position = CGPoint(x: 0, y: 0)
        buttonLayer.addChild(puiButton)
        
        fartButton = SKActionButtonNode(
            defaultButtonImage: "FartButton.png",
            activeButtonImage: "FartButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("fartButtonPressed") })
        fartButton.position = CGPoint(x: 220, y: 0)
        buttonLayer.addChild(fartButton)
        
        poopButton = SKActionButtonNode(
            defaultButtonImage: "PoopButton.png",
            activeButtonImage: "PoopButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("poopButtonPressed") })
        poopButton.position = CGPoint(x: 440, y: 0)
        buttonLayer.addChild(poopButton)
        
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
        let path = gameEngine.getPlayerPath(gameEngine.player)
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
    
    private func animatePuiAction(action: PuiAction) {
        let startNode = gameEngine.currentPlayerMoveToNode
        let path = gameEngine.pathOfPui(startNode, direction: action.direction)
        var pathSequence: [SKAction] = []
        
        for node in path {
            let action = SKAction.moveTo(node.sprite.position, duration: 0.15)
            pathSequence.append(action)
        }
        
        let pui = SKSpriteNode(imageNamed: "Pui.png")
        pui.size = CGSize(width: tileSize, height: tileSize)
        pui.position = startNode.sprite.position
        
        switch action.direction {
        case .Right:
            pui.zRotation = CGFloat(3 * M_PI / 2.0)
        case .Bottom:
            pui.zRotation = CGFloat(M_PI)
        case .Left:
            pui.zRotation = CGFloat(M_PI/2.0)
        default:
            break
        }
        
        entityLayer.addChild(pui)
        pui.runAction(
            SKAction.sequence(pathSequence),
            completion: {
                self.gameEngine.nextState()
                pui.removeFromParent()
            }
        )
    }
    
    private func performActions() {
        if let action = gameEngine.currentPlayerAction {
            println(action)
            switch action.actionType {
            case .Pui:
                animatePuiAction(action as PuiAction)
            case .Fart:
                gameEngine.nextState()
            case .Poop:
                gameEngine.nextState()
            }
        } else {
            gameEngine.nextState()
        }
    }
    
    func onStateUpdate(state: GameState) {
        // we should restrict next-state calls in game engine
        switch state {
        case .Precalculation:
            break
        case .PlayerAction:
            deleteRemovedDoodads()
            highlightReachableNodes()
            break
        case .ServerUpdate:
            clearDirectionArrows()
            removeHighlights()
            break
        case .StartMovesExecution:
            previewNode.hidden = true
        case .MovesExecution:
            movePlayer()
            gameEngine.nextState()
        case .StartActionsExecution:
            gameEngine.nextState()
            performActions()
        case .ActionsExecution:
            break
        case .PostExecution:
            break
        }
    }
    
    func onActionUpdate(action: Action?) {
        clearDirectionArrows()
        if let action = action {
            switch action.actionType {
            case .Pui:
                drawDirectionArrows(action as PuiAction)
            case .Fart:
                break
            case .Poop:
                break
            }
        }
    }
    
    private func drawDirectionArrows(action: PuiAction) {
        var directionSprite = SKDirectionButtonNode(
            defaultButtonImage: "Direction.png",
            activeButtonImage: "DirectionSelected.png",
            size: CGSize(width: 50, height: 50),
            centerSize: puiButton.calculateAccumulatedFrame().size,
            hoverAction: {(direction) -> Void in
                self.gameEngine.currentPlayerAction!.direction = direction
            },
            availableDirection: action.availableDirections,
            selected: action.direction
        )
        
        puiButton.addChild(directionSprite)
        previewDirectionNodes = directionSprite
    }
    
    private func clearDirectionArrows() {
        if previewDirectionNodes != nil {
            previewDirectionNodes.removeFromParent()
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
