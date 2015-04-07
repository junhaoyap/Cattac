/*
    Cattac's game controller, the actual game view
*/

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    
    let ref = Firebase(url: "https://torrid-inferno-1934.firebaseio.com/")
    var scene: GameScene!
    var level: GameLevel!
    var playerNumber: Int!
    let levelGenerator = LevelGenerator.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        scene = GameScene(skView.bounds.size, level)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        /* Start timer */
        NSTimer.scheduledTimerWithTimeInterval(
            1,
            target: self,
            selector: Selector("updateTime"),
            userInfo: nil,
            repeats: true
        )
        
        timerLabel.text = "10"
        
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    @IBAction func puiButtonPressed(sender: AnyObject) {
        scene.gameEngine.trigger("puiButtonPressed")
    }
    
    
    @IBAction func fartButtonPressed(sender: AnyObject) {
        scene.gameEngine.trigger("fartButtonPressed")
    }
    
    
    @IBAction func poopButtonPressed(sender: AnyObject) {
        scene.gameEngine.trigger("poopButtonPressed")
    }
    
    func updateTime() {
        var currentTime = timerLabel.text!.toInt()
        
        if currentTime == 0 {
            // This is where the time for choosing something is over
            // we should move on to the next thing to do?
            
            timerLabel.text = "10"
            scene.gameEngine.nextState()
        } else {
            timerLabel.text = String(currentTime! - 1)
        }
    }
}
