import SpriteKit

protocol ApplicationUIListener {
    func presentAlert(alert: UIAlertController)
    func endGame()
}

/// The spritekit scene for the game, in charge of drawing and animating all 
/// entities of the game.
class GameScene: SKScene {

    /// Game Engine that does all the logic for the scene.
    let gameEngine: GameEngine!

    /// Game Manager that contains all the information for the current state of
    /// the game.
    let gameManager: GameManager!
    
    private var applicationUIListener: ApplicationUIListener?

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

    /// The bottom layer that consists of the main buttons for the actions.
    private let bottomBoardLayer = SKNode()

    private let buttonLayer = SKNode()

    private let topBoardLayer = SKNode()

    /// All action buttons.
    private var actionButtons = [SKActionButtonNode]()

    /// Button that sets the action of the player to Pui.
    private var puiButton: SKPuiActionButtonNode!

    /// Button that sets the action of the player to Fart.
    private var fartButton: SKActionButtonNode!

    /// Button that sets the action of the player to Poop.
    private var poopButton: SKActionButtonNode!
    
    /// Inventory slots for all the items.
    private var inventoryMilkButton: SKInventoryItemNode!
    private var inventoryProjectileButton: SKInventoryItemNode!
    private var inventoryNukeButton: SKInventoryItemNode!
    
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
    
    // Player Names
    private var playerNames: [String]!
    
    private var animationCount: Int = 0
    
    // Sound Player
    let soundPlayer = SoundPlayer.sharedInstance
    
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
        multiplayer: Bool, names: [String]) {
            super.init(size: size)
            
            self.playerNames = names
            self.level = level
            gameEngine = GameEngine(grid: level.grid,
                playerNumber: currentPlayerNumber, multiplayer: multiplayer)
            gameEngine.eventListener = self

            gameManager = gameEngine.gameManager

            sceneUtils = SceneUtils(windowWidth: size.width,
                numRows: level.numRows, numColumns: level.numColumns)
            
            // Sets the anchorpoint for the scene to be the center of the screen
            anchorPoint = CGPoint(x: 0.5, y: 0.5)

            initializeLayers()
            initializeButtons()

            initializePreviewNodes(currentPlayerNumber)
            addTiles()
            addPlayers()

            topBoardLayer.position = CGPoint(x: -384, y: 320)
            gameLayer.addChild(topBoardLayer)
            initializeInformationBar()
    }
    
    /// When player tries to perform movement actions
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if !gameEngine.currentPlayer.isDead {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(gameLayer)
                
                if let node = sceneUtils.nodeForLocation(location,
                    grid: level.grid) {
                        registerPlayerMovement(node)
                }
            }
        }
    }
    
    /// When player tries to change their movement actions
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if !gameEngine.currentPlayer.isDead {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(gameLayer)

                if let node = sceneUtils.nodeForLocation(location,
                    grid: level.grid) {
                        registerPlayerMovement(node)
                }
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
    
    func setUIListener(listener: ApplicationUIListener) {
        applicationUIListener = listener
    }

    func updateTime() {
        if currentTime == 0 {
            timerLabel.text = "Wait"
            gameEngine.triggerPlayerActionEnded()
            timer.invalidate()
            currentTime = Constants.turnDuration
        } else {
            currentTime--
            timerLabel.text = "\(currentTime)s"
        }
    }
}


extension GameScene: EventListener {
    
    /// Updates the scene whenever the game state updates.
    ///
    /// :param: state The update game state.
    func onStateUpdate(state: GameState) {
        // we should restrict next-state calls in game engine
        switch state {
        case .PlayerAction:
            startTimer()
            deleteRemovedDoodads()
            if !gameEngine.currentPlayer.isDead {
                wiggleCurrentPlayer()
                highlightReachableNodes()
                enableActionButtons()
            } else {
                previewNode.hidden = true
            }
        case .WaitForAll:
            disableActionButtons()
            removeHighlights()
            unhighlightTargetPlayers()
            unwiggleCurrentPlayer()
        case .StartMovesExecution:
            previewNode.hidden = true
        case .DeconflictExecution:
            runDummyAnimation()
            deconflictPlayer()
        case .MovesExecution:
            movePlayers()
            runDummyAnimation()
        case .ActionsExecution:
            hidePoop()
            performActions()
            performPendingAnimations()
            runDummyAnimation()
            unselectActionButtons()
        case .GameEnded:
            endGame()
        default:
            break
        }
    }
    
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

                switch (action as ItemAction).item {
                case is MilkItem:
                    unselectActionButtonsExcept(inventoryMilkButton)
                case is ProjectileItem:
                    unselectActionButtonsExcept(inventoryProjectileButton)
                case is NukeItem:
                    unselectActionButtonsExcept(inventoryNukeButton)
                default:
                    break
                }

                if (action as ItemAction).item.canTargetOthers() {
                    unhighlightTargetPlayers()
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
        let poopSprite = sceneUtils.getPoopNode(at: target.sprite.position)
        let action = sceneUtils.getFartAnimation(0)

        pendingAnimations += [AnimationEvent(poopSprite, action,
            completion: {
                let dmg = poop.victim!.inflict(poop.damage)
                self.showDamage(dmg, node: target)
        })]
    }
    
    /// Animates the obtaining of an item. Item shrinks into character sprite
    /// and disappears. If item is obtained by current player, the item number
    /// will increase in the inventory box.
    ///
    /// :param: item The item that is obtained.
    /// :param: isCurrentPlayer true if item is picked by current player, false
    ///         otherwise.
    func onItemObtained(item: Item, _ isCurrentPlayer: Bool) {
        let animAction = sceneUtils.getObtainItemAnimation()
        item.sprite.runAction(animAction)
        
        if isCurrentPlayer {
            switch item {
            case is MilkItem:
                showInventoryItemIncrease(inventoryMilkButton)
                inventoryMilkButton.increase()
                inventoryMilkButton.alpha = 1
            case is ProjectileItem:
                showInventoryItemIncrease(inventoryProjectileButton)
                inventoryProjectileButton.increase()
                inventoryProjectileButton.alpha = 1
            case is NukeItem:
                showInventoryItemIncrease(inventoryNukeButton)
                inventoryNukeButton.increase()
                inventoryNukeButton.alpha = 1
            default:
                break
            }
        }
    }
    
    /// Animates the spawning of an item.
    ///
    /// :param: node The node with the spawnedItem
    func onItemSpawned(node: TileNode) {
        let animAction = sceneUtils.getSpawnItemAnimation()
        let itemSprite = node.item!.sprite
        itemSprite.size = sceneUtils.tileSize
        itemSprite.position = node.sprite.position
        itemSprite.zPosition = Constants.Z.itemActivated
        itemSprite.runAction(animAction, completion: {
            itemSprite.zPosition = Constants.Z.items
        })
        
        println("Spawned \(node.item!.name)")
        entityLayer.addChild(itemSprite)
    }

    func onPlayerDied(players: [Cat]) {
        for player in players {
            player.getSprite().removeFromParent()
        }
    }
}



private extension GameScene {
    
    func initializeLayers() {
        let background = SKSpriteNode(imageNamed: "Background.png")
        background.size = self.size
        background.zPosition = Constants.Z.background
        self.addChild(background)

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
        bottomBoardLayer.position = CGPoint(x: -384, y: -512)
        gameLayer.addChild(bottomBoardLayer)
    }

    /// Initializes the action buttons for the scene.
    func initializeButtons() {
        let bottomBoard = SKSpriteNode(imageNamed: "BottomBoard.png")
        bottomBoard.size = CGSize(width: self.size.width,
            height: 192)
        bottomBoard.position = CGPoint(x: 384, y: 96)
        bottomBoard.zPosition = -10
        bottomBoardLayer.addChild(bottomBoard)

        buttonLayer.position = Constants.UI.bottomBoard.position
        bottomBoardLayer.addChild(buttonLayer)

        puiButton = SKPuiActionButtonNode(
            actionText: "PUI",
            size: CGSize(width: 90, height: 60),
            buttonAction: { (dir: Direction) in
                self.gameEngine.triggerPuiButtonPressed(dir)
            },
            unselectAction: { self.gameEngine.triggerClearAction() },
            getAvailableDirections: {
                let player = self.gameEngine.currentPlayer
                return self.gameEngine.getAvailablePuiDirections(player)
        })
        puiButton.position = Constants.UI.bottomBoard.puiButtonPosition
        buttonLayer.addChild(puiButton)
        actionButtons.append(puiButton)

        fartButton = SKActionButtonNode(
            actionText: "FART",
            size: CGSize(width: 90, height: 60),
            buttonAction: { self.gameEngine.triggerFartButtonPressed() },
            unselectAction: { self.gameEngine.triggerClearAction() })
        fartButton.position = Constants.UI.bottomBoard.fartButtonPosition
        buttonLayer.addChild(fartButton)
        actionButtons.append(fartButton)

        poopButton = SKActionButtonNode(
            actionText: "POOP",
            size: CGSize(width: 90, height: 60),
            buttonAction: { self.gameEngine.triggerPoopButtonPressed() },
            unselectAction: {
                self.hidePoop()
                self.gameEngine.triggerClearAction()
        })
        poopButton.position = Constants.UI.bottomBoard.poopButtonPosition
        buttonLayer.addChild(poopButton)
        actionButtons.append(poopButton)

        initializeInventory(buttonLayer)
    }
    
    /// Initializes the inventory slot on game scene.
    func initializeInventory(buttonLayer: SKNode) {
        let inventoryLabel = SKLabelNode(text: "Inventory")
        inventoryLabel.fontName = "BubblegumSans-Regular"
        inventoryLabel.fontColor = UIColor.blackColor()
        inventoryLabel.position =
            Constants.UI.bottomBoard.inventoryLabelPosition
        inventoryLabel.verticalAlignmentMode = .Bottom
        buttonLayer.addChild(inventoryLabel)

        inventoryMilkButton = SKInventoryItemNode(
            defaultButtonImage: "Milk.png",
            size: CGSize(width: 60, height: 60),
            buttonAction: {
                self.inventoryButtonSelect(.Milk)
            },
            unselectAction: inventoryButtonUnselect)
        inventoryMilkButton.position = Constants.UI.bottomBoard.milkPosition
        inventoryMilkButton.alpha = 0.5
        actionButtons.append(inventoryMilkButton)
        buttonLayer.addChild(inventoryMilkButton)

        inventoryProjectileButton = SKInventoryItemNode(
            defaultButtonImage: "Projectile.png",
            size: CGSize(width: 60, height: 60),
            buttonAction: {
                self.inventoryButtonSelect(.Projectile)
            },
            unselectAction: inventoryButtonUnselect)
        inventoryProjectileButton.position =
            Constants.UI.bottomBoard.projectilePosition
        inventoryProjectileButton.alpha = 0.5
        actionButtons.append(inventoryProjectileButton)
        buttonLayer.addChild(inventoryProjectileButton)

        inventoryNukeButton = SKInventoryItemNode(
            defaultButtonImage: "Nuke.png",
            size: CGSize(width: 60, height: 60),
            buttonAction: {
                self.inventoryButtonSelect(.Nuke)
            },
            unselectAction: inventoryButtonUnselect)
        inventoryNukeButton.position = Constants.UI.bottomBoard.nukePosition
        inventoryNukeButton.alpha = 0.5
        actionButtons.append(inventoryNukeButton)
        buttonLayer.addChild(inventoryNukeButton)
    }
    
    func inventoryButtonSelect(type: ItemType) {
        self.gameManager[inventoryOf: self.gameEngine.currentPlayer]!.selectedItem = type
        self.gameEngine.triggerItemButtonPressed()
    }
    
    func inventoryButtonUnselect() {
        self.gameManager[inventoryOf: self.gameEngine.currentPlayer]!.selectedItem = nil
        self.gameEngine.triggerClearAction()
        self.unhighlightTargetPlayers()
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
        topBoard.position = CGPoint(x: 384, y: 96)
        topBoard.zPosition = -10
        topBoardLayer.addChild(topBoard)

        let playerInfoLayer = SKNode()
        playerInfoLayer.position = CGPoint(x: 384, y: 110)
        topBoardLayer.addChild(playerInfoLayer)

        let playerInfoNodeSize = CGSize(width: 250, height: 64)
        let playerInfoNodePositions = [
            CGPoint(x: -175, y: 32),
            CGPoint(x: -175, y: -32),
            CGPoint(x: 175, y: 32),
            CGPoint(x: 175, y: -32)
        ]

        for (index, player) in enumerate(gameManager.players.values) {
            let playerInfoNode = SKPlayerInfoNode(player: player,
                size: playerInfoNodeSize, playerName: playerNames[index])
            playerInfoNode.position = playerInfoNodePositions[index]
            playerInfoLayer.addChild(playerInfoNode)
        }

        timerLabel = SKLabelNode(fontNamed: "BubblegumSans-Regular")
        timerLabel.fontColor = UIColor.blackColor()
        playerInfoLayer.addChild(timerLabel)
    }

    /// Initializes the preview nodes.
    ///
    /// :param: currentPlayerNumber The index/id of the currentPlayer.
    func initializePreviewNodes(currentPlayerNumber: Int) {
        previewNode = gameEngine.currentPlayer.previewSprite
        previewNode.size = sceneUtils.tileSize
        previewNode.hidden = true
        entityLayer.addChild(previewNode)
        
        
        /// Initializes the preview node for the poop action.
        poopPreviewNode = sceneUtils.getPoopPreviewNode()
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
    func drawTileEntity(spriteNode: SKSpriteNode, _ tileEntity: TileEntity) {
        let entityNode = tileEntity.getSprite()
        if entityNode is SKSpriteNode {
            (entityNode as SKSpriteNode).size = spriteNode.size
        }
    
        entityNode.hidden = !tileEntity.isVisible()
        entityNode.position = spriteNode.position
        entityLayer.addChild(entityNode)
    }
    
    func endGame() {
        var title: String!
        var message: String!
        if gameEngine.currentPlayer.isDead {
            title = "You lost!"
            message = "Better luck next time!"
        } else {
            title = "You Win!"
            message = "Congratulations! Time for a harder challenge."
            message = message + "\n\(gameManager.playerRanks)"
        }
        
        let endGameAlert = AlertBuilder(title, message,
            AlertAction("Okay", {
                (alertAction) in
                self.applicationUIListener?.endGame()
                return
            }))
        applicationUIListener?.presentAlert(endGameAlert.controller)
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
                validateActionOnMove()
            }
        }
    }
    
    /// Revalidates the current player action after player decides to move to a
    /// new node.
    func validateActionOnMove() {
        let currentPlayer = gameEngine.currentPlayer
        let action = gameManager[actionOf: currentPlayer]
        if let puiAction = action as? PuiAction {
            let moveToPosition = gameManager[moveToPositionOf: currentPlayer]
            let directions = gameEngine.getAvailablePuiDirections(currentPlayer)
            if contains(directions, puiAction.direction) {
                puiButton.resetDirectionNode(puiAction.direction)
            } else {
                puiButton.unselect()
                gameManager[actionOf: currentPlayer] = nil
            }
        }
    }
    
    /// Moves all the players to their respective next positions.
    ///
    /// Notifies the game manager and game engine of movement completion.
    func movePlayers() {
        for (playerName, player) in gameManager.players {
            if let path = gameEngine.executePlayerMove(player) {
                if path.count == 0 {
                    continue
                }
                runAnimation(player.getSprite(),
                    action: sceneUtils.getTraverseAnim(path, 0.25),
                    completion: nil)
            }
        }
    }
    
    func deconflictPlayer() {
        for (playerName, player) in gameManager.players {
            if let path = gameEngine.executePlayerDeconflict(player) {
                runAnimation(player.getSprite(),
                    action: sceneUtils.getTraverseAnim(path, 0.25),
                    completion: nil)
            }
        }
    }

    /// Animates the pui action of the given player in the given direction.
    ///
    /// :param: player The cat that is performing the pui action.
    /// :param: direction The direction to pui in.
    func animatePuiAction(player: Cat, direction: Direction) {
        let startNode = gameManager[moveToPositionOf: player]!
        let path = gameEngine.pathOfPui(startNode, direction: direction)
        var victimPlayer: Cat?

        if let node = path.last {
            if let player = gameEngine.playerMoveToNodes[node.position] {
                victimPlayer = player
            }
        }

        let pui = sceneUtils.getPuiNode(direction)
        let action = sceneUtils.getTraverseAnim(path, 0.15)
        pui.position = startNode.sprite.position
        entityLayer.addChild(pui)
        runAnimation(pui, action: action, completion: {
            pui.removeFromParent()
            if victimPlayer != nil {
                victimPlayer!.inflict(player.puiDmg)
                self.showDamage(player.puiDmg, node: path.last!)
                println("\(player.name) pui on \(victimPlayer!.name) with" +
                    "\(player.puiDmg) damage.")
            }
        })
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

                if let player = gameEngine.playerMoveToNodes[node.position] {
                    victimPlayer = player
                }

                let fart = sceneUtils.getFartNode(at: node.sprite.position)
                let action = sceneUtils.getFartAnimation(timeInterval)
                entityLayer.addChild(fart)
                
                runAnimation(fart, action: action, completion: {
                    fart.removeFromParent()
                    if victimPlayer != nil {
                        let dmg = victimPlayer!.inflict(player.fartDmg)
                        self.showDamage(dmg, node: node)
                        println("\(player.name) fart on \(victimPlayer!.name)" +
                            " with \(player.fartDmg) damage.")
                    }
                })
            }
        }
    }
    
    /// Animates the item action of the given player.
    ///
    /// :param: player The cat that is performing the action.
    /// :param: action ItemAction used
    func animateItemAction(player: Cat, action: ItemAction) {
        if player.name == gameEngine.currentPlayer.name {
            switch action.item {
            case is MilkItem:
                inventoryMilkButton.decrease()
            case is ProjectileItem:
                inventoryProjectileButton.decrease()
            case is NukeItem:
                inventoryNukeButton.decrease()
            default:
                break
            }
        }

        let itemSprite = action.item.sprite
        let tileNode = gameManager[moveToPositionOf: player]!
        let targetPlayer = action.targetPlayer
        itemSprite.size = tileNode.sprite.size
        itemSprite.zPosition = Constants.Z.itemActivated
        itemSprite.position = tileNode.sprite.position
        var completion: (() -> Void)?
        
        var animAction: SKAction!
        
        if gameManager.samePlayer(player, targetPlayer) {
            animAction = sceneUtils.getPassiveItemUsedAnimation()
            if let item = action.item as? NukeItem {
                soundPlayer.playNuke()
                completion = {
                    for player in self.gameManager.players.values {
                        let dmg = player.inflict(Constants.itemEffect.nukeDmg)
                        self.showDamage(dmg,
                            node: self.gameManager[moveToPositionOf: player]!)
                    }
                }
            } else if let item = action.item as? MilkItem {
                soundPlayer.playMilk()
                completion = {
                    self.showHeal(Constants.itemEffect.milkHpIncreaseEffect,
                        node: self.gameManager[moveToPositionOf: player]!)
                }
            }
        } else {
            let dest = action.targetNode!.sprite.position
            let v = SceneUtils.vector(tileNode.sprite.position, dest)
            animAction = sceneUtils.getAggressiveItemUsedAnimation(v)
            soundPlayer.playBall()
            if let item = action.item as? ProjectileItem {
                completion = {
                    let dmg = targetPlayer.inflict(Constants.itemEffect.projectileDmg)
                    self.showDamage(dmg,
                        node: self.gameManager[moveToPositionOf: targetPlayer]!)
                }
            }
        }
        entityLayer.addChild(itemSprite)
        
        runAnimation(itemSprite, action: animAction, completion: {
            itemSprite.removeFromParent()
            completion?()
        })
    }

    /// Performs the respective actions for each player.
    func performActions() {
        for (playerName, player) in gameManager.players {
            let path = gameEngine.executePlayerDeconflict(player)
            let action = gameEngine.executePlayerAction(player)
            
            if path == nil && action != nil  {
                println(action)
                switch action!.actionType {
                case .Pui:
                    let direction = (action! as PuiAction).direction
                    animatePuiAction(player, direction: direction)
                    soundPlayer.playPui()
                case .Fart:
                    animateFartAction(player)
                    soundPlayer.playFart()
                case .Poop:
                    soundPlayer.playPoopArm()
                case .Item:
                    animateItemAction(player, action: action! as ItemAction)
                }
            }
        }
    }

    /// Performs the animations for each event, such as stepping on poop.
    func performPendingAnimations() {
        for event in pendingAnimations {
            entityLayer.addChild(event.sprite)
            
            soundPlayer.playPoop()
            runAnimation(event.sprite,
                action: event.action,
                completion: {
                    event.sprite.removeFromParent()
                    event.completion?()
            })
        }
        pendingAnimations.removeAll(keepCapacity: false)
    }
    
    func runDummyAnimation() {
        let node = SKLabelNode(text: "")
        entityLayer.addChild(node)
        runAnimation(node,
            action: SKAction.moveByX(1, y: 1, duration: 0.25),
            completion: {
                node.removeFromParent()
        })
    }
    
    /// Central method for running state-sensitive animations
    func runAnimation(sprite: SKNode, action: SKAction,
        completion: (() -> ())?) {
            sprite.runAction(action, completion: {
                completion?()
                self.animationEnded()
            })
            animationCount++
    }
    
    func animationEnded() {
        if --animationCount == 0 {
            gameEngine.triggerAnimationEnded()
        }
    }

    /// Shows the health awarded on the TileNode of the receiving player.
    ///
    /// :param: health The amount of health awarded.
    /// :param: node The TileNode of the receiving player.
    func showHeal(health: Int, node: TileNode) {
        showDamage(-health, node: node)
    }

    /// Show the damage dealt on the TileNode of the victim player.
    ///
    /// :param: damange The amount of damage dealt.
    /// :param: node The TileNode of the victim player.
    func showDamage(damage: Int, node: TileNode) {
        let damageNode = sceneUtils.getDamageLabelNode(damage)
        damageNode.position = node.sprite.position
        entityLayer.addChild(damageNode)

        runAnimation(damageNode,
            action: sceneUtils.getDamageLabelAnimation(),
            completion: {
                damageNode.removeFromParent()
        })
    }

    /// Show an increase in inventory for that item.
    ///
    /// :param: inventory The inventory of the item.
    func showInventoryItemIncrease(inventory: SKNode) {
        let additionNode = sceneUtils.getDamageLabelNode(-1)
        additionNode.position = inventory.position
        buttonLayer.addChild(additionNode)
        
        runAnimation(additionNode,
            action: sceneUtils.getNumberChangeAnimation(30),
            completion: {
                additionNode.removeFromParent()
        })
    }

    /// Enables all the action buttons.
    func enableActionButtons() {
        for button in actionButtons {
            button.isEnabled = true
        }
        let player = gameEngine.currentPlayer
        if gameManager[inventoryOf: player]?.count(.Milk) == 0 {
            inventoryMilkButton.isEnabled = false
            inventoryMilkButton.alpha = 0.5
        }
        if gameManager[inventoryOf: player]?.count(.Projectile) == 0 {
            inventoryProjectileButton.isEnabled = false
            inventoryProjectileButton.alpha = 0.5
        }
        if gameManager[inventoryOf: player]?.count(.Nuke)  == 0 {
            inventoryNukeButton.isEnabled = false
            inventoryNukeButton.alpha = 0.5
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

    /// Wiggles the current player's cat during the player action state so that 
    /// the current player's cat can be easily identified.
    func wiggleCurrentPlayer() {
        let duration: NSTimeInterval = 0.5
        let angle = CGFloat(M_PI_4 / Double(4))
        let angle_2 = angle / 2

        let rotateFromCenterToRight =
            SKAction.rotateByAngle(angle_2, duration: duration / 2)
        let rotateFromRightToLeft =
            SKAction.rotateByAngle(-angle, duration: duration)
        let rotateFromLeftToCenter =
            SKAction.rotateByAngle(angle_2, duration: duration / 2)
        let rotateSequence = SKAction.sequence([
            rotateFromCenterToRight,
            rotateFromRightToLeft,
            rotateFromLeftToCenter
        ])
        let rotateAnimation = SKAction.repeatActionForever(rotateSequence)

        gameEngine.currentPlayer.getSprite()
            .runAction(rotateAnimation, withKey: "wiggle")

    }

    /// Stops wiggling the current player's cat after the player action state
    /// has ended.
    func unwiggleCurrentPlayer() {
        let playerSprite = gameEngine.currentPlayer.getSprite()
        let rotateBack = SKAction.rotateToAngle(0, duration: 0)

        playerSprite.removeActionForKey("wiggle")
        playerSprite.runAction(rotateBack)
    }
    
    /// Hides arrows indicating targetable players for item action.
    func highlightTargetPlayers() {
        let currentPlayer = gameEngine.currentPlayer
        let inventory = gameManager[inventoryOf: currentPlayer]!
        let item = inventory.getItem(inventory.selectedItem!)

        for player in gameManager.players.values {
            let position = player.getSprite().position

            if item.shouldTargetAll() {
                let crosshairSprite = sceneUtils.getCrosshairNode()
                crosshairSprite.position = position
                entityLayer.addChild(crosshairSprite)
                targetPreviewNodes += [crosshairSprite]
            } else if !gameManager.samePlayer(player, currentPlayer) {
                let playerSprite = SKTouchSpriteNode(imageNamed: "DummyTouchTile.png")
                playerSprite.size = (player.getSprite() as SKSpriteNode).size
                playerSprite.position = position
                playerSprite.zPosition = Constants.Z.targetTouchOverlay
                targetPreviewNodes.append(playerSprite)
                entityLayer.addChild(playerSprite)

                let arrowSprite = sceneUtils.getPlayerTargetableArrow(position)
                entityLayer.addChild(arrowSprite)
                
                targetPreviewNodes += [arrowSprite]
                playerSprite.setTouchObserver({
                    self.gameEngine.triggerTargetPlayerChanged(player)
                    self.crosshairNode.position = position
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
