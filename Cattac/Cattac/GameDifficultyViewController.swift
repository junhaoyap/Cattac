/*
    Cattac's game difficulty view controller
*/

import UIKit

class GameDifficultyViewController: UIViewController {
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
    let levelGenerator = LevelGenerator.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue,
        sender: AnyObject?) {
            if segue.identifier == "bypassSegue" {
                if let destinationVC = segue.destinationViewController
                    as? GameViewController {
                        
                    let level = levelGenerator.generateBasic()
                    destinationVC.level = level
                }
            }
    }

    @IBAction func unwindToGameDifficultyView(segue: UIStoryboardSegue) {
        // This is the view controller that the game will unwind to
        // when the game has ended or when the player quits the game
    }
}