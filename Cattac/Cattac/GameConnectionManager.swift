/*
    Based upon the ConnectionManager, used for things pertaining directly
    for Cattac
*/

class GameConnectionManager {
    let connectionManager: ConnectionManager!
    
    init(urlProvided: String) {
        connectionManager = ConnectionManager(firebase: urlProvided)
    }
    
    // MARK: LoginViewController
    
    func autoLogin(theSender: AnyObject) {
        let sender = theSender as LoginViewController
        
        connectionManager.authUser(Constants.AutoAccount.username,
            password: Constants.AutoAccount.password,
            onComplete: {
                error, authData in
                if error != nil {
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    
                    sender.presentMenuView()
                }
        })
    }
    
    func login(email: String, password: String, theSender: AnyObject) {
        let sender = theSender as LoginViewController
        
        connectionManager.authUser(email, password: password) {
            error, authData in
            if (error != nil) {
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch (errorCode) {
                    case .UserDoesNotExist:
                        self.createAUser(email, aPassword: password)
                        
                        self.connectionManager.authUser(email,
                            password: password) {
                                error, authData in
                                
                                if (error != nil) {
                                    // do nothing, so many errors just make
                                    // the user click the login button again
                                } else {
                                    self.setInitialMeows()
                                    
                                    sender.presentMenuView()
                                }
                        }
                        
                        break
                    case .InvalidEmail:
                        println("Invalid Email")
                        
                        break
                    case .InvalidPassword:
                        println("Invalid Password")
                        
                        break
                    default:
                        break
                    }
                }
            } else {
                sender.presentMenuView()
            }
        }
    }
    
    func createAUser(anEmail: String, aPassword: String) {
        connectionManager.createUser(anEmail, password: aPassword,
            onComplete: {
                error, result in
                
                if error != nil {
                    println("Error creating user")
                } else {
                    let uid = result["uid"] as? String
                    println("Successfully created user account: \(uid)")
                }
        })
    }
    
    func setInitialMeows() {
        let uid = connectionManager.getAuthId()
        
        let meowsManager = connectionManager.append(
            Constants.Firebase.nodeMeows + "/" + uid
        )
        
        let defaultUserMeow = [
            Constants.Firebase.keyMeows : Constants.defaultNumberOfMeows
        ]
        
        meowsManager.overwrite("", data: defaultUserMeow)
    }
    
    // MARK: MenuViewController
    
    func getMeows(theSender: AnyObject) {
        let sender = theSender as MenuViewController
        
        let uid = connectionManager.getAuthId()
        
        connectionManager.readOnce(Constants.Firebase.nodeMeows + "/" + uid,
            onComplete: {
                theSnapshot in
                
                let snapshot = theSnapshot as FDataSnapshot
                
                let myNumberOfMeows = snapshot.value.objectForKey(
                    Constants.Firebase.keyMeows) as? Int
                
                if myNumberOfMeows == nil {
                    self.setInitialMeows()
                    
                    sender.numberOfMeows = Constants.defaultNumberOfMeows
                } else {
                    sender.numberOfMeows = myNumberOfMeows!
                }
        })
    }
    
    // MARK: LobbyViewController
    
    func joinLobby(theSender: AnyObject) {
        let sender = theSender as LobbyViewController
        
        let lobbyRef = connectionManager.append(
            Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame + "/" +
            Constants.Firebase.nodeLobby
        )
        
        var uid = connectionManager.getAuthId()
        
        lobbyRef.readOnce("", onComplete: {
            theSnapshot in
            
            let snapshot = theSnapshot as FDataSnapshot
            
            let lastActiveTimeString = snapshot.value[
                Constants.Firebase.keyTime] as? String
            
            let lastActiveTime = lastActiveTimeString == nil ?
                nil : DateUtils.dateFormatter.dateFromString(
                    lastActiveTimeString!
            )
            
            let currentTime = DateUtils.dateFormatter.stringFromDate(NSDate())
            
            if lastActiveTime == nil ||
                DateUtils.isMinutesBeforeNow(lastActiveTime!, minutes: 1) {
                    lobbyRef.overwrite("", data: [
                        Constants.Firebase.keyTime: currentTime,
                        Constants.Firebase.nodePlayers: [
                            uid, "", "", ""
                        ]
                        ])
                    sender.playerNumber = 1
                    sender.waitForGameStart()
            } else {
                var numberOfPlayers = 1
                
                let players = snapshot.value.objectForKey(
                    Constants.Firebase.nodePlayers)! as [String]
                
                for player in players {
                    if !player.isEmpty {
                        numberOfPlayers++
                    }
                }
                
                sender.playerNumber = numberOfPlayers
                
                lobbyRef.update(Constants.Firebase.nodePlayers, data: [
                    "\(numberOfPlayers - 1)": uid
                    ]
                )
                
                lobbyRef.update("", data: [
                    "lastActive": currentTime
                    ]
                )
                
                if numberOfPlayers == 4 {
                    sender.initiateGameStart()
                } else {
                    sender.waitForGameStart()
                }
            }
        })
    }
    
    func sendLevel(aLevel: GameLevel) {
        let gameRef = connectionManager.append(
            Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame
        )
        
        gameRef.overwrite("", data:
            [
                "hasGameStarted": 1,
                Constants.Firebase.nodeGameLevel: aLevel.compress(),
                Constants.Firebase.nodePlayers: [
                    Constants.Firebase.nodePlayerMovements,
                    Constants.Firebase.nodePlayerMovements,
                    Constants.Firebase.nodePlayerMovements,
                    Constants.Firebase.nodePlayerMovements
                ]
            ]
        )
    }
    
    func waitForGameStart(theSender: AnyObject) {
        let sender = theSender as LobbyViewController
        
        let gameRef = connectionManager.append(
            Constants.Firebase.nodeGames + "/" +
                Constants.Firebase.nodeGame
        )
        
        gameRef.watchUpdateOnce("", onComplete: {
            snapshot in
            
            gameRef.readOnce(Constants.Firebase.nodeGameLevel,
                onComplete: {
                    gameSnapshot in
                    
                    sender.level = sender.levelGenerator
                        .createGame(fromSnapshot: gameSnapshot as FDataSnapshot)
                    
                    sender.startGame()
            })
        })
    }
    
    // MARK: GameEngine
    
    func updateServer(playerNumber: Int, currentTile: TileNode,
        moveToTile: TileNode, action: Action?, number: Int) {
            let playerMoveUpdateRef = connectionManager.append(
                Constants.Firebase.nodeGames + "/" +
                Constants.Firebase.nodeGame + "/" +
                Constants.Firebase.nodePlayers + "/" +
                "\(playerNumber)" + "/" +
                Constants.Firebase.nodePlayerMovements
            )
            
            var moveData = [:]
            
            if action == nil {
                moveData = [
                    Constants.Firebase.keyMoveFromRow: currentTile.position.row,
                    Constants.Firebase.keyMoveFromCol: currentTile.position.col,
                    Constants.Firebase.keyMoveToRow: moveToTile.position.row,
                    Constants.Firebase.keyMoveToCol: moveToTile.position.col,
                    Constants.Firebase.keyAttkType: "",
                    Constants.Firebase.keyAttkDir: "",
                    Constants.Firebase.keyAttkRange: "",
                    Constants.Firebase.keyTargetRow: "",
                    Constants.Firebase.keyTargetCol: ""
                ]
            } else {
                let targetNode = action?.targetNode
                
                moveData = [
                    Constants.Firebase.keyMoveFromRow: currentTile.position.row,
                    Constants.Firebase.keyMoveFromCol: currentTile.position.col,
                    Constants.Firebase.keyMoveToRow: moveToTile.position.row,
                    Constants.Firebase.keyMoveToCol: moveToTile.position.col,
                    Constants.Firebase.keyAttkType:
                        action!.actionType.description,
                    Constants.Firebase.keyAttkDir:
                        action!.direction.description,
                    Constants.Firebase.keyAttkRange: action!.range,
                    Constants.Firebase.keyTargetRow:
                        targetNode != nil ? targetNode!.position.row : 0,
                    Constants.Firebase.keyTargetCol:
                        targetNode != nil ? targetNode!.position.col : 0
                ]
            }
            
            playerMoveUpdateRef.update("", data: [
                "\(number)": moveData
                ]
            )
    }
    
    func registerMovementWatcher(playerNumber: Int, theSender: AnyObject) {
        let sender = theSender as GameEngine
        
        let playerMovementWatcherRef = connectionManager
            .append(Constants.Firebase.nodeGames)
            .append(Constants.Firebase.nodeGame)
            .append(Constants.Firebase.nodePlayers)
            .append("\(playerNumber)")
            .append(Constants.Firebase.nodePlayerMovements)
        
        playerMovementWatcherRef.watchNew("", onComplete: {
            theSnapshot in
            
            let snapshot = theSnapshot as FDataSnapshot
            
            let fromRow = snapshot.value.objectForKey(
                Constants.Firebase.keyMoveFromRow) as? Int
            let fromCol = snapshot.value.objectForKey(
                Constants.Firebase.keyMoveFromCol) as? Int
            let moveToRow = snapshot.value.objectForKey(
                Constants.Firebase.keyMoveToRow) as? Int
            let moveToCol = snapshot.value.objectForKey(
                Constants.Firebase.keyMoveToCol) as? Int
            
            let attackType = snapshot.value.objectForKey(
                Constants.Firebase.keyAttkType) as? String
            let attackDir = snapshot.value.objectForKey(
                Constants.Firebase.keyAttkDir) as? String
            let attackDmg = snapshot.value.objectForKey(
                Constants.Firebase.keyAttkDmg) as? Int
            let attackRange = snapshot.value.objectForKey(
                Constants.Firebase.keyAttkRange) as? Int
            
            let player = sender.gameManager[Constants.catArray[playerNumber]]!
            
            sender.gameManager[positionOf: player] = sender.getGrid()[
                fromRow!, fromCol!]
            sender.gameManager[moveToPositionOf: player] = sender.getGrid()[
                moveToRow!, moveToCol!]
            println("\(sender.getPlayer().name)[\(playerNumber)]" +
                " moving to \(moveToRow!),\(moveToCol!)"
            )
            
            if let playerActionType = ActionType.create(attackType!) {
                switch playerActionType {
                case .Pui:
                    let puiDirection = Direction.create(attackDir!)!
                    sender.gameManager[actionOf: player] = PuiAction(direction:
                        puiDirection)
                case .Fart:
                    let fartRange = attackRange!
                    sender.gameManager[actionOf: player] = FartAction(range:
                        fartRange)
                case .Poop:
                    let targetNodeRow = snapshot.value.objectForKey(
                        Constants.Firebase.keyTargetRow) as? Int
                    let targetNodeCol = snapshot.value.objectForKey(
                        Constants.Firebase.keyTargetCol) as? Int
                    let targetNode = sender.getGrid()[targetNodeRow!,
                        targetNodeCol!]!
                    
                    sender.gameManager[actionOf: player] = PoopAction(
                        targetNode: targetNode)
                case .Item:
                    break
                }
                println("\(player.name)[\(playerNumber)]" +
                    " \(playerActionType.description)"
                )
            }
            
            sender.otherPlayersMoved++
            
            if sender.otherPlayersMoved == 3 {
                sender.triggerAllPlayersMoved()
                sender.otherPlayersMoved = 0
            }
        })
    }
}
