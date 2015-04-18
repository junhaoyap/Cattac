/*
    Cattac's shop view controller
*/

import UIKit

class ShopViewController: UIViewController {
    
    let ref = Firebase(url: "https://torrid-inferno-1934.firebaseio.com/")
    
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