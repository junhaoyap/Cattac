

import UIKit

class LevelDesignerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "designGameStartSegue" {
            if let destinationVC = segue.destinationViewController
                as? GameViewController {
                    // TODO: Make a level with the collection view controller
                    // and send it via segue and as single player
                    // let level = levelGenerator.generateBasic()
                    // destinationVC.level = level
            }
        }
    }

    @IBAction func playPressed(sender: UIButton) {
        self.performSegueWithIdentifier("designGameStartSegue", sender: self)
    }

    @IBAction func savePressed(sender: UIButton) {
        // TODO: Deal with saving
        println("save")
    }

    @IBAction func loadPressed(sender: UIButton) {
        // TODO: Deal with loading
        println("load")
    }

    @IBAction func controlPressed(sender: UIButton) {
        // TODO: Can be any of the buttons, check which one is pressed

        println("control pressed")
    }
}
