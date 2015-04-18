import SpriteKit

/// The spritekit scene for the game, in charge of drawing and animating all 
/// entities of the game.
class GameScene: SKScene {

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

    /// All action buttons.
    private var actionButtons = [SKActionButtonNode]()

    /// Button that sets the action of the player to Pui.
    private var puiButton: SKActionButtonNode!

    /// Button that sets the action of the player to Fart.
    private var fartButton: SKActionButtonNode!

    /// Button that sets the action of the player to Poop.
    private var poopButton: SKActionButtonNode!
    
    /// Inventory slot showing player's held item
    private var inventoryBox: SKSpriteNode!
    
    /// Preview of the next position of the current player when setting the
    /// next tile to move to.
    private var previewNode: SKSpriteNode!
    
    /// Preview of poop when used
    private var poopPreviewNode: SKSpriteNode!
    
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
                CGPoint(x: -buttonSpacing, y: layerPosition.y - 100)
            gameLayer.addChild(buttonLayer)

            /// Additional initialization
            initializeButtons(buttonSpacing)
            initializeInventory()
            initializePlayerPreview(currentPlayerNumber)
            initializePoopPreview()
            addTiles()
            addPlayers()
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
    
    /// This is automatically called at every frame by the scene
    override func update(currentTime: CFTimeInterval) {
        gameEngine.gameLoop()
    }
}



extension GameScene: GameStateListener {
    /// Updates the scene whenever the game state updates.
    ///
    /// :param: state The update game state.
    func onStateUpdate(state: GameState) {
        // we should restrict next-state calls in game engine
        switch state {
        case .PlayerAction:
            enableActionButtons()
            deleteRemovedDoodads()
            highlightReachableNodes()
            break
        case .ServerUpdate:
            disableActionButtons()
            removeHighlights()
        case .AICalculation:
            disableActionButtons()
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
            unselectActionButtons()
        default:
            break
        }
    }
}



extension GameScene: EventListener {
    /// Updates the scene based on the current action selected.
    ///
    /// :param: action The current selected action.
    func onActionUpdate(action: Action?) {
        if let action = action {
            switch action.actionType {
            case .Pui:
                hidePoop()
                unselectActionButtonsExcept(puiButton)
            case .Fart:
                hidePoop()
                unselectActionButtonsExcept(fartButton)
            case .Poop:
                drawPoop(action as PoopAction)
                unselectActionButtonsExcept(poopButton)
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
    
    func onItemObtained(item: Item) {
        let scale = inventoryBox.size.height / item.sprite.size.height
        let animAction = SKAction.group([
            SKAction.moveTo(inventoryBox.position, duration: 0.5),
            SKAction.scaleTo(scale, duration: 0.5)
        ])
        item.sprite.runAction(animAction)
    }
}



private extension GameScene {
    /// Sets the game background image.
    ///
    /// :param: name The background image file.
    func setBackgroundImage(name: String) {
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
    func initializeButtons(buttonSpacing: CGFloat) {
        puiButton = SKPuiActionButtonNode(
            defaultButtonImage: "PuiButton.png",
            activeButtonImage: "PuiButtonPressed.png",
            buttonAction: { (dir: Direction) in
                self.gameEngine.triggerPuiButtonPressed(dir)
            },
            unselectAction: { self.gameEngine.triggerClearAction() },
            getAvailableDirections: { return self.gameEngine.getAvailablePuiDirections() })
        puiButton.position = CGPoint(x: 0 * buttonSpacing, y: 0)
        buttonLayer.addChild(puiButton)
        actionButtons.append(puiButton)

        fartButton = SKActionButtonNode(
            defaultButtonImage: "FartButton.png",
            activeButtonImage: "FartButtonPressed.png",
            buttonAction: { self.gameEngine.triggerFartButtonPressed() },
            unselectAction: { self.gameEngine.triggerClearAction() })
        fartButton.position = CGPoint(x: 1 * buttonSpacing, y: 0)
        buttonLayer.addChild(fartButton)
        actionButtons.append(fartButton)

        poopButton = SKActionButtonNode(
            defaultButtonImage: "PoopButton.png",
            activeButtonImage: "PoopButtonPressed.png",
            buttonAction: { self.gameEngine.triggerPoopButtonPressed() },
            unselectAction: {
                self.hidePoop()
                self.gameEngine.triggerClearAction()
        })
        poopButton.position = CGPoint(x: 2 * buttonSpacing, y: 0)
        buttonLayer.addChild(poopButton)
        actionButtons.append(poopButton)
    }
    
    /// Initializes the inventory slot on game scene.
    func initializeInventory() {
        inventoryBox = SKSpriteNode(imageNamed: "InventoryBox.png")
        inventoryBox.size = CGSizeMake(64, 64)
        inventoryBox.position = CGPoint(x: 32, y: -37)
        entityLayer.addChild(inventoryBox)
    }

    /// Adds the player nodes to the grid.
    func addPlayers() {
        for player in gameEngine.gameManager.players.values {
            let spriteNode = gameEngine.gameManager[positionOf: player]!.sprite
            let playerNode = player.getSprite() as SKSpriteNode
            playerNode.size = spriteNode.size
            playerNode.position = spriteNode.position
            entityLayer.addChild(playerNode)
        }
    }

    /// Initializes the preview node for the current player.
    ///
    /// :param: currentPlayerNumber The index/id of the currentPlayer.
    func initializePlayerPreview(currentPlayerNumber: Int) {
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
    func initializePoopPreview() {
        poopPreviewNode = SKSpriteNode(imageNamed: "Poop.png")
        poopPreviewNode.size = sceneUtils.tileSize
        poopPreviewNode.alpha = 0.5
        poopPreviewNode.hidden = true
        entityLayer.addChild(poopPreviewNode)
    }

    /// Adds the tiles to the grid based on the given level.
    func addTiles() {
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
    func drawTile(tileNode: TileNode) {
        let spriteNode = tileNode.sprite
        spriteNode.size = sceneUtils.tileSize
        spriteNode.position = sceneUtils.pointFor(tileNode.position)
        tilesLayer.addChild(spriteNode)
        
        if let doodad = tileNode.doodad {
            self.drawTileEntity(spriteNode, doodad)
        }
        if let item = tileNode.item {
            self.drawTileEntity(spriteNode, item)
        }
    }

    /// Draws the `TileEntity` on the `SKSpriteNode` of the `TileNode` that it
    /// belongs to.
    ///
    /// :param: spriteNode The `SKSpriteNode` on which the parent `TileNode` is
    ///                    drawn.
    /// :param: tileEntity The given `TileEntity` to be drawn.
    func drawTileEntity(spriteNode: SKSpriteNode,
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

    /// Sets the next position to move to for the current player.
    ///
    /// :param: node The `TileNode` that the player will be moving to.
    func registerPlayerMovement(node: TileNode) {
        if gameEngine.state == GameState.PlayerAction {
            if gameEngine.reachableNodes[Node(node).hashValue] != nil {
                gameEngine.setCurrentPlayerMoveToPosition(node)
                previewNode.position = sceneUtils.pointFor(node.position)
                previewNode.hidden = false
            }
        }
    }

    /// Moves all the players to their respective next positions.
    ///
    /// Notifies the game manager and game engine of movement completion.
    func movePlayers() {
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
    func notifyMovementCompletionFor(player: Cat) {
        gameManager.completeMovementOf(player)
        gameEngine.triggerMovementAnimationEnded()
    }

    /// Animates the pui action of the given player in the given direction.
    ///
    /// :param: player The cat that is performing the pui action.
    /// :param: direction The direction to pui in.
    func animatePuiAction(player: Cat, direction: Direction) {
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

    /// Animates the fart action of the given player.
    ///
    /// :param: player The cat that is performing the fart action.
    func animateFartAction(player: Cat) {
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
                let action = sceneUtils.getFartAnimation(timeInterval)

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
    func performActions() {
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
    func performPendingAnimations() {
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
    func notifyActionCompletionFor(player: Cat) {
        gameManager.completeActionOf(player)
        gameEngine.triggerActionAnimationEnded()
    }

    /// Enables all the action buttons.
    func enableActionButtons() {
        for button in actionButtons {
            button.isEnabled = true
        }
    }

    /// Disables all the action buttons.
    func disableActionButtons() {
        for button in actionButtons {
            button.isEnabled = false
        }
    }

    /// Unselect all of the actions buttons.
    func unselectActionButtons() {
        for button in actionButtons {
            button.unselect()
        }
    }

    /// Unselect all of the actions buttons that is not the given selected
    /// action button.
    ///
    /// :param: actionButton The action button that corresponds to the selected
    ///                      action.
    func unselectActionButtonsExcept(actionButton: SKActionButtonNode) {
        for button in actionButtons {
            if button != actionButton {
                button.unselect()
            }
        }
    }

    /// Draws the preview poop on tile pooper is on.
    ///
    /// :param: action The PoopAction object.
    func drawPoop(action: PoopAction) {
        let referenceSprite = action.targetNode!.sprite
        poopPreviewNode.position = referenceSprite.position
        poopPreviewNode.hidden = false
    }

    /// Removes the poop preview from tile
    func hidePoop() {
        poopPreviewNode.hidden = true
    }

    /// Highlights the reachable nodes for the current player.
    func highlightReachableNodes() {
        for node in gameEngine.reachableNodes.values {
            node.highlight()
        }
    }

    /// Removes the highlighted nodes for the current player.
    func removeHighlights() {
        for node in gameEngine.reachableNodes.values {
            node.unhighlight()
        }
    }

    /// Removes the doodads that are expended for the current turn.
    func deleteRemovedDoodads() {
        let removedSprites = gameManager.doodadsToRemove.values.map {
            (doodad) -> SKNode in
            return doodad.getSprite()
        }
        entityLayer.removeChildrenInArray([SKNode](removedSprites))
        gameManager.doodadsToRemove = [:]
    }
}
