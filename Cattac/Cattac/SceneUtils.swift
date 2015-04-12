import SpriteKit

/// A set of utility functions that are used together with the game scene.
class SceneUtils {

    private let numRows: Int
    private let numColumns: Int
    private let windowWidth: CGFloat
    private let tileWidth: CGFloat
    private let tileHeight: CGFloat

    /// Initializes the class with information of the current scene.
    ///
    /// :param: windowWidth The width of the entire view.
    /// :param: numRows The number of rows for the game level.
    /// :param: numColumns The number of columns for the game level.
    init(windowWidth: CGFloat, numRows: Int, numColumns: Int) {
        self.numRows = numRows
        self.numColumns = numColumns
        self.windowWidth = windowWidth
        self.tileWidth = windowWidth / CGFloat(max(numRows, numColumns) + 2)
        self.tileHeight = self.tileWidth
    }

    /// The size of a single tile in the grid.
    var tileSize: CGSize {
        return CGSize(width: tileWidth, height: tileHeight)
    }

    /// The position for drawing the grid.
    ///
    /// :returns: The point to draw the layers (for spritekit, the origin of 
    ///           the layer lies on the bottom left of the layer)
    func getLayerPosition() -> CGPoint {
        let x = -tileWidth * CGFloat(numColumns) / 2
        let y = -tileHeight * CGFloat(numRows) / 2
        return CGPoint(x: x, y: y)
    }

    /// Gets the point for the grid index.
    ///
    /// :param: gridIndex The grid index given to calculate the point in the
    ///                   the view.
    /// :returns: The point for the grid index.
    func pointFor(gridIndex: GridIndex) -> CGPoint {
        return CGPoint(
            x: CGFloat(gridIndex.col) * tileWidth + tileWidth / 2,
            y: CGFloat(gridIndex.row) * tileHeight + tileHeight / 2)
    }

    /// Gets the `TileNode` that lies on the given location based on the grid
    /// of the game level.
    ///
    /// :param: location The point in the view to be used to retrieve the tile
    ///                  in the grid.
    /// :param: grid The grid of the game level.
    /// :returns: The `TileNode` that lies on the location point.
    func nodeForLocation(location: CGPoint, grid: Grid) -> TileNode? {
        let normalizedX = location.x + (CGFloat(numColumns)/2) * tileWidth
        let normalizedY = location.y + (CGFloat(numRows)/2) * tileHeight
        let col = Int(normalizedX / tileWidth)
        let row = Int(normalizedY / tileHeight)
        return grid[row, col]
    }

    /// Calculates the amount of rotation for a given direction.
    ///
    /// :param: dir The direction used to calculate the rotation.
    /// :returns: The rotation in radians.
    class func zRotation(dir: Direction) -> CGFloat {
        switch dir {
        case .Right:
            return CGFloat(3 * M_PI / 2.0)
        case .Bottom:
            return CGFloat(M_PI)
        case .Left:
            return CGFloat(M_PI / 2.0)
        default:
            return 0
        }
    }
}
