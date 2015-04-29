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

class GameViewController: UIViewController, ApplicationUIListener {
    @IBOutlet weak var musicImage: UIButton!
    @IBOutlet weak var soundImage: UIButton!
    
    var scene: GameScene!
    var level: GameLevel!
    var playerNumber: Int = 1
    let levelGenerator = LevelGenerator.sharedInstance
    var multiplayer: Bool = false
    var playerNames: [String] = ["Grumpy", "Nyan", "Octocat", "Hello Kitty"]
    let backgroundMusicPlayer = MusicPlayer.sharedInstance
    let soundPlayer = SoundPlayer.sharedInstance
    
    let soundViewImage = UIImage(named: "Sound")
    let soundCrossedImage = UIImage(named: "SoundCrossed")
    let musicViewImage = UIImage(named: "Music")
    let musicCrossedImage = UIImage(named: "MusicCrossed")

    var unwindIdentifer: String = "endgameToGameDifficultyViewSegue"
    
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
        scene.setUIListener(self)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        if !soundPlayer.shouldPlaySound() {
            soundImage.setImage(soundCrossedImage, forState: .Normal)
        }
        
        if !backgroundMusicPlayer.isCurrentlyPlaying() {
            musicImage.setImage(musicCrossedImage, forState: .Normal)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.scene.removeAllChildren()
        self.scene.removeFromParent()
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
    
    func presentAlert(alert: UIAlertController) {
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func endGame() {
        exitGame(nil)
    }
    
    private func exitGame(action: UIAlertAction!) {
        self.performSegueWithIdentifier(unwindIdentifer, sender: self)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        let quitAlert = AlertBuilder("Quit Game",
            "Are you sure you want to leave the game?",
            AlertAction("Yes", exitGame),
            AlertAction("No", nil))
        
        presentViewController(quitAlert.controller, animated: true,
            completion: nil)
    }
    
    @IBAction func soundButtonPressed(sender: UIButton) {
        if soundPlayer.shouldPlaySound() {
            soundPlayer.stopPlayingSound()
            soundImage.setImage(soundCrossedImage, forState: .Normal)
        } else {
            // !soundPlayer.shouldPlaySound()
            soundPlayer.doPlaySound()
            soundImage.setImage(soundViewImage, forState: .Normal)
        }
    }
    
    @IBAction func musicButtonPressed(sender: UIButton) {
        if backgroundMusicPlayer.isCurrentlyPlaying() {
            backgroundMusicPlayer.stopBackgroundMusic()
            musicImage.setImage(musicCrossedImage, forState: .Normal)
        } else {
            // !backgroundMusicPlayer.isCurrentlyPlaying()
            backgroundMusicPlayer.playBackgroundMusic()
            musicImage.setImage(musicViewImage, forState: .Normal)
        }
    }
}
