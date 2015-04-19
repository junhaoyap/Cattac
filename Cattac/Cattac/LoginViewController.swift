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
        autoLogin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
    
    func autoLogin() {
        gameConnectionManager.authUser("b@b.com", password: "bbb",
            onComplete: {
                error, authData in
                if error != nil {
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    
                    self.presentMenuView()
                }
        })
    }
    
    func login(email: String, password: String) {
        gameConnectionManager.authUser(email, password: password) {
            error, authData in
            if (error != nil) {
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch (errorCode) {
                    case .UserDoesNotExist:
                        self.createAUser(email, aPassword: password)
                        
                        self.gameConnectionManager.authUser(email,
                            password: password) {
                                error, authData in
                                
                                if (error != nil) {
                                    // do nothing, so many errors just make
                                    // the user click the login button again
                                } else {
                                    self.setInitialMeows()
                                    
                                    self.presentMenuView()
                            }
                        }
                        
                        break
                    case .InvalidEmail:
                        println("Invalid Email")
                        
                        break
                    case .InvalidPassword:
                        println("Invalid Password")
                        
                        break
                    default:
                        break
                    }
                }
            } else {
                self.presentMenuView()
            }
        }
    }
    
    func createAUser(anEmail: String, aPassword: String) {
        gameConnectionManager.createUser(anEmail, password: aPassword,
            onComplete: {
                error, result in
                
                if error != nil {
                    println("Error creating user")
                } else {
                    let uid = result["uid"] as? String
                    println("Successfully created user account: \(uid)")
                }
        })
    }
    
    func setInitialMeows() {
        let uid = self.gameConnectionManager.getAuthId()
        
        let meowsManager = self.gameConnectionManager.append(
            Constants.Firebase.nodeMeows + "/" + uid
        )
        
        let defaultUserMeow = [
            Constants.Firebase.keyMeows : Constants.defaultNumberOfMeows
        ]
        
        meowsManager.overwrite("", data: defaultUserMeow)
    }
    
    func presentMenuView() {
        self.performSegueWithIdentifier(
            Constants.Segues.loginToMenuSegueIdentifier, sender: nil
        )
    }
}