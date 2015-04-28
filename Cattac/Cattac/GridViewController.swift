import Foundation
import UIKit

private extension Grid {
    subscript(indexPath: NSIndexPath) -> TileNode? {
        get {
            return self[Grid.convert(indexPath, totalRows: rows)]
        }
        set {
            self[Grid.convert(indexPath, totalRows: rows)] = newValue
        }
    }

    class func convert(indexPath: NSIndexPath, totalRows: Int) -> GridIndex {
        return GridIndex(totalRows - indexPath.section - 1, indexPath.row)
    }
}

let gridCellIdentifier = "gridCellIdentifier"
let tileEntityTag = 20

class GridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // Current selected palette action
    private var currentAction: String?

    private let rows = Constants.Level.basicRows
    private let columns = Constants.Level.basicColumns
    private var sceneUtils: SceneUtils!

    var wallLocations: [GridIndex:UICollectionViewCell] = [:]
    var wormholeLocations: [GridIndex:UIButton] = [:]
    var grid: Grid!

    var wormholeBlueButton: UIButton!
    var wormholeOrangeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set size of grid area to the size of the container view
        let gridViewWidth = self.view.frame.width
        let gridViewHeight = self.view.frame.height

        sceneUtils = SceneUtils(windowWidth: gridViewWidth, numRows: rows,
            numColumns: columns)
        grid = Grid(rows: rows, columns: columns)
        for row in 0..<rows {
            for column in 0..<columns {
                let tileNode = TileNode(row: row, column: column)
                grid[row, column] = tileNode
            }
        }

        // Defines the layout for the UICollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = sceneUtils.tileSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let frame = CGRectMake(0, 0, gridViewWidth, gridViewHeight)

        // Initialise the UICollectionView
        let collectionView: UICollectionView = UICollectionView(frame: frame,
            collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self,
            forCellWithReuseIdentifier: gridCellIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()

        // Register gestures
        let panGesture = UIPanGestureRecognizer(target: self,
            action: "panGestureHandler:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        collectionView.addGestureRecognizer(panGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self,
            action: "longPressGestureHandler:")
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)

        self.view = collectionView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated0.
    }

    func numberOfSectionsInCollectionView(
        collectionView: UICollectionView) -> Int {
            return Constants.Level.basicRows
    }

    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return Constants.Level.basicColumns
    }

    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                gridCellIdentifier, forIndexPath: indexPath)
                as UICollectionViewCell

            let tileImage = UIImage(named: "Grass.png")!
            let tile = UIImageView(image: tileImage)
            let tileSize = sceneUtils.tileSize
            tile.frame = CGRectMake(0, 0, tileSize.width, tileSize.height)
            cell.addSubview(tile)

            if isPlayerLocation(indexPath) {
                addPlayer(cell,
                    gridIndex: Grid.convert(indexPath, totalRows: rows))
            }

            return cell
    }

    private func addPlayer(cell: UICollectionViewCell, gridIndex: GridIndex) {
        func addImage(# named: String) {
            let image = UIImage(named: named)
            let imageView = UIImageView(image: image)
            let tileSize = cell.frame.size
            imageView.frame = CGRectMake(0, 0, tileSize.width, tileSize.height)
            cell.addSubview(imageView)
        }

        if gridIndex.row == 0 {
            if gridIndex.col == 0 {
                addImage(named: "Grumpy.png")
            } else if gridIndex.col == columns - 1 {
                addImage(named: "Octocat.png")
            }
        } else if gridIndex.row == rows - 1 {
            if gridIndex.col == 0 {
                addImage(named: "Nyan.png")
            } else if gridIndex.col == columns - 1 {
                addImage(named: "HelloKitty.png")
            }
        }
    }

    // Used to register single tap on grid
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if isPlayerLocation(indexPath) {
                return
            }
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            tileAction(cell!, toggle: true, indexPath: indexPath)
    }

    func setCurrentAction(action: String) {
        self.currentAction = action
        println("\(action) button selected")
    }

    func longPressGestureHandler(sender: UILongPressGestureRecognizer) {
        let collectionView = self.view as UICollectionView
        let point: CGPoint = sender.locationInView(self.view)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            removeTileEntity(cell!, indexPath: indexPath)
        }
    }

    func panGestureHandler(sender: UIPanGestureRecognizer) {
        let collectionView = self.view as UICollectionView
        let point: CGPoint = sender.locationInView(collectionView)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            tileAction(cell!, toggle: false, indexPath: indexPath)
        }
    }

    func load(levelData: [String:AnyObject]) {
        func add(entity: TileEntity, to gridIndex: GridIndex) {
            let indexPath = NSIndexPath(forRow: gridIndex.col,
                inSection: rows - gridIndex.row - 1)
            let cell = (self.view as UICollectionView)
                .cellForItemAtIndexPath(indexPath)

            addTileEntity(cell!, entityObject: entity, indexPath: indexPath)
        }

        let level = LevelGenerator.sharedInstance.createGame(fromDict: levelData)

        for tileNode in level.grid {
            if let doodad = tileNode.doodad {
                let gridIndex = tileNode.position
                grid[gridIndex]!.doodad = doodad
                add(doodad, to: gridIndex)
            } else if let item = tileNode.item {
                let gridIndex = tileNode.position
                grid[gridIndex]!.item = item
                add(item, to: gridIndex)
            }
        }
    }

    func reset() {
        let collectionView = self.view as UICollectionView
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(
                indexPath as NSIndexPath)
            removeTileEntity(cell!, indexPath: indexPath as NSIndexPath)
        }
    }

    private func isPlayerLocation(indexPath: NSIndexPath) -> Bool {
        let selectedRow = indexPath.section
        let selectedColumn = indexPath.row

        return selectedRow == 0 && selectedColumn == 0 ||
            selectedRow == 0 && selectedColumn == columns - 1 ||
            selectedRow == rows - 1 && selectedColumn == columns - 1 ||
            selectedRow == rows - 1 && selectedColumn == 0
    }

    private func isInvalidWormhole(entity: String, _ gridIndex: GridIndex) -> Bool {
        if entity == Constants.Entities.Title.wormholeBlue {
            if wormholeBlueButton.enabled {
                wormholeBlueButton.enabled = false
                wormholeLocations[gridIndex] = wormholeBlueButton
            } else {
                return true
            }
        } else if entity == Constants.Entities.Title.wormholeOrange {
            if wormholeOrangeButton.enabled {
                wormholeOrangeButton.enabled = false
                wormholeLocations[gridIndex] = wormholeOrangeButton
            } else {
                return true
            }
        }

        return false
    }

    private func tileAction(cell: UICollectionViewCell, toggle: Bool,
        indexPath: NSIndexPath) {
            if let actionTitle = currentAction {
                if actionTitle == "Eraser" {
                    removeTileEntity(cell, indexPath: indexPath)
                } else {
                    changeTileEntity(cell, toggle: toggle, indexPath: indexPath)
                }
            }
    }

    private func addTileEntity(cell: UICollectionViewCell, entity: String,
        indexPath: NSIndexPath) {
            let gridIndex = Grid.convert(indexPath, totalRows: rows)

            if isPlayerLocation(indexPath) || isInvalidWormhole(entity, gridIndex) {
                return
            }

            let entityObject = Constants.Entities.getObject(entity)!

            add(entity: entity, to: cell)
            add(entityObject: entityObject, to: gridIndex)

            if entity == Constants.Entities.Title.wall {
                wallLocations[gridIndex] = cell
            }
    }

    private func addTileEntity(cell: UICollectionViewCell,
        entityObject: TileEntity, indexPath: NSIndexPath) {
            let gridIndex = Grid.convert(indexPath, totalRows: rows)
            let entity = getEntity(entityObject)

            if isPlayerLocation(indexPath) || isInvalidWormhole(entity, gridIndex) {
                return
            }

            add(entity: entity, to: cell)
            add(entityObject: entityObject, to: gridIndex)

            if entity == Constants.Entities.Title.wall {
                wallLocations[gridIndex] = cell
            }
    }

    private func add(# entity: String, to cell: UICollectionViewCell) {
        let entityImage =
            UIImage(named: Constants.Entities.getImage(entity)!)
        let entityImageView = UIImageView(image: entityImage)

        entityImageView.frame = CGRectMake(0, 0,
            cell.frame.width, cell.frame.height)
        entityImageView.tag = tileEntityTag
        cell.addSubview(entityImageView)
    }

    private func add(# entityObject: TileEntity, to gridIndex: GridIndex) {
        let tileNode = grid[gridIndex]!
        if entityObject is Doodad {
            tileNode.doodad = (entityObject as Doodad)
        } else if entityObject is Item {
            tileNode.item = (entityObject as Item)
        }

    }

    private func removeTileEntity(cell: UICollectionViewCell,
        indexPath: NSIndexPath) -> TileEntity? {
            var currentTileEntity: TileEntity?

            if let entityImage = cell.viewWithTag(tileEntityTag) {
                entityImage.removeFromSuperview()

                let gridIndex = Grid.convert(indexPath, totalRows: rows)
                let tileNode = grid[gridIndex]!
                if tileNode.doodad != nil {
                    currentTileEntity = tileNode.doodad
                    tileNode.doodad = nil
                } else if tileNode.item != nil {
                    currentTileEntity = tileNode.item
                    tileNode.item = nil
                }

                if let button = wormholeLocations[gridIndex] {
                    button.enabled = true
                    button.alpha = 1
                    wormholeLocations.removeValueForKey(gridIndex)
                }

                wallLocations.removeValueForKey(gridIndex)
            }

            return currentTileEntity
    }

    private func changeTileEntity(cell: UICollectionViewCell, toggle: Bool,
        indexPath: NSIndexPath) {
            if cell.viewWithTag(tileEntityTag) == nil {
                addTileEntity(cell, entity: currentAction!, indexPath: indexPath)
            } else if toggle {
                if let prevEntity = removeTileEntity(cell,
                    indexPath: indexPath) {
                        let nextEntity = getNextEntityName(prevEntity)
                        addTileEntity(cell, entity: nextEntity,
                            indexPath: indexPath)
                }
            }
    }

    private func getNextEntityName(entity: TileEntity) -> String {
        let entities = Constants.Entities.Title.self

        switch entity {
        case is FortressDoodad:
            return entities.tower
        case is WatchTowerDoodad:
            return entities.trampoline
        case is TrampolineDoodad:
            if wormholeBlueButton.enabled {
                return entities.wormholeBlue
            } else if wormholeOrangeButton.enabled {
                return entities.wormholeOrange
            } else {
                return entities.milk
            }
        case is WormholeDoodad:
            return entities.milk
        case is MilkItem:
            return entities.nuke
        case is NukeItem:
            return entities.projectile
        case is ProjectileItem:
            return entities.wall
        default:
            return entities.fortress
        }
    }

    private func getEntity(entity: TileEntity) -> String {
        let entities = Constants.Entities.Title.self

        switch entity {
        case is FortressDoodad:
            return entities.fortress
        case is WatchTowerDoodad:
            return entities.tower
        case is TrampolineDoodad:
            return entities.trampoline
        case is WormholeDoodad:
            if wormholeBlueButton.enabled {
                return entities.wormholeBlue
            } else {
                return entities.wormholeOrange
            }
        case is MilkItem:
            return entities.milk
        case is NukeItem:
            return entities.nuke
        case is ProjectileItem:
            return entities.projectile
        default:
            return entities.wall
        }
    }
}