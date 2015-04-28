import UIKit

class LevelDesignerViewController: UIViewController {

    private var gridViewController: GridViewController!
    private var currentPaletteButton: UIButton!
    private let selection = UIImageView(image: UIImage(named: "ButtonSelect.png"))
    private var gameLevel: GameLevel?
    private var currentLevelName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        gridViewController.wormholeBlueButton =
            self.view.viewWithTag(4) as UIButton
        gridViewController.wormholeOrangeButton =
            self.view.viewWithTag(5) as UIButton

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
                    destinationVC.level = gameLevel!
                    destinationVC.unwindIdentifer =
                        "endgameToLevelDesignerViewSegue"
            }
        } else if segue.identifier == "gridContainer" {
            self.gridViewController = segue.destinationViewController
                as GridViewController
        }
    }

    @IBAction func unwindToLevelDesignerView(segue: UIStoryboardSegue) {
    }

    @IBAction func playPressed(sender: UIButton) {
        gameLevel = createLevel()
        if isValidLevel(gameLevel!.grid) {
            self.performSegueWithIdentifier("designGameStartSegue", sender: self)
        } else {
            showInvalidLevelAlert()
        }
    }

    @IBAction func savePressed(sender: UIButton) {
        var title: String = "Save Level"
        var message: String = ""

        if currentLevelName != nil {
            message = "Replace current level."
        }

        var alert = UIAlertController(title: title, message: nil,
            preferredStyle: UIAlertControllerStyle.Alert)

        alert.addTextFieldWithConfigurationHandler(
            { (textField: UITextField!) -> Void in
                if let name = self.currentLevelName {
                    textField.text = name
                } else {
                    textField.placeholder = "😸😹😺😻😼😽😿🙀😾"
                }
                textField.addTarget(self, action: "textChanged:",
                    forControlEvents: .EditingChanged)
        })

        alert.addAction(UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Save",
            style: UIAlertActionStyle.Default, handler:
            { (action: UIAlertAction!) -> Void in
                var textField = alert.textFields!.first! as UITextField
                Storage.saveLevel(textField.text,
                    levelData: self.createLevel().compress())
                //self.currentFile.text = textField.text
        }))

        if self.currentLevelName == nil {
            (alert.actions[1] as UIAlertAction).enabled = false
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func loadPressed(sender: UIButton) {
        let savedItems = Storage.getSavedLevels()

        let alert = UIAlertController(title: "Load Level", message: nil,
            preferredStyle: UIAlertControllerStyle.Alert)

        for item in savedItems {
            alert.addAction(UIAlertAction(title: item,
                style: UIAlertActionStyle.Default, handler: {
                    (action: UIAlertAction!) -> Void in
                    self.gridViewController.reset()
                    if let data = Storage.getLevelData(action.title) {
                        self.gridViewController.load(data)
                    }
                    self.currentLevelName = action.title
                    //self.currentFile.text = action.title
            }))
        }
        alert.addAction(UIAlertAction(title: "New Level",
            style: UIAlertActionStyle.Default, handler:
            { (action: UIAlertAction!) -> Void in
                self.currentLevelName = nil
                self.gridViewController.reset()
                //self.currentFile.text = "*unsaved level*"
        }))

        alert.addAction(UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)
    }

    // Watcher to check the level name is empty, enable save button if a
    // non-empty string is entered
    func textChanged(sender: UITextField) {
        let textField = sender
        var responder : UIResponder! = textField
        while !(responder is UIAlertController) {
            responder = responder.nextResponder()
        }
        let alert = responder as UIAlertController
        let text: NSString = textField.text
        var enableSave = !text.isEqual("")

        // checks for invalid file name
        if text.containsString("/") || text.containsString(":") ||
            text.rangeOfString(".").location == 0 {
                enableSave = false
        }

        if currentLevelName != nil && text == currentLevelName! {
            alert.message = "Replace current level."
        } else {
            alert.message = ""
        }

        (alert.actions[1] as UIAlertAction).enabled = enableSave
    }

    @IBAction func controlPressed(sender: UIButton) {
        setPaletteButton(sender)
    }

    private func setPaletteButton(button: UIButton) {
        gridViewController.setCurrentAction(button.currentTitle!)

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

    private func showInvalidLevelAlert() {
        let title = "Oops!"
        let message = "It seems like the players cannot reach each other."
        let dismissButton = "Back"
        let alert = UIAlertController(title: title, message: message,
            preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: dismissButton,
            style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)

    }

    private func createLevel() -> GameLevel {
        let level = BasicLevel()
        let designerGrid = gridViewController.grid

        // Perform a copy of the grid in grid view controller.
        // This is done as we do not want to call construct graph/remove nodes
        // on that grid.
        level.grid = Grid(rows: designerGrid.rows,
            columns: designerGrid.columns)

        for tileNode in designerGrid {
            level.grid[tileNode.position] = tileNode

            // Removes reference to parent as we are not doing a deep copy of
            // the grid. So the sprite nodes may still be attached to the 
            // parent nodes.
            tileNode.sprite.removeFromParent()
            if let doodad = tileNode.doodad {
                doodad.getSprite().removeFromParent()
            } else if let item = tileNode.item {
                item.getSprite().removeFromParent()
            }
        }

        level.grid.constructGraph()

        for gridIndex in gridViewController.wallLocations.keys {
            let tileNodeToRemove = level.grid[gridIndex]!
            level.grid.removeNodeFromGraph(tileNodeToRemove)
        }

        let wormholes = gridViewController.wormholeLocations.keys.array

        if wormholes.count == 2 {
            let firstWormholeTileNode = level.grid[wormholes[0]]!
            let secondWormholeTileNode = level.grid[wormholes[1]]!
            let firstWormhole = firstWormholeTileNode.doodad
                as WormholeDoodad
            let secondWormhole = secondWormholeTileNode.doodad
                as WormholeDoodad

            firstWormhole.setDestination(secondWormholeTileNode)
            secondWormhole.setDestination(firstWormholeTileNode)

            firstWormhole.setColor(0)
            secondWormhole.setColor(1)
        } else if wormholes.count == 1 {
            let wormholeTileNode = level.grid[wormholes[0]]!

            wormholeTileNode.doodad = nil
        }

        return level
    }

    private func isValidLevel(grid: Grid) -> Bool {
        let startingPositions = Constants.Level.invalidDoodadWallLocation

        for i in 0..<startingPositions.count {
            for j in i..<startingPositions.count {
                if i == j {
                    continue
                }

                let positionA = startingPositions[i]
                let positionB = startingPositions[j]

                let path = grid.shortestPathFromNode(grid[positionA]!,
                    toNode: grid[positionB]!)

                if grid.shortestPathFromNode(grid[positionA]!,
                    toNode: grid[positionB]!).count == 0 {
                        return false
                }
            }
        }

        return true
    }
}
