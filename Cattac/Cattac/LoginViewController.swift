/*
    Cattac's login view controller
*/

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginUsername: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    let gameConnectionManager = GameConnectionManager(urlProvided:
        Constants.Firebase.baseUrl
    )
    
    let backgroundMusicPlayer = MusicPlayer.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundMusicPlayer.playBackgroundMusic()
        
        // For testing and demo purposes only
//        gameConnectionManager.autoLogin1(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func presentMenuView() {
        self.performSegueWithIdentifier(
            Constants.Segues.loginToMenuSegueIdentifier, sender: nil
        )
    }
    
    func login(email: String, password: String) {
        gameConnectionManager.login(email, password: password, theSender: self)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        let email = loginUsername.text
        let password = loginPassword.text
        
        if (email.isEmpty || password.isEmpty) {
            println("email or password is empty")
            return
        }
        
        login(email, password: password)
    }
}