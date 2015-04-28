/*
    Cattac's lobby view controller
*/

import UIKit

class LobbyViewController: UIViewController {
    @IBOutlet weak var playerOneName: UILabel!
    @IBOutlet weak var playerTwoName: UILabel!
    @IBOutlet weak var playerThreeName: UILabel!
    @IBOutlet weak var playerFourName: UILabel!
    
    let levelGenerator = LevelGenerator.sharedInstance
    var level: GameLevel!
    var playerNumber: Int!
    var playerNames: [String] = ["Grumpy", "Nyan", "Octocat", "Hello Kitty"]
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
    let soundPlayer = SoundPlayer.sharedInstance
    
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
                        destinationVC.playerNames = playerNames
                        destinationVC.unwindIdentifer =
                            "endgameToGameDifficultyViewSegue"
                }
            }
    }
    
    func startGame() {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self,
            selector: Selector("startGameSegue"),
            userInfo: nil,
            repeats: false
        )
    }
    
    func initiateGameStart() {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self,
            selector: Selector("sendLevel"),
            userInfo: nil,
            repeats: false
        )
        
        startGame()
    }
    
    func sendLevel() {
        
        level = levelGenerator.generateBasic()
        
        gameConnectionManager.sendLevel(level)
    }
    
    func startGameSegue() {
        self.performSegueWithIdentifier("gameStartSegue", sender: nil)
    }
    
    func joinLobby() {
        gameConnectionManager.joinLobby(self)
    }
    
    func waitForGameStart() {
        gameConnectionManager.waitForGameStart(self)
    }
    
    @IBAction func grumpyTapped(sender: UIButton) {
        soundPlayer.playGrumpy()
    }
    
    @IBAction func nyanTapped(sender: UIButton) {
        soundPlayer.playNyan()
    }
    
    @IBAction func helloKittyTapped(sender: UIButton) {
        soundPlayer.playHelloKitty()
    }
    
    @IBAction func octoTapped(sender: UIButton) {
        soundPlayer.playOcto()
    }
}