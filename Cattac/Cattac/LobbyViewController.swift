/*
    Cattac's lobby view controller
*/

import UIKit

class LobbyViewController: UIViewController {
    
    private let ref = ConnectionManager(urlProvided: Constants.Firebase.baseUrl)
    
    let levelGenerator = LevelGenerator.sharedInstance
    var level: GameLevel!
    var playerNumber: Int!
    
    var gameRef: Firebase {
        return ref.append(Constants.Firebase.nodeGames + "/" +
            Constants.Firebase.nodeGame)
    }
    
    var lobbyRef: Firebase {
        return gameRef.childByAppendingPath(Constants.Firebase.nodeLobby)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinLobby()
    }
    
    func joinLobby() {
        lobbyRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            let lastActiveTimeString = snapshot.value["lastActive"] as? String
            let lastActiveTime = lastActiveTimeString == nil ?
                nil : DateUtils.dateFormatter.dateFromString(lastActiveTimeString!)
            
            let currentTime = DateUtils.dateFormatter.stringFromDate(NSDate())
            
            if lastActiveTime == nil || DateUtils.isMinutesBeforeNow(lastActiveTime!, minutes: 1) {
                self.lobbyRef.setValue([
                    "lastActive": currentTime,
                    Constants.Firebase.nodePlayers: [
                        self.ref.getAuthId(), "", "", ""
                    ]
                ])
                self.playerNumber = 1
                self.waitForGameStart()
            } else {
                var numberOfPlayers = 1
                let players = snapshot.value.objectForKey(Constants.Firebase.nodePlayers)! as [String]
                for player in players {
                    if !player.isEmpty {
                        numberOfPlayers++
                    }
                }
                self.playerNumber = numberOfPlayers
                
                let playerRef = self.lobbyRef.childByAppendingPath(Constants.Firebase.nodePlayers)
                    .childByAppendingPath("\(numberOfPlayers - 1)")
                playerRef.setValue(self.ref.getAuthId())
                
                self.lobbyRef.updateChildValues(["lastActive": currentTime])
                
                if numberOfPlayers == 4 {
                    self.initiateGameStart()
                } else {
                    self.waitForGameStart()
                }
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gameStartSegue" {
            if let destinationVC = segue.destinationViewController as? GameViewController {
                destinationVC.level = level
                destinationVC.playerNumber = playerNumber
                destinationVC.multiplayer = true
            }
        } else if segue.identifier == "waitGameStartSegue" {
            if let destinationVC = segue.destinationViewController as? GameViewController {
                destinationVC.level = level
                destinationVC.playerNumber = playerNumber
                destinationVC.multiplayer = true
            }
        }
    }
    
    func initiateGameStart() {
        level = levelGenerator.generateBasic()
        gameRef.updateChildValues([
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
        let gameLevelRef = gameRef.childByAppendingPath(Constants.Firebase.nodeGameLevel)
        
        gameLevelRef.observeSingleEventOfType(.ChildChanged, withBlock: {
            snapshot in
            gameLevelRef.observeSingleEventOfType(.Value, withBlock: {
                gameSnapshot in
                
                self.level = self.levelGenerator.createGame(fromSnapshot: gameSnapshot)
                
                self.performSegueWithIdentifier("waitGameStartSegue", sender: nil)
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