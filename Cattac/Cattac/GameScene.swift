import SpriteKit

/// The spritekit scene for the game, in charge of drawing and animating all 
/// entities of the game.
class GameScene: SKScene, GameStateListener, ActionListener {

    /// Game Engine that does all the logic for the scene.
    let gameEngine: GameEngine!

    /// Current level for the game.
    private let level: GameLevel!

    /// Utilities for the scene.
    private let sceneUtils: SceneUtils!

    /// The game layer that encompases everything in the scene.
    private let gameLayer = SKNode()

    /// The tiles layer that encompases the grid.
    private let tilesLayer = SKNode()

    /// The entity layer that lays on top of the tiles layer and encompases all
    /// the players and objects on the grid.
    private let entityLayer = SKNode()

    /// The button layer that consists of the main buttons for the actions.
    private let buttonLayer = SKNode()

    /// Button that sets the action of the player to Pui.
    private var puiButton: SKActionButtonNode!

    /// Button that sets the action of the player to Fart.
    private var fartButton: SKActionButtonNode!

    /// Button that sets the action of the player to Poop.
    private var poopButton: SKActionButtonNode!

    /// Preview of the next position of the current player when setting the
    /// next tile to move to.
    private var previewNode: SKSpriteNode!

    /// Preview of the directional buttons that appears when the pui action 
    /// button is selected.
    private var previewDirectionNodes: SKNode!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        assertionFailure("Should not call this init, init with game level!")
    }

    /// Initializes the game scene.
    ///
    /// :param: size The size of the view.
    /// :param: level The game level that is selected.
    /// :param: currentPlayerNumber The index/id for the current player.
    init(_ size: CGSize, _ level: GameLevel, _ currentPlayerNumber: Int) {
        super.init(size: size)
        
        self.level = level
        gameEngine =
            GameEngine(grid: level.grid, playerNumber: currentPlayerNumber)
        gameEngine.gameStateListener = self
        gameEngine.actionListener = self

        sceneUtils = SceneUtils(windowWidth: size.width,
            numRows: level.numRows, numColumns: level.numColumns)
        
        // Sets the anchorpoint for the scene to be the center of the screen
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addChild(gameLayer)
        
        // position of the general game layer
        let layerPosition = sceneUtils.getLayerPosition()

        // adds tilesLayer to the game layer
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        // adds entityLayer to the game layer
        entityLayer.position = layerPosition
        gameLayer.addChild(entityLayer)

        // adds buttonLayer to the gameLayer
        let buttonSpacing: CGFloat = 220
        buttonLayer.position =
            CGPoint(x: -buttonSpacing, y: layerPosition.y - 90)
        gameLayer.addChild(buttonLayer)

        /// Additional initialization
        initializeButtons(buttonSpacing)
        initializePlayerPreview(currentPlayerNumber)
        addTiles()
        addPlayers()
    }

    /// Initializes the action buttons for the scene.
    ///
    /// :param: buttonSpacing The spacing between the center anchor of the 
    ///                       buttons.
    private func initializeButtons(buttonSpacing: CGFloat) {
        puiButton = SKActionButtonNode(
            defaultButtonImage: "PuiButton.png",
            activeButtonImage: "PuiButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("puiButtonPressed") })
        puiButton.position = CGPoint(x: 0 * buttonSpacing, y: 0)
        buttonLayer.addChild(puiButton)

        fartButton = SKActionButtonNode(
            defaultButtonImage: "FartButton.png",
            activeButtonImage: "FartButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("fartButtonPressed") })
        fartButton.position = CGPoint(x: 1 * buttonSpacing, y: 0)
        buttonLayer.addChild(fartButton)

        poopButton = SKActionButtonNode(
            defaultButtonImage: "PoopButton.png",
            activeButtonImage: "PoopButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("poopButtonPressed") })
        poopButton.position = CGPoint(x: 2 * buttonSpacing, y: 0)
        buttonLayer.addChild(poopButton)
    }

    /// Initializes the preview node for the current player.
    ///
    /// :param: currentPlayerNumber The index/id of the currentPlayer.
    private func initializePlayerPreview(currentPlayerNumber: Int) {
        switch currentPlayerNumber {
        case 1:
            previewNode = SKSpriteNode(imageNamed: "Nala.png")
        case 2:
            previewNode = SKSpriteNode(imageNamed: "Grumpy.png")
        case 3:
            previewNode = SKSpriteNode(imageNamed: "Nyan.png")
        case 4:
            previewNode = SKSpriteNode(imageNamed: "Pusheen.png")
        default:
            break
        }

        previewNode.size = sceneUtils.tileSize
        previewNode.alpha = 0.5
        entityLayer.addChild(previewNode)
        previewNode.hidden = true
    }

    /// Adds the tiles to the grid based on the given level.
    private func addTiles() {
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                if let tileNode = level.nodeAt(row, column) {
                    drawTile(tileNode)
                }
            }
        }
    }

    /// Draws the tiles on the scene based on the `TileNode` given, including
    /// the doodads.
    ///
    /// :param: tileNode The given `TileNode` to be drawn.
    private func drawTile(tileNode: TileNode) {
        let spriteNode = tileNode.sprite
        spriteNode.size = sceneUtils.tileSize
        spriteNode.position = sceneUtils.pointFor(tileNode.position)
        tilesLayer.addChild(spriteNode)

        if let doodad = tileNode.doodad {
            self.drawTileEntity(spriteNode, doodad)
        }
    }

    /// Draws the `TileEntity` on the `SKSpriteNode` of the `TileNode` that it
    /// belongs to.
    ///
    /// :param: spriteNode The `SKSpriteNode` on which the parent `TileNode` is
    ///                    drawn.
    /// :param: tileEntity The given `TileEntity` to be drawn.
    private func drawTileEntity(spriteNode: SKSpriteNode,
        _ tileEntity: TileEntity) {
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

    /// Adds the player nodes to the grid.
    private func addPlayers() {
        for player in gameEngine.gameManager.players.values {
            let spriteNode = gameEngine.gameManager[positionOf: player]!.sprite
            let playerNode = player.getSprite() as SKSpriteNode
            playerNode.size = spriteNode.size
            playerNode.position = spriteNode.position
            entityLayer.addChild(playerNode)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)
            
            if let node = sceneUtils.nodeForLocation(location,
                grid: level.grid) {
                    registerPlayerMovement(node)
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)

            if let node = sceneUtils.nodeForLocation(location,
                grid: level.grid) {
                    registerPlayerMovement(node)
            }
        }
    }

    /// Sets the next position to move to for the current player.
    ///
    /// :param: node The `TileNode` that the player will be moving to.
    private func registerPlayerMovement(node: TileNode) {
        if gameEngine.state == GameState.PlayerAction {
            if gameEngine.reachableNodes[Node(node).hashValue] != nil {
                gameEngine.setCurrentPlayerMoveToPosition(node)
                previewNode.position = sceneUtils.pointFor(node.position)
                previewNode.hidden = false
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        gameEngine.gameLoop()
    }

    /// Moves all the players to their respective next positions.
    ///
    /// Triggers the `movementAnimationEnded` event of the game engine so as to
    /// advance to the next game state to animation the player actions.
    private func movePlayers() {
        let players = gameEngine.gameManager.players

        for (playerName, player) in players {
            let path = gameEngine.executePlayerMove(player)
            var pathSequence: [SKAction] = []
            
            for node in path {
                let action = SKAction.moveTo(node.sprite.position,
                    duration: 0.25)
                pathSequence.append(action)
            }
            
            if pathSequence.count > 0 {
                player.getSprite().runAction(
                    SKAction.sequence(pathSequence),
                    completion: {
                        self.gameEngine.gameManager.completeMovementOf(player)
                        self.gameEngine.trigger("movementAnimationEnded")
                    }
                )
            }
        }
    }

    /// Animates the pui action of the given player in the given direction.
    ///
    /// :param: player The cat that is performing the pui action.
    /// :param: direction The direction to pui in.
    private func animatePuiAction(player: Cat, direction: Direction) {
        let startNode = gameEngine.gameManager[moveToPositionOf: player]!
        let path = gameEngine.pathOfPui(startNode, direction: direction)
        var pathSequence: [SKAction] = []

        for node in path {
            let action = SKAction.moveTo(node.sprite.position, duration: 0.15)
            pathSequence.append(action)
        }

        let pui = SKSpriteNode(imageNamed: "Pui.png")
        pui.size = sceneUtils.tileSize
        pui.position = startNode.sprite.position
        pui.zRotation = SceneUtils.zRotation(direction)

        entityLayer.addChild(pui)

        pui.runAction(
            SKAction.sequence(pathSequence),
            completion: {
                pui.removeFromParent()
            }
        )
    }

    /// Performs the respective actions for each player.
    private func performActions() {
        for player in gameEngine.gameManager.players.values {
            if let action = gameEngine.executePlayerAction(player) {
                println(action)
                switch action.actionType {
                case .Pui:
                    let direction = (action as PuiAction).direction
                    animatePuiAction(player, direction: direction)
                case .Fart:
                    break
                case .Poop:
                    break
                }
            }
        }
    }

    /// Updates the scene whenever the game state updates.
    ///
    /// :param: state The update game state.
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
        case .WaitForAll:
            break
        case .StartMovesExecution:
            previewNode.hidden = true
        case .MovesExecution:
            movePlayers()
        case .StartActionsExecution:
            performActions()
        case .ActionsExecution:
            break
        case .PostExecution:
            break
        }
    }

    /// Updates the scene based on the current action selected.
    ///
    /// :param: action The current selected action.
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

    /// Draws the directional arrows for pui action button.
    ///
    /// :param: action The Pui Action object.
    private func drawDirectionArrows(action: PuiAction) {
        var directionSprite = SKDirectionButtonNode(
            defaultButtonImage: "Direction.png",
            activeButtonImage: "DirectionSelected.png",
            size: CGSize(width: 50, height: 50),
            centerSize: puiButton.calculateAccumulatedFrame().size,
            hoverAction: {(direction) in
                self.gameEngine.gameManager[actionOf: self.gameEngine.currentPlayer]!.direction = direction
            },
            availableDirection: action.availableDirections,
            selected: action.direction
        )
        
        puiButton.addChild(directionSprite)
        previewDirectionNodes = directionSprite
    }

    /// Clears the directional arrows for the pui action button.
    private func clearDirectionArrows() {
        if previewDirectionNodes != nil {
            previewDirectionNodes.removeFromParent()
        }
    }

    /// Highlights the reachable nodes for the current player.
    private func highlightReachableNodes() {
        for node in gameEngine.reachableNodes.values {
            node.highlight()
        }
    }

    /// Removes the highlighted nodes for the current player.
    private func removeHighlights() {
        for node in gameEngine.reachableNodes.values {
            node.unhighlight()
        }
    }

    /// Removes the doodads that are expended for the current turn.
    private func deleteRemovedDoodads() {
        let removedSprites = gameEngine.gameManager.doodadsToRemove.values.map {
            (doodad) -> SKNode in
            return doodad.getSprite()
        }
        entityLayer.removeChildrenInArray([SKNode](removedSprites))
        gameEngine.gameManager.doodadsToRemove = [:]
    }
}
