import XCTest

class GridTests: XCTestCase {

    func createGrid(modify: (Grid)->()) -> Grid {
        var grid = Grid(rows: 10, columns: 10)

        for row in 0..<10 {
            for column in 0..<10 {
                let tileNode = TileNode(row: row, column: column)
                grid[row, column] = tileNode
            }
        }

        modify(grid)

        grid.constructGraph()

        return grid
    }

    func testShortestPathFromNode() {
        var grid = createGrid({ (grid) in () })

        let fromNode = grid[0, 0]!
        let toNode = grid[9, 9]!

        let path = grid.shortestPathFromNode(fromNode, toNode: toNode)

        XCTAssertEqual(path.count, 18, "Shortest path is incorrect")
    }
}
