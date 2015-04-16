/*
    Cattac's game difficulty view controller
*/

import UIKit

class GameDifficultyViewController: UIViewController {
    let ref = Firebase(url: Constants.Firebase.baseUrl)
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
}