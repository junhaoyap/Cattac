import SpriteKit

class SceneUtils {

    private let numRows: Int
    private let numColumns: Int
    private let windowWidth: CGFloat
    private let tileWidth: CGFloat
    private let tileHeight: CGFloat

    init(windowWidth: CGFloat, numRows: Int, numColumns: Int) {
        self.numRows = numRows
        self.numColumns = numColumns
        self.windowWidth = windowWidth
        self.tileWidth = windowWidth / CGFloat(max(numRows, numColumns) + 2)
        self.tileHeight = self.tileWidth
    }

    var tileSize: CGSize {
        return CGSize(width: tileWidth, height: tileHeight)
    }

    func getLayerPosition() -> CGPoint {
        let x = -tileWidth * CGFloat(numColumns) / 2
        let y = -tileHeight * CGFloat(numRows) / 2
        return CGPoint(x: x, y: y)
    }

    func pointFor(gridIndex: GridIndex) -> CGPoint {
        return CGPoint(
            x: CGFloat(gridIndex.col) * tileWidth + tileWidth / 2,
            y: CGFloat(gridIndex.row) * tileHeight + tileHeight / 2)
    }

    func nodeForLocation(location: CGPoint, grid: Grid) -> TileNode? {
        let normalizedX = location.x + (CGFloat(numColumns)/2) * tileWidth
        let normalizedY = location.y + (CGFloat(numRows)/2) * tileHeight
        let col = Int(normalizedX / tileWidth)
        let row = Int(normalizedY / tileHeight)
        return grid[row, col]
    }

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
