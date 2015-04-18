/*
    Cattac's menu view controller
*/

import UIKit

class MenuViewController: UIViewController {
    let connectionManager = ConnectionManager(urlProvided: Constants.Firebase.baseUrl)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectionManager.readOnce("usersMeow/" + connectionManager.getAuthId(), onComplete: {
            snapshot in
            
            let myNumberOfMeows: AnyObject! = snapshot.value["numberOfMeows"]
            
            if myNumberOfMeows == nil {
                // TODO EXTRACT INTO CONNECTIONMANAGER
//                let meowsRef = self.ref.childByAppendingPath("usersMeow").childByAppendingPath(self.ref.authData.uid)
//                
//                var defaultUserMeow = ["numberOfMeows" : Constants.defaultNumberOfMeows]
//                
//                meowsRef.setValue(defaultUserMeow)
            } else {
//                println("I has meows:")
//                println(myNumberOfMeows)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}