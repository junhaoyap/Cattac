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

    private let infoLayer = SKNode()

    /// All action buttons.
    private var actionButtons = [SKActionButtonNode]()

    /// Button that sets the action of the player to Pui.
    private var puiButton: SKActionButtonNode!

    /// Button that sets the action of the player to Fart.
    private var fartButton: SKActionButtonNode!

    /// Button that sets the action of the player to Poop.
    private var poopButton: SKActionButtonNode!
    
    /// Inventory slot showing player's held item
    private var inventoryBoxButton: SKActionButtonNode!
    
    /// Preview of the next position of the current player when setting the
    /// next tile to move to.
    private var previewNode: SKSpriteNode!
    
    /// Preview of poop when used
    private var poopPreviewNode: SKSpriteNode!
    
    /// Pending animation events to be executed post movement
    private var pendingAnimations: [AnimationEvent] = []
    
    /// Container for previews displayed on game layer for targeting
    private var targetPreviewNodes: [SKSpriteNode] = []
    
    /// Targeting preview during item action
    private var crosshairNode: SKSpriteNode!

    /// Timer
    private var timer: NSTimer!
    private var currentTime: Int = Constants.turnDuration
    private var timerLabel: SKLabelNode!
    private var isPlayerTurn: Bool = true
    
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
            buttonLayer.position = CGPoint(x: -360, y: -512)
            gameLayer.addChild(buttonLayer)

            /// Additional initialization
            initializeButtons(buttonSpacing)
            initializeInventory()
            initializePreviewNodes(currentPlayerNumber)
            addTiles()
            addPlayers()

            infoLayer.position = CGPoint(x: -360, y: 320)
            gameLayer.addChild(infoLayer)
            initializeInformationBar()
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

    override func willMoveFromView(view: SKView) {
        timer.invalidate()
    }

    func updateTime() {
        if currentTime == 0 {
            timerLabel.text = "Executing Turn"
            gameEngine.triggerPlayerActionEnded()
            timer.invalidate()
            currentTime = Constants.turnDuration
        } else {
            currentTime--
            timerLabel.text = "\(currentTime)s"
        }
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
            startTimer()
            enableActionButtons()
            deleteRemovedDoodads()
            highlightReachableNodes()
            break
        case .ServerUpdate:
            disableActionButtons()
            removeHighlights()
            unhighlightTargetPlayers()
        case .AICalculation:
            disableActionButtons()
            removeHighlights()
            unhighlightTargetPlayers()
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
                unhighlightTargetPlayers()
            case .Fart:
                hidePoop()
                unselectActionButtonsExcept(fartButton)
                unhighlightTargetPlayers()
            case .Poop:
                drawPoop(action as PoopAction)
                unselectActionButtonsExcept(poopButton)
                unhighlightTargetPlayers()
            case .Item:
                hidePoop()
                unselectActionButtonsExcept(inventoryBoxButton)
                if (action as ItemAction).item.canTargetOthers() {
                    highlightTargetPlayers()
                }
            }
        }
    }
    
    /// Adds poop activation animation to pending animations. Pending animations
    /// are animated immediately after moves execution.
    ///
    /// :param: poop The Poop that is being activated.
    /// :param: target The target TileNode to animate at.
    func addPendingPoopAnimation(poop: Poop, target: TileNode) {
        let poopSprite = SKSpriteNode(imageNamed: "Poop.png")
        poopSprite.position = sceneUtils.pointFor(target.position)
        poopSprite.size = sceneUtils.tileSize

        let action = sceneUtils.getFartAnimation(0)
        let completion = {
            self.showDamage(poop.damage, node: target)
        }

        pendingAnimations += [AnimationEvent(poopSprite, action,
            completion: completion)]
    }
    
    /// Animates the obtaining of an item. If item is obtained by current
    /// player, the item sprite is flown to the inventory box, but if its not
    /// the current player, item shrinks into character sprite and disappears.
    ///
    /// :param: item The item that is obtained.
    /// :param: isCurrentPlayer true if item is picked by current player, false
    ///         otherwise.
    func onItemObtained(item: Item, _ isCurrentPlayer: Bool) {
        if isCurrentPlayer {
            let scale = 64 / item.sprite.size.height
            let dur = sceneUtils.getAnimDuration(item.sprite.position,
                dest: inventoryBoxButton.position)

            let inventoryPositionInGameLayer = buttonLayer.convertPoint(
                inventoryBoxButton.position, toNode: gameLayer)
            let inventoryPositionInEntityLayer = gameLayer.convertPoint(
                inventoryPositionInGameLayer, toNode: entityLayer)

            let animAction = SKAction.group([
                SKAction.moveTo(inventoryPositionInEntityLayer, duration: dur),
                SKAction.scaleTo(scale, duration: dur)
            ])
            item.sprite.runAction(animAction)
        } else {
            let animAction = sceneUtils.getObtainItemAnimation()
            item.sprite.runAction(animAction)
        }
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
        let bottomBoard = SKSpriteNode(imageNamed: "BottomBoard.png")
        bottomBoard.size = CGSize(width: self.size.width,
            height: 192)
        bottomBoard.position = CGPoint(x: 360, y: 96)
        bottomBoard.zPosition = -10
        buttonLayer.addChild(bottomBoard)

        puiButton = SKPuiActionButtonNode(
            defaultButtonImage: "PuiButton.png",
            activeButtonImage: "PuiButtonPressed.png",
            buttonAction: { (dir: Direction) in
                self.gameEngine.triggerPuiButtonPressed(dir)
            },
            unselectAction: { self.gameEngine.triggerClearAction() },
            getAvailableDirections: { return self.gameEngine.getAvailablePuiDirections() })
        puiButton.position = CGPoint(x: 360-buttonSpacing, y: 80)
        buttonLayer.addChild(puiButton)
        actionButtons.append(puiButton)

        fartButton = SKActionButtonNode(
            defaultButtonImage: "FartButton.png",
            activeButtonImage: "FartButtonPressed.png",
            buttonAction: { self.gameEngine.triggerFartButtonPressed() },
            unselectAction: { self.gameEngine.triggerClearAction() })
        fartButton.position = CGPoint(x: 360, y: 80)
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
        poopButton.position = CGPoint(x: 360+buttonSpacing, y: 80)
        buttonLayer.addChild(poopButton)
        actionButtons.append(poopButton)
    }
    
    /// Initializes the inventory slot on game scene.
    func initializeInventory() {
        inventoryBoxButton = SKActionButtonNode(
            defaultButtonImage: "InventoryBox.png",
            activeButtonImage: "InventoryBoxPressed.png",
            buttonAction: { self.gameEngine.triggerItemButtonPressed() },
            unselectAction: {
                self.gameEngine.triggerClearAction()
                self.unhighlightTargetPlayers()
        })
        
        inventoryBoxButton.position = CGPoint(x: 360, y: 140)
        actionButtons.append(inventoryBoxButton)
        buttonLayer.addChild(inventoryBoxButton)
    }

    func startTimer() {
        timerLabel.text = "\(currentTime)s"
        timer = NSTimer.scheduledTimerWithTimeInterval(
            1,
            target: self,
            selector: Selector("updateTime"),
            userInfo: nil,
            repeats: true
        )
    }

    /// Adds the player nodes to the grid.
    func addPlayers() {
        for player in gameManager.players.values {
            let spriteNode = gameEngine.gameManager[positionOf: player]!.sprite
            let playerNode = player.getSprite() as SKSpriteNode
            playerNode.size = spriteNode.size
            playerNode.position = spriteNode.position
            entityLayer.addChild(playerNode)
        }
    }

    func initializeInformationBar() {
        let topBoard = SKSpriteNode(imageNamed: "TopBoard.png")
        topBoard.size = CGSize(width: self.size.width, height: 192)
        topBoard.position = CGPoint(x: 360, y: 96)
        topBoard.zPosition = -10
        infoLayer.addChild(topBoard)

        timerLabel = SKLabelNode(fontNamed: "BubblegumSans-Regular")
        timerLabel.fontColor = UIColor.blackColor()
        timerLabel.position = CGPoint(x: 360, y: 96)
        infoLayer.addChild(timerLabel)
    }

    /// Initializes the preview nodes game.
    ///
    /// :param: currentPlayerNumber The index/id of the currentPlayer.
    func initializePreviewNodes(currentPlayerNumber: Int) {
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
        
        
        /// Initializes the preview node for the poop action.
        poopPreviewNode = SKSpriteNode(imageNamed: "Poop.png")
        poopPreviewNode.size = sceneUtils.tileSize
        poopPreviewNode.alpha = 0.5
        poopPreviewNode.hidden = true
        entityLayer.addChild(poopPreviewNode)
        
        /// Initializes the preview node for the crosshair.
        crosshairNode = sceneUtils.getCrosshairNode()
        crosshairNode.hidden = true
        entityLayer.addChild(crosshairNode)
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
        var victimPlayer: Cat?

        for node in path {
            let action = SKAction.moveTo(node.sprite.position, duration: 0.15)
            pathSequence.append(action)
        }

        if let node = path.last {
            if let player = gameEngine.otherPlayerMoveToNodes[node.position] {
                victimPlayer = player
            }
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
                if victimPlayer != nil {
                    victimPlayer!.inflict(player.puiDmg)
                    self.showDamage(player.puiDmg, node: path.last!)
                    println("\(player.name) pui on \(victimPlayer!.name) with" +
                        "\(player.puiDmg) damage.")
                }
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
                var victimPlayer: Cat?

                if let player = gameEngine.otherPlayerMoveToNodes[node.position] {
                    victimPlayer = player
                }

                let fart = SKSpriteNode(imageNamed: "Fart.png")
                fart.size = CGSize(width: sceneUtils.tileSize.width / 4,
                    height: sceneUtils.tileSize.height / 4)
                fart.position = node.sprite.position
                fart.alpha = 0

                entityLayer.addChild(fart)
                let action = sceneUtils.getFartAnimation(timeInterval)

                fart.runAction(action, completion: {
                    fart.removeFromParent()
                    if victimPlayer != nil {
                        victimPlayer!.inflict(player.fartDmg)
                        self.showDamage(player.fartDmg, node: node)
                        println("\(player.name) fart on \(victimPlayer!.name)" +
                            " with \(player.fartDmg) damage.")
                    }
                    if i == path.count - 1 && j == nodes.count - 1 {
                        self.notifyActionCompletionFor(player)
                    }
                })
            }
        }
    }
    
    /// Animates the fart action of the given player.
    ///
    /// :param: player The cat that is performing the action.
    /// :param: action ItemAction used
    func animateItemAction(player: Cat, action: ItemAction) {
        let itemSprite = action.item.sprite
        let tileNode = gameManager[moveToPositionOf: player]!
        let targetPlayer = action.targetPlayer
        itemSprite.size = tileNode.sprite.size
        itemSprite.position = tileNode.sprite.position
        var completion: (() -> Void)?
        
        var animAction: SKAction!
        
        if gameManager.samePlayer(player, targetPlayer) {
            animAction = sceneUtils.getPassiveItemUsedAnimation()
            if let item = action.item as? NukeItem {
                completion = {
                    for player in self.gameManager.players.values {
                        self.showDamage(Constants.itemEffect.nukeDmg,
                            node: self.gameManager[moveToPositionOf: player]!)
                    }
                }
            } else if let item = action.item as? MilkItem {
                completion = {
                    self.showDamage(-Constants.itemEffect.milkHpIncreaseEffect,
                        node: self.gameManager[moveToPositionOf: player]!)
                }
            }
        } else {
            let dest = action.targetNode!.sprite.position
            let v = SceneUtils.vector(tileNode.sprite.position, dest)
            animAction = sceneUtils.getAggressiveItemUsedAnimation(v)
            if let item = action.item as? ProjectileItem {
                completion = {
                    self.showDamage(Constants.itemEffect.projectileDmg,
                        node: self.gameManager[moveToPositionOf: targetPlayer]!)
                }
            }
        }
        
        itemSprite.runAction(animAction, completion: {
            self.notifyActionCompletionFor(player)
            itemSprite.removeFromParent()
            completion?()
        })
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
                case .Item:
                    animateItemAction(player, action: action as ItemAction)
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
                if event.completion != nil {
                    event.completion!()
                }
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

    /// Show the damage dealt on the TileNode of the victim player.
    ///
    /// :param: damange The amount of damage dealt
    /// :param: node The TileNode of the victim player.
    func showDamage(damage: Int, node: TileNode) {
        let nodeSprite = node.sprite
        let damageNode = SKLabelNode(text: "\(-damage)")
        let color = damage > 0 ? UIColor.redColor() : UIColor.cyanColor()
        damageNode.position = node.sprite.position
        damageNode.alpha = 0
        damageNode.fontColor = color
        damageNode.fontName = "LuckiestGuy-Regular"
        damageNode.zPosition = 20
        entityLayer.addChild(damageNode)

        let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.25)
        let move = SKAction.moveByX(0, y: node.sprite.size.height, duration: 0.25)
        let entryGroup = SKAction.group([fadeIn, move])
        let wait = SKAction.waitForDuration(0.5)
        let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.25)
        let sequence = SKAction.sequence([entryGroup, wait, fadeOut])

        damageNode.runAction(sequence, completion: {
            damageNode.removeFromParent()
        })
    }

    /// Enables all the action buttons.
    func enableActionButtons() {
        for button in actionButtons {
            button.isEnabled = true
        }
        if gameManager[itemOf: gameEngine.currentPlayer] == nil {
            inventoryBoxButton.isEnabled = false
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
    
    /// Hides arrows indicating targetable players for item action.
    func highlightTargetPlayers() {
        let currentPlayer = gameEngine.currentPlayer
        let item = gameManager[itemOf: currentPlayer]!
        for player in gameManager.players.values {
            if gameManager.samePlayer(player, currentPlayer) {
                continue
            }
            
            let playerSprite = player.getSprite() as SKTouchSpriteNode
            let position = playerSprite.position
            let arrowSprite = sceneUtils.getPlayerTargetableArrow(position)
            entityLayer.addChild(arrowSprite)
            targetPreviewNodes += [arrowSprite]
            
            if item.shouldTargetAll() {
                let crosshairSprite = sceneUtils.getCrosshairNode()
                crosshairSprite.position = playerSprite.position
                entityLayer.addChild(crosshairSprite)
                targetPreviewNodes += [crosshairSprite]
            } else {
                playerSprite.setTouchObserver({
                    self.gameEngine.triggerTargetPlayerChanged(player)
                    self.crosshairNode.position = playerSprite.position
                    self.crosshairNode.hidden = false
                })
                playerSprite.userInteractionEnabled = true
            }
        }
    }
    
    /// Hides arrows indicating targetable players for item action.
    func unhighlightTargetPlayers() {
        for player in gameManager.players.values {
            if gameManager.samePlayer(player, gameEngine.currentPlayer) {
                continue
            }
            let playerSprite = player.getSprite() as SKTouchSpriteNode
            if playerSprite.userInteractionEnabled {
                playerSprite.setTouchObserver(nil)
                playerSprite.userInteractionEnabled = false
            }
        }
        for node in targetPreviewNodes {
            node.removeFromParent()
        }
        targetPreviewNodes.removeAll(keepCapacity: false)
        crosshairNode.hidden = true
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
