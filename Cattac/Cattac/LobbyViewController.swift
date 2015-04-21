/*
    Cattac's lobby view controller
*/

import UIKit

class LobbyViewController: UIViewController {
    
    let levelGenerator = LevelGenerator.sharedInstance
    var level: GameLevel!
    var playerNumber: Int!
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinLobby()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
            }
    }
    
    func startGame() {
        self.performSegueWithIdentifier("gameStartSegue", sender: nil)
    }
    
    func initiateGameStart() {
        level = levelGenerator.generateBasic()
        
        gameConnectionManager.sendLevel(level)
        
        startGame()
    }
    
    func joinLobby() {
        gameConnectionManager.joinLobby(self)
    }
    
    func waitForGameStart() {
        gameConnectionManager.waitForGameStart(self)
    }
}