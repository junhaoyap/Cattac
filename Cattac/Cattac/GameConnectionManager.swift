/*
    Based upon the ConnectionManager, used for things pertaining directly
    for Cattac
*/

class GameConnectionManager {
    
    let connectionManager: ConnectionManager!
    
    init(urlProvided: String) {
        connectionManager = ConnectionManager(firebase: urlProvided)
    }
    
    func readOnce(childUrl: String, onComplete: (FDataSnapshot) -> ()) {
        connectionManager.readOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot as FDataSnapshot)
        })
    }
    
    func overwrite(childUrl: String, data: [String: AnyObject]) {
        connectionManager.overwrite(childUrl, data: data)
    }
    
    func update(childUrl: String, data: [String: AnyObject]) {
        connectionManager.update(childUrl, data: data)
    }
    
    func watchUpdateOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchUpdateOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchUpdate(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchUpdate(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchNewOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchNewOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchNew(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchNew(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func createUser(email: String, password: String,
        onComplete: (NSError!, [NSObject: AnyObject]!) -> ()) {
            connectionManager.createUser(email, password: password, onComplete: {
                error, result in
                
                onComplete(error, result)
            })
    }
    
    func authUser(email: String, password: String,
        onComplete: (NSError!, AnyObject) -> ()) {
            connectionManager.authUser(email, password: password, onComplete: {
                error, authdata in
                
                onComplete(error, authdata)
            })
    }
    
    func getAuthId() -> String {
        return connectionManager.getAuthId()
    }
    
    func append(childUrl: String) -> ConnectionManager {
        return connectionManager.append(childUrl)
    }
    
    func removeAllObservers() {
        connectionManager.removeAllObservers()
    }
    
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
    
    func updateServer(playerNumber: Int, currentTile: TileNode,
        moveToTile: TileNode, action: Action?, number: Int) {
            let playerMoveUpdateRef = connectionManager
                .append(Constants.Firebase.nodeGames)
                .append(Constants.Firebase.nodeGame)
                .append(Constants.Firebase.nodePlayers)
                .append("\(playerNumber)")
                .append(Constants.Firebase.nodePlayerMovements)
            
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
                    Constants.Firebase.keyAttkType: action!.actionType.description,
                    Constants.Firebase.keyAttkDir: action!.direction.description,
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
}
