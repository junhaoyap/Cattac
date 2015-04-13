import XCTest

class GridTests: XCTestCase {

    func createGrid(modify: (Grid)->Grid) -> Grid {
        var grid = Grid(rows: 10, columns: 10)

        for row in 0..<10 {
            for column in 0..<10 {
                let tileNode = TileNode(row: row, column: column)
                grid[row, column] = tileNode
            }
        }

        grid.constructGraph()

        modify(grid)

        return grid
    }

    func testShortestPathFromNodeWithoutObstruction() {
        var grid = createGrid({ (grid) in return grid })

        let startNode = grid[0, 0]!
        let endNode = grid[9, 9]!

        let path = grid.shortestPathFromNode(startNode, toNode: endNode)

        XCTAssertEqual(path.count, 18, "Shortest path is incorrect")
    }

    func testShortestPathFromNodeWithObstruction() {
        var grid = createGrid({ (grid) in
            // Removes nodes from graph so that there is only nodes for the 
            // left, top and right side of the grid.
            for row in 0..<9 {
                for column in 1..<9 {
                    grid.removeNodeFromGraph(grid[row, column]!)
                }
            }
            return grid
        })

        let originNode = grid[0, 0]!
        let topRightNode = grid[9, 9]!
        let bottomRightNode = grid[0, 9]!

        // Get path from bottom left to top right
        var path = grid.shortestPathFromNode(originNode, toNode: topRightNode)

        XCTAssertEqual(path.count, 18, "Shortest path is incorrect")

        // Get path from bottom left to bottom right
        path = grid.shortestPathFromNode(originNode, toNode: bottomRightNode)

        XCTAssertEqual(path.count, 27, "Shortest path is incorrect")

    }
}
