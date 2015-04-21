/*
    Cattac's menu view controller
*/

import UIKit

class MenuViewController: UIViewController {
    
    var numberOfMeows: Int!
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameConnectionManager.getMeows(self)
        
        gameConnectionManager.getName(self)
        
        // TODO: Display the number of meows somewhere and maybe put it
        // as a UILabel somewhere so that gameConnectionManager can change
        // the number depending on what the number actually is
        // once the asynchronous call completes
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}