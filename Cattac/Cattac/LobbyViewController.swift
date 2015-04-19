/*
    Cattac's lobby view controller
*/

import UIKit

class LobbyViewController: UIViewController {
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
    let levelGenerator = LevelGenerator.sharedInstance
    var level: GameLevel!
    var playerNumber: Int!
    
    var gameRef: ConnectionManager {
        return gameConnectionManager.append(Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame
        )
    }
    
    var lobbyRef: ConnectionManager {
        return gameRef.append(Constants.Firebase.nodeLobby)
    }
    
    var uid: String {
        return gameConnectionManager.getAuthId()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinLobby()
    }
    
    func joinLobby() {
        lobbyRef.readOnce("", onComplete: {
            theSnapshot in
            
            let snapshot = theSnapshot as FDataSnapshot
            
            let lastActiveTimeString = snapshot.value["lastActive"] as? String
            
            let lastActiveTime = lastActiveTimeString == nil ?
                nil : DateUtils.dateFormatter.dateFromString(
                    lastActiveTimeString!
            )
            
            let currentTime = DateUtils.dateFormatter.stringFromDate(NSDate())
            
            if lastActiveTime == nil ||
                DateUtils.isMinutesBeforeNow(lastActiveTime!, minutes: 1) {
                    self.lobbyRef.overwrite("", data: [
                        "lastActive": currentTime,
                        Constants.Firebase.nodePlayers: [
                            self.uid, "", "", ""
                        ]
                    ])
                    self.playerNumber = 1
                    self.waitForGameStart()
            } else {
                var numberOfPlayers = 1
                let players = snapshot.value.objectForKey(
                    Constants.Firebase.nodePlayers)! as [String]
                
                for player in players {
                    if !player.isEmpty {
                        numberOfPlayers++
                    }
                }
                
                self.playerNumber = numberOfPlayers
                
                self.lobbyRef.update(Constants.Firebase.nodePlayers, data: [
                    "\(numberOfPlayers - 1)": self.uid
                    ]
                )
                
                self.lobbyRef.update("", data: [
                    "lastActive": currentTime
                    ]
                )
                
                if numberOfPlayers == 4 {
                    self.initiateGameStart()
                } else {
                    self.waitForGameStart()
                }
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue,
        sender: AnyObject?) {
            if segue.identifier == "gameStartSegue" {
                if let destinationVC = segue.destinationViewController as?
                    GameViewController {
                        destinationVC.level = level
                        destinationVC.playerNumber = playerNumber
                        destinationVC.multiplayer = true
                }
            } else if segue.identifier == "waitGameStartSegue" {
                if let destinationVC = segue.destinationViewController
                    as? GameViewController {
                        destinationVC.level = level
                        destinationVC.playerNumber = playerNumber
                        destinationVC.multiplayer = true
                }
            }
    }
    
    func initiateGameStart() {
        level = levelGenerator.generateBasic()
        gameRef.overwrite("", data: [
            "hasGameStarted": 1,
            Constants.Firebase.nodeGameLevel: level.compress(),
            Constants.Firebase.nodePlayers: [
                Constants.Firebase.nodePlayerMovements,
                Constants.Firebase.nodePlayerMovements,
                Constants.Firebase.nodePlayerMovements,
                Constants.Firebase.nodePlayerMovements
            ]
        ])
        
        self.performSegueWithIdentifier("gameStartSegue", sender: nil)
    }
    
    func waitForGameStart() {
        let gameLevelRef = gameRef.append(
            Constants.Firebase.nodeGameLevel
        )
        
        gameLevelRef.watchUpdateOnce("", onComplete: {
            snapshot in
            
            gameLevelRef.readOnce("", onComplete: {
                gameSnapshot in
                
                self.level = self.levelGenerator
                    .createGame(fromSnapshot: gameSnapshot as FDataSnapshot)
                
                self.performSegueWithIdentifier("waitGameStartSegue",
                    sender: nil
                )
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}