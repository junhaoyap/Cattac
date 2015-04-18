import SpriteKit

/// The spritekit scene for the game, in charge of drawing and animating all 
/// entities of the game.
class GameScene: SKScene, GameStateListener, EventListener {

    /// Game Engine that does all the logic for the scene.
    let gameEngine: GameEngine!

    /// Game Manager that contains all the information for the current state of
    /// the game.
    let gameManager: GameManager!

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
    
    /// Preview of poop when used
    private var poopPreviewNode: SKSpriteNode!

    /// Preview of the directional buttons that appears when the pui action 
    /// button is selected.
    private var previewDirectionNodes: SKNode!
    
    /// Pending animation events to be executed post movement
    private var pendingAnimations: [AnimationEvent] = []
    
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
    /// :param: multiplayer Whether the game is multiplayer or single player.
    init(size: CGSize, level: GameLevel, currentPlayerNumber: Int,
        multiplayer: Bool) {
            super.init(size: size)

            self.level = level
            gameEngine = GameEngine(grid: level.grid,
                playerNumber: currentPlayerNumber, multiplayer: multiplayer)
            gameEngine.gameStateListener = self
            gameEngine.eventListener = self

            gameManager = gameEngine.gameManager

            sceneUtils = SceneUtils(windowWidth: size.width,
                numRows: level.numRows, numColumns: level.numColumns)
            
            // Sets the anchorpoint for the scene to be the center of the screen
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            self.addChild(gameLayer)

            setBackgroundImage("background.jpg")
            
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
            initializePoopPreview()
            addTiles()
            addPlayers()
    }

    /// Sets the game background image.
    ///
    /// :param: name The background image file.
    private func setBackgroundImage(name: String) {
        let image = UIImage(named: name)!
        let backgroundCGImage = image.CGImage
        let textureSize = CGRectMake(0, 0, image.size.width, image.size.height)

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawTiledImage(context, textureSize, backgroundCGImage)
        let tiledBackground = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let backgroundTexture = SKTexture(CGImage: tiledBackground.CGImage)
        let backgroundImage  = SKSpriteNode(texture: backgroundTexture)
        backgroundImage.yScale = -1
        backgroundImage.zPosition = -10

        self.addChild(backgroundImage)
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
            previewNode = SKSpriteNode(imageNamed: "Nyan.png")
        case 3:
            previewNode = SKSpriteNode(imageNamed: "Grumpy.png")
        case 4:
            previewNode = SKSpriteNode(imageNamed: "Pusheen.png")
        default:
            break
        }

        previewNode.size = sceneUtils.tileSize
        previewNode.alpha = 0.5
        previewNode.hidden = true
        entityLayer.addChild(previewNode)
    }
    
    /// Initializes the preview node for the poop action.
    private func initializePoopPreview() {
        poopPreviewNode = SKSpriteNode(imageNamed: "Poop.png")
        poopPreviewNode.size = sceneUtils.tileSize
        poopPreviewNode.alpha = 0.5
        poopPreviewNode.hidden = true
        entityLayer.addChild(poopPreviewNode)
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
    
    /// When player tries to perform movement actions
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)
            
            if let node = sceneUtils.nodeForLocation(location,
                grid: level.grid) {
                    registerPlayerMovement(node)
            }
        }
    }
    
    /// When player tries to change their movement actions
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
    
    /// This is automatically called at every frame by the scene
    override func update(currentTime: CFTimeInterval) {
        gameEngine.gameLoop()
    }

    /// Moves all the players to their respective next positions.
    ///
    /// Notifies the game manager and game engine of movement completion.
    private func movePlayers() {
        for (playerName, player) in gameManager.players {
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
                        self.notifyMovementCompletionFor(player)
                    }
                )
            } else {
                notifyMovementCompletionFor(player)
            }
        }
    }

    /// Sets the completion flag of the player movement in the game manager.
    ///
    /// Triggers the `movementAnimationEnded` event of the game engine so as to
    /// advance to the next game state to animation the player actions.
    ///
    /// :param: player The player that has completed its movement animation.
    private func notifyMovementCompletionFor(player: Cat) {
        gameManager.completeMovementOf(player)
        gameEngine.trigger("movementAnimationEnded")
    }

    /// Animates the pui action of the given player in the given direction.
    ///
    /// :param: player The cat that is performing the pui action.
    /// :param: direction The direction to pui in.
    private func animatePuiAction(player: Cat, direction: Direction) {
        let startNode = gameManager[moveToPositionOf: player]!
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
                self.notifyActionCompletionFor(player)
            }
        )
    }

    private func animateFartAction(player: Cat) {
        let startNode = gameManager[moveToPositionOf: player]!
        let path = gameEngine.pathOfFart(startNode, range: player.fartRange)
        let delay = 0.25

        for (i, nodes) in enumerate(path) {
            let timeInterval = Double(i) * delay
            for (j, node) in enumerate(nodes.values) {

                let fart = SKSpriteNode(imageNamed: "Fart.png")
                fart.size = CGSize(width: sceneUtils.tileSize.width / 4,
                    height: sceneUtils.tileSize.height / 4)
                fart.position = node.sprite.position
                fart.alpha = 0

                entityLayer.addChild(fart)
                let action = sceneUtils.getFartAnimation(delay)
                
                fart.runAction(action, completion: {
                    fart.removeFromParent()
                    if i == path.count - 1 && j == nodes.count - 1 {
                        self.notifyActionCompletionFor(player)
                    }
                })
            }
        }
    }

    /// Performs the respective actions for each player.
    private func performActions() {
        for player in gameManager.players.values {
            if let action = gameEngine.executePlayerAction(player) {
                println(action)
                switch action.actionType {
                case .Pui:
                    let direction = (action as PuiAction).direction
                    animatePuiAction(player, direction: direction)
                case .Fart:
                    animateFartAction(player)
                case .Poop:
                    notifyActionCompletionFor(player)
                }
            } else {
                notifyActionCompletionFor(player)
            }
        }
    }
    
    /// Performs the animations for each event, such as stepping on poop.
    private func performPendingAnimations() {
        for event in pendingAnimations {
            entityLayer.addChild(event.sprite)
            
            event.sprite.runAction(event.action, completion: {
                event.sprite.removeFromParent()
            })
        }
        pendingAnimations.removeAll(keepCapacity: false)
    }

    /// Sets the completion flag of the player action in the game manager.
    ///
    /// Triggers the `actionAnimationEnded` event of the game engine so as to
    /// advance to the next game state to post execution.
    ///
    /// :param: player The player that has completed its action animation.
    private func notifyActionCompletionFor(player: Cat) {
        gameManager.completeActionOf(player)
        gameEngine.trigger("actionAnimationEnded")
    }

    /// Updates the scene whenever the game state updates.
    ///
    /// :param: state The update game state.
    func onStateUpdate(state: GameState) {
        // we should restrict next-state calls in game engine
        switch state {
        case .PlayerAction:
            deleteRemovedDoodads()
            highlightReachableNodes()
            break
        case .ServerUpdate:
            clearDirectionArrows()
            removeHighlights()
        case .AICalculation:
            clearDirectionArrows()
            removeHighlights()
        case .StartMovesExecution:
            previewNode.hidden = true
        case .MovesExecution:
            movePlayers()
        case .ActionsExecution:
            // intuitively hide poop preview only after pooper moved away
            hidePoop()
            performPendingAnimations()
            performActions()
        default:
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
                hidePoop()
            case .Fart:
                hidePoop()
            case .Poop:
                drawPoop(action as PoopAction)
            }
        }
    }
    
    func addPendingPoopAnimation(target: GridIndex) {
        let poopSprite = SKSpriteNode(imageNamed: "Poop.png")
        poopSprite.position = sceneUtils.pointFor(target)
        poopSprite.size = sceneUtils.tileSize
        
        let action = sceneUtils.getFartAnimation(0)
        
        pendingAnimations += [AnimationEvent(poopSprite, action)]
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
                self.gameManager[actionOf:
                    self.gameEngine.currentPlayer]!.direction = direction
            },
            availableDirection: action.availableDirections,
            selected: action.direction
        )
        
        puiButton.addChild(directionSprite)
        previewDirectionNodes = directionSprite
    }
    
    /// Draws the preview poop on tile pooper is on.
    ///
    /// :param: action The PoopAction object.
    private func drawPoop(action: PoopAction) {
        let referenceSprite = action.targetNode!.sprite
        poopPreviewNode.position = referenceSprite.position
        poopPreviewNode.hidden = false
    }
    
    /// Removes the poop preview from tile
    private func hidePoop() {
        poopPreviewNode.hidden = true
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
        let removedSprites = gameManager.doodadsToRemove.values.map {
            (doodad) -> SKNode in
            return doodad.getSprite()
        }
        entityLayer.removeChildrenInArray([SKNode](removedSprites))
        gameManager.doodadsToRemove = [:]
    }
}
