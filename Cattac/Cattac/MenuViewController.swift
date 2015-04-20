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
        
        // TODO: Display it somewhere rather than just printing it
        println("I has meows:")
        println(numberOfMeows)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}