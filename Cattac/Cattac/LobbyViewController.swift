/*
    Cattac's lobby view controller
*/

import UIKit

class LobbyViewController: UIViewController {
    private let ref = Firebase(url: Constants.Firebase.baseUrl)
    //private var gameStartObserver
    let levelGenerator = LevelGenerator.sharedInstance
    var level: GameLevel!
    var playerNumber: Int!
    
    var gameRef: Firebase {
        return ref.childByAppendingPath(Constants.Firebase.nodeGames)
            .childByAppendingPath(Constants.Firebase.nodeGame)
    }
    
    var lobbyRef: Firebase {
        return gameRef.childByAppendingPath(Constants.Firebase.nodeLobby)
    }
    
    // TODO check if the player who is joining the game has already joined,
    // if not he can join as multiplayer players from the same game and
    // screw the game up, hypothetically speaking shouldn't happen at the moment
    // but we can keep that in view
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
                        self.ref.authData.uid, "", "", ""
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
                playerRef.setValue(self.ref.authData.uid)
                
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
        }
        
        if segue.identifier == "waitGameStartSegue" {
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
    
    func isAfter(dateOne: NSDate, dateTwo: NSDate) -> Bool {
        return dateOne.compare(dateTwo) == NSComparisonResult.OrderedAscending
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}