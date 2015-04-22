/*
    Cattac's game controller, the actual game view
*/

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(
            file, ofType: "sks") {
                var sceneData = NSData(contentsOfFile: path,
                    options: .DataReadingMappedIfSafe, error: nil)!
                
                var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
                
                archiver.setClass(self.classForKeyedUnarchiver(),
                    forClassName: "SKScene")
                
                let scene = archiver.decodeObjectForKey(
                    NSKeyedArchiveRootObjectKey) as GameScene
                
                archiver.finishDecoding()
                
                return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var level: GameLevel!
    var playerNumber: Int = 1
    let levelGenerator = LevelGenerator.sharedInstance
    var multiplayer: Bool = false
    var playerNames: [String] = ["Grumpy", "Nyan", "Octocat", "Hello Kitty"]
    let backgroundMusicPlayer = MusicPlayer.sharedInstance
    let soundPlayer = SoundPlayer.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /// Sprite Kit applies additional optimizations to 
        /// improve rendering performance
        skView.ignoresSiblingOrder = true
        
        // HACKY HACKY
        if !multiplayer {
            playerNames[0] = "You"
        }
        
        scene = GameScene(size: skView.bounds.size, level: level,
            currentPlayerNumber: playerNumber, multiplayer: multiplayer,
            names: playerNames
        )
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        // TODO: Set the initial sound or music vector depending
        // on whether sound player or music player should currently
        // be playing
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scene?.removeAllChildren()
        self.scene?.removeFromParent()
        (self.view as SKView).presentScene(nil)
        self.scene = nil
        self.view.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        let dismissActionHandler = {
            (action: UIAlertAction!) in
            
            self.performSegueWithIdentifier("endgameSegue", sender: self)
        }
        
        let quitAlert = UIAlertController(title: "Quit Game",
            message: "Are you sure you want to leave the game?",
            preferredStyle: .Alert
        )
        
        quitAlert.addAction(UIAlertAction(title: "Yes",
            style: .Default,
            handler: dismissActionHandler
            ))
        
        quitAlert.addAction(UIAlertAction(title: "No",
            style: .Default,
            handler: nil
            ))
        
        presentViewController(quitAlert, animated: true, completion: nil)
    }
    
    @IBAction func soundButtonPressed(sender: UIButton) {
        if soundPlayer.shouldPlaySound() {
            soundPlayer.stopPlayingSound()
        } else {
            // !soundPlayer.shouldPlaySound()
            soundPlayer.doPlaySound()
        }
    }
    
    @IBAction func musicButtonPressed(sender: UIButton) {
        if backgroundMusicPlayer.isCurrentlyPlaying() {
            backgroundMusicPlayer.stopBackgroundMusic()
        } else {
            // !backgroundMusicPlayer.isCurrentlyPlaying()
            backgroundMusicPlayer.playBackgroundMusic()
        }
    }
}
