import UIKit

class LevelDesignerViewController: UIViewController {

    private var gridViewController: GridViewController!
    private var currentPaletteButton: UIButton!
    private let selection = UIImageView(image: UIImage(named: "ButtonSelect.png"))

    override func viewDidLoad() {
        super.viewDidLoad()

        let fortressButton: UIButton = self.view.viewWithTag(1) as UIButton
        setPaletteButton(fortressButton)

        self.view.addSubview(selection)
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
                    let level = BasicLevel()
                    level.grid = gridViewController.grid
                    level.grid.constructGraph()

                    for indexPath in gridViewController.wallLocations.keys {
                        let tileNodeToRemove = level.grid[indexPath.section,
                                                          indexPath.row]!
                        level.grid.removeNodeFromGraph(tileNodeToRemove)
                    }

                    destinationVC.level = level
            }
        } else if segue.identifier == "gridContainer" {
            self.gridViewController = segue.destinationViewController
                as GridViewController
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
        setPaletteButton(sender)
    }

    private func setPaletteButton(button: UIButton) {
        gridViewController?.setCurrentAction(button.currentTitle!)

        currentPaletteButton?.alpha = 0.5
        currentPaletteButton = button
        currentPaletteButton?.alpha = 1

        selection.frame = CGRectMake(
            button.frame.minX - 10,
            button.frame.minY - 10,
            button.frame.width + 20,
            button.frame.height + 20
        )
    }
}
