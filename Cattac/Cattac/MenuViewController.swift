/*
    Cattac's menu view controller
*/

import UIKit

class MenuViewController: UIViewController {
    let ref = Firebase(url: "https://torrid-inferno-1934.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let meowsRef = self.ref.childByAppendingPath("usersMeow").childByAppendingPath(self.ref.authData.uid)
        
        meowsRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            let myNumberOfMeows: AnyObject! = snapshot.value["numberOfMeows"]
            
            if myNumberOfMeows == nil {
                let meowsRef = self.ref.childByAppendingPath("usersMeow").childByAppendingPath(self.ref.authData.uid)
                
                var defaultUserMeow = ["numberOfMeows" : Constants.defaultNumberOfMeows]
                
                meowsRef.setValue(defaultUserMeow)
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