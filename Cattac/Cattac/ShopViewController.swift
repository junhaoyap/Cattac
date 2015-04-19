/*
    Cattac's shop view controller
*/

import UIKit

class ShopViewController: UIViewController {
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
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