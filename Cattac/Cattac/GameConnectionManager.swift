/*
    Based upon the ConnectionManager, used for things pertaining directly
    for Cattac
*/

import Firebase

class GameConnectionManager {
    let stringUtils = StringUtils()
    let connectionManager: ConnectionManager
    private var observerReferences: [Int: ObserverReference]
    private var dropObserverReferences: [Int: ObserverReference]
    
    init(urlProvided: String) {
        connectionManager = ConnectionManager(firebase: urlProvided)
        observerReferences = [:]
        dropObserverReferences = [:]
    }
    
    // MARK: LoginViewController

    func autoLogin1(theSender: AnyObject) {
        let sender = theSender as! LoginViewController
        
        connectionManager.authUser(Constants.AutoAccount.username1,
            password: Constants.AutoAccount.password1,
            onComplete: {
                error, authData in
                if error != nil {
                    print(error)
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    
                    sender.presentMenuView()
                }
        })
    }
    
    func autoLogin2(theSender: AnyObject) {
        let sender = theSender as! LoginViewController
        
        connectionManager.authUser(Constants.AutoAccount.username2,
            password: Constants.AutoAccount.password2,
            onComplete: {
                error, authData in
                if error != nil {
                    print(error)
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    
                    sender.presentMenuView()
                }
        })
    }
    
    func autoLogin3(theSender: AnyObject) {
        let sender = theSender as! LoginViewController
        
        connectionManager.authUser(Constants.AutoAccount.username3,
            password: Constants.AutoAccount.password3,
            onComplete: {
                error, authData in
                if error != nil {
                    print(error)
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    
                    sender.presentMenuView()
                }
        })
    }
    
    func autoLogin4(theSender: AnyObject) {
        let sender = theSender as! LoginViewController
        
        connectionManager.authUser(Constants.AutoAccount.username4,
            password: Constants.AutoAccount.password4,
            onComplete: {
                error, authData in
                if error != nil {
                    print(error)
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    
                    sender.presentMenuView()
                }
        })
    }
    
    func login(email: String, password: String, theSender: AnyObject) {
        let sender = theSender as! LoginViewController
        
        connectionManager.authUser(email, password: password) {
            error, authData in
            if (error != nil) {
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch (errorCode) {
                    case .UserDoesNotExist:
                        self.createAUser(email, aPassword: password)
                        self.createUsername(email)
                        
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
                        print("Invalid Email")
                        
                        break
                    case .InvalidPassword:
                        print("Invalid Password")
                        
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
                    print("Error creating user")
                } else {
                    let uid = result["uid"] as? String
                    print("Successfully created user account: \(uid)")
                }
        })
    }
    
    func createUsername(anEmail: String) {
        let uid = connectionManager.getAuthId()
        
        let usernameData = [
            uid: stringUtils.getNameFromEmail(anEmail)
        ]
        
        connectionManager.update("", data: usernameData)
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
        let sender = theSender as! MenuViewController
        
        let uid = connectionManager.getAuthId()
        
        connectionManager.readOnce(Constants.Firebase.nodeMeows + "/" + uid,
            onComplete: {
                theSnapshot in
                
                let snapshot = theSnapshot as! FDataSnapshot
                
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
    
    func getName(theSender: AnyObject) {
        
        let uid = connectionManager.getAuthId()
        
        connectionManager.readOnce("", onComplete: {
            theSnapshot in
            
            let snapshot = theSnapshot as! FDataSnapshot
            
            let myUsername = snapshot.value.objectForKey(uid) as? String
            
            if myUsername == nil {
                let email = self.connectionManager.getEmail()
                
                let usernameToWrite = self.stringUtils.getNameFromEmail(email)
                
                self.createUsername(email)
                
                print(usernameToWrite)
            } else {
                print(myUsername)
            }
        })
    }
    
    // MARK: LobbyViewController
    
    func joinLobby(theSender: AnyObject) {
        let sender = theSender as! LobbyViewController
        
        let lobbyRef = connectionManager.append(
            Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame + "/" +
            Constants.Firebase.nodeLobby
        )
        
        let uid = connectionManager.getAuthId()
        
        lobbyRef.readOnce("", onComplete: {
            theSnapshot in
            
            let snapshot = theSnapshot as! FDataSnapshot
            
            let lastActiveTimeString = snapshot.value.objectForKey(
                Constants.Firebase.keyTime) as? String
            
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
                    self.waitPlayerName(theSender)
                    sender.waitForGameStart()
            } else {
                var numberOfPlayers = 1
                
                let players = snapshot.value.objectForKey(
                    Constants.Firebase.nodePlayers)! as! [String]
                
                for player in players {
                    if !player.isEmpty {
                        numberOfPlayers++
                    }
                }
                
                _ = players.count
                
                self.waitPlayerName(theSender)
                
                sender.playerNumber = numberOfPlayers
                print(sender.playerNumber)
                
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
    
    func waitPlayerName(theSender: AnyObject) {
        let sender = theSender as! LobbyViewController
        
        let lobbyRef = connectionManager.append(
            Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame + "/" +
            Constants.Firebase.nodeLobby
        )
        
        lobbyRef.watchNew("", onComplete: {
            aSnapshot in
            
            lobbyRef.readOnce("", onComplete: {
                theSnapshot in
                
                let snapshot = theSnapshot as! FDataSnapshot
                
                let playerNames = snapshot.value.objectForKey(
                    Constants.Firebase.nodePlayers
                    ) as? [String]
                
                if playerNames != nil {
                    for i in 0...3 {
                        let playerId = playerNames![i]
                        
                        self.connectionManager.readOnce("", onComplete: {
                            secondSnapshot in
                            
                            let thisSnapshot = secondSnapshot as! FDataSnapshot
                            
                            let playerName = thisSnapshot.value.objectForKey(
                                playerId
                                ) as? String
                            
                            if playerName == "" || playerName == nil {
                                // do nothing, let it stay as 
                                // "awaiting player..."
                            } else {
                                switch i {
                                case 0:
                                    sender.playerNames[0] = playerName!
                                    sender.playerOneName.text = playerName
                                case 1:
                                    sender.playerNames[1] = playerName!
                                    sender.playerTwoName.text = playerName
                                case 2:
                                    sender.playerNames[2] = playerName!
                                    sender.playerThreeName.text = playerName
                                case 3:
                                    sender.playerNames[3] = playerName!
                                    sender.playerFourName.text = playerName
                                default:
                                    break
                                }
                            }
                        })
                    }
                }
            })
        })
        
        lobbyRef.watchUpdate("", onComplete: {
            aSnapshot in
            
            lobbyRef.readOnce("", onComplete: {
                theSnapshot in
                
                let snapshot = theSnapshot as! FDataSnapshot
                
                let playerNames = snapshot.value.objectForKey(
                    Constants.Firebase.nodePlayers
                    ) as? [String]
                
                if playerNames != nil {
                    for i in 0...3 {
                        let playerId = playerNames![i]
                        
                        self.connectionManager.readOnce("", onComplete: {
                            secondSnapshot in
                            
                            let thisSnapshot = secondSnapshot as! FDataSnapshot
                            
                            let playerName = thisSnapshot.value.objectForKey(
                                playerId
                                ) as? String
                            
                            if playerName == "" || playerName == nil {
                                // do nothing, let it stay as
                                // "awaiting player..."
                            } else {
                                switch i {
                                case 0:
                                    sender.playerNames[0] = playerName!
                                    sender.playerOneName.text = playerName
                                case 1:
                                    sender.playerNames[1] = playerName!
                                    sender.playerTwoName.text = playerName
                                case 2:
                                    sender.playerNames[2] = playerName!
                                    sender.playerThreeName.text = playerName
                                case 3:
                                    sender.playerNames[3] = playerName!
                                    sender.playerFourName.text = playerName
                                default:
                                    break
                                }
                            }
                        })
                    }
                }
            })
        })
    }
    
    func sendLevel(aLevel: GameLevel) {
        let gameRef = connectionManager.append(
            Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame
        )
        
        let playerTurnInfo = [
            Constants.Firebase.nodePlayerMovements:"",
            Constants.Firebase.nodePlayerDropped:""
        ]
        
        gameRef.overwrite("", data:
            [
                "hasGameStarted": 1,
                Constants.Firebase.nodeGameLevel: aLevel.compress(),
                Constants.Firebase.nodeSpawnedItems: "",
                Constants.Firebase.nodePlayers: [
                    "1": playerTurnInfo,
                    "2": playerTurnInfo,
                    "3": playerTurnInfo,
                    "4": playerTurnInfo
                ]
            ]
        )
    }
    
    func waitForGameStart(theSender: AnyObject) {
        let sender = theSender as! LobbyViewController
        
        let gameRef = connectionManager.append(
            Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame
        )
        
        gameRef.watchUpdateOnce(Constants.Firebase.nodeGameLevel, onComplete: {
            snapshot in
            
            gameRef.readOnce(Constants.Firebase.nodeGameLevel,
                onComplete: {
                    gameSnapshot in
                    
                    sender.level = sender.levelGenerator
                        .createGame(fromSnapshot: gameSnapshot as! FDataSnapshot)
                    
                    sender.startGame()
            })
        })
    }
    
    // MARK: GameEngine
    
    func updateServer(playerNumber: Int, currentTile: TileNode,
        moveToTile: TileNode, action: Action?, number: Int, targetNum: Int) {
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
                let itemAction = action as? ItemAction
                
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
                        targetNode != nil ? targetNode!.position.col : 0,
                    Constants.Firebase.keyItemRow:
                        targetNode != nil ? targetNode!.position.row : 0,
                    Constants.Firebase.keyItemCol:
                        targetNode != nil ? targetNode!.position.col : 0,
                    Constants.Firebase.keyItemName:
                        itemAction != nil ? itemAction!.item.name : "",
                    Constants.Firebase.keyItemVictim: targetNum
                ]
            }
            
            playerMoveUpdateRef.update("", data: [
                "\(number)": moveData
                ]
            )
    }
    
    func dropPlayer(playerNum: Int) {
        let playerRef = connectionManager
            .append(Constants.Firebase.nodeGames)
            .append(Constants.Firebase.nodeGame)
            .append(Constants.Firebase.nodePlayers)
            .append("\(playerNum)")
        playerRef.update("",
            data: [Constants.Firebase.nodePlayerDropped: DateUtils.nowString()])
    }
    
    func sendSpawnedItem(itemNum: Int, item: Item, node: TileNode) {
        let playerRef = connectionManager
            .append(Constants.Firebase.nodeGames)
            .append(Constants.Firebase.nodeGame)
            .append(Constants.Firebase.nodeSpawnedItems)
        playerRef.update("",
            data: ["\(itemNum)": [
                Constants.Firebase.keyItemRow: node.position.row,
                Constants.Firebase.keyItemCol: node.position.col,
                Constants.Firebase.keyItemName: item.name
            ]])
    }
    
    func registerPlayerWatcher(playerNum: Int,
        completion: (data: FDataSnapshot, playerNum: Int) -> Void) {
            
            let playerMovementWatcherRef = connectionManager
                .append(Constants.Firebase.nodeGames)
                .append(Constants.Firebase.nodeGame)
                .append(Constants.Firebase.nodePlayers)
                .append("\(playerNum)")
                .append(Constants.Firebase.nodePlayerMovements)
            
            let obsvRef = playerMovementWatcherRef.watchNew("", onComplete: {
                theSnapshot in
                
                let snapshot = theSnapshot as! FDataSnapshot
                completion(data: snapshot, playerNum: playerNum)
            })
            observerReferences[playerNum] = obsvRef
    }
    
    func registerSpawnedItemWatcher(completion: (FDataSnapshot) -> Void) {
            
            let playerMovementWatcherRef = connectionManager
                .append(Constants.Firebase.nodeGames)
                .append(Constants.Firebase.nodeGame)
                .append(Constants.Firebase.nodeSpawnedItems)
            
            playerMovementWatcherRef.watchNew("", onComplete: {
                theSnapshot in
                
                let snapshot = theSnapshot as! FDataSnapshot
                completion(snapshot)
            })
    }
    
    func unregisterPlayerWatcher(playerNum: Int) {
        print("unregistered \(playerNum)")
        observerReferences[playerNum]?.unregister()
    }
}
