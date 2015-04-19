/*
    Cattac's menu view controller
*/

import UIKit

class MenuViewController: UIViewController {
    
    let gameConnectionManager = GameConnectionManager(urlProvided: Constants.Firebase.baseUrl)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMeowsAndDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func getMeowsAndDisplay() {
        let uid = self.gameConnectionManager.getAuthId()
        
        gameConnectionManager.readOnce(Constants.Firebase.nodeMeows + "/" + uid,
            onComplete: {
                snapshot in
                
                let myNumberOfMeows = snapshot.value["numberOfMeows"]

                if myNumberOfMeows == nil {
                    self.gameConnectionManager.setInitialMeows()
                } else {
                    // TODO: Display it somewhere rather than just
                    // printing it
                    println("I has meows:")
                    println(myNumberOfMeows)
                }
        })
    }
}