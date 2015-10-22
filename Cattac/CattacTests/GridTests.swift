import XCTest

class GridTests: XCTestCase {

    func createGrid(modify: (Grid)->()) -> Grid {
        let grid = Grid(rows: 10, columns: 10)

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

    func testShortestPathFromNode() {
        let grid = createGrid({ (grid) in () })

        let startNode = grid[0, 0]!
        let endNode = grid[9, 9]!

        let path = grid.shortestPathFromNode(startNode, toNode: endNode)

        XCTAssertEqual(path.count, 18, "Shortest path is incorrect")
    }

    func testShortestPathFromNodeWithObstruction() {
        let grid = createGrid({ (grid) in
            // Removes nodes from graph so that there is only nodes for the 
            // left, top and right side of the grid.
            for row in 0..<9 {
                for column in 1..<9 {
                    grid.removeNodeFromGraph(grid[row, column]!)
                }
            }
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

    func testShortestPathFromNodeToUnreachableNode() {
        let unreachable = (row: 9, col: 9)
        let grid = createGrid({ (grid) in
            grid.removeNodeFromGraph(grid[unreachable.row, unreachable.col]!)
        })

        let originNode = grid[0, 0]!
        let unreachableNode = grid[unreachable.row, unreachable.col]!

        let path = grid.shortestPathFromNode(originNode,
            toNode: unreachableNode)

         XCTAssertEqual(path.count, 0, "Shortest path is incorrect")
    }

    func checkNodeWithinRange(nodes: [Int:TileNode], range: Int,
        fromNode: TileNode) {
            for node in nodes.values {
                let row = node.position.row
                let col = node.position.col

                let rowDiff = abs(row - fromNode.position.row)
                let colDiff = abs(col - fromNode.position.col)

                XCTAssertLessThanOrEqual(rowDiff + colDiff, range,
                    "Tile(\(row),\(col)) should not be in range")
            }
    }

    func testGetNodesInRangeCenter() {
        let grid = createGrid({ (grid) in () })

        let centerRow = 5
        let centerCol = 5
        let centerNode = grid[centerRow, centerCol]!
        let range = 3

        let nodes = grid.getNodesInRange(centerNode, range: range)

        XCTAssertEqual(nodes.count, 25, "Incorrect number of nodes in range")

        checkNodeWithinRange(nodes, range: range, fromNode: centerNode)
    }

    func testGetNodesInRangeCenterWithObstruction() {
        let grid = createGrid({ (grid) in
            grid.removeNodeFromGraph(grid[6, 5]!)
            grid.removeNodeFromGraph(grid[4, 4]!)
        })

        let centerRow = 5
        let centerCol = 5
        let centerNode = grid[centerRow, centerCol]!
        let range = 3

        let nodes = grid.getNodesInRange(centerNode, range: range)

        XCTAssertEqual(nodes.count, 21, "Incorrect number of nodes in range")

        checkNodeWithinRange(nodes, range: range, fromNode: centerNode)
    }

    func testGetNodesInRangeSide() {
        let grid = createGrid({ (grid) in () })

        let sideRow = 0
        let sideCol = 5
        let sideNode = grid[sideRow, sideCol]!
        let range = 3

        let nodes = grid.getNodesInRange(sideNode, range: 3)

        XCTAssertEqual(nodes.count, 16, "Incorrect number of nodes in range")

        checkNodeWithinRange(nodes, range: range, fromNode: sideNode)
    }

    func testGetNodesInRangeSideWithObstruction() {
        let grid = createGrid({ (grid) in
            grid.removeNodeFromGraph(grid[0, 4]!)
            grid.removeNodeFromGraph(grid[0, 6]!)
        })

        let sideRow = 0
        let sideCol = 5
        let sideNode = grid[sideRow, sideCol]!
        let range = 3

        let nodes = grid.getNodesInRange(sideNode, range: 3)

        XCTAssertEqual(nodes.count, 10, "Incorrect number of nodes in range")

        checkNodeWithinRange(nodes, range: range, fromNode: sideNode)
    }

    func testGetNodesInRangeCorner() {
        let grid = createGrid({ (grid) in () })

        let cornerRow = 0
        let cornerCol = 0
        let cornerNode = grid[cornerRow, cornerCol]!
        let range = 3

        let nodes = grid.getNodesInRange(cornerNode, range: 3)

        XCTAssertEqual(nodes.count, 10, "Incorrect number of nodes in range")

        checkNodeWithinRange(nodes, range: range, fromNode: cornerNode)
    }

    func testGetNodesInRangeCornerWithObstruction() {
        let grid = createGrid({ (grid) in
            grid.removeNodeFromGraph(grid[0, 2]!)
            grid.removeNodeFromGraph(grid[1, 2]!)
        })

        let cornerRow = 0
        let cornerCol = 0
        let cornerNode = grid[cornerRow, cornerCol]!
        let range = 3

        let nodes = grid.getNodesInRange(cornerNode, range: 3)

        XCTAssertEqual(nodes.count, 7, "Incorrect number of nodes in range")

        checkNodeWithinRange(nodes, range: range, fromNode: cornerNode)
    }

    func checkNodesWithinRangeAllDirections(layers: [[Int:TileNode]],
        range: Int, fromNode: TileNode) -> Int {
            var total = 0

            for (_, layer) in layers.enumerate() {
                total += layer.count
                for node in layer.values {
                    let row = node.position.row
                    let col = node.position.col

                    let rowDiff = abs(row - fromNode.position.row)
                    let colDiff = abs(col - fromNode.position.col)

                    XCTAssertLessThanOrEqual(max(rowDiff, colDiff), range,
                        "Tile(\(row),\(col)) should not be in range")
                }
            }

            return total
    }

    func testGetNodesInRangeAllDirectionsCenter() {
        let grid = createGrid({ (grid) in () })

        let centerRow = 5
        let centerCol = 5
        let centerNode = grid[centerRow, centerCol]!
        let range = 2

        let layers = grid.getNodesInRangeAllDirections(centerNode, range: range)

        XCTAssertEqual(layers.count, range, "Incorrect range obtained")

        let total = checkNodesWithinRangeAllDirections(layers, range: range,
            fromNode: centerNode)

        XCTAssertEqual(total, 24,
            "Incorrect number of nodes in range for all direcitons")
    }

    func testGetNodesInRangeAllDirectionsCenterWithObstruction() {
        let grid = createGrid({ (grid) in
            grid[6, 5]!.setDoodad(Wall())
            grid[4, 4]!.setDoodad(Wall())
        })

        let centerRow = 5
        let centerCol = 5
        let centerNode = grid[centerRow, centerCol]!
        let range = 2

        let layers = grid.getNodesInRangeAllDirections(centerNode, range: range)

        XCTAssertEqual(layers.count, range, "Incorrect range obtained")

        let total = checkNodesWithinRangeAllDirections(layers, range: range,
            fromNode: centerNode)

        XCTAssertEqual(total, 10,
            "Incorrect number of nodes in range for all direcitons")
    }

    func testGetNodesInRangeAllDirectionsSide() {
        let grid = createGrid({ (grid) in () })

        let sideRow = 0
        let sideCol = 5
        let sideNode = grid[sideRow, sideCol]!
        let range = 2

        let layers = grid.getNodesInRangeAllDirections(sideNode, range: range)

        XCTAssertEqual(layers.count, range, "Incorrect range obtained")

        let total = checkNodesWithinRangeAllDirections(layers, range: range,
            fromNode: sideNode)

        XCTAssertEqual(total, 14,
            "Incorrect number of nodes in range for all direcitons")
    }

    func testGetNodesInRangeAllDirectionsSideWithObstruction() {
        let grid = createGrid({ (grid) in
            grid[0, 4]!.setDoodad(Wall())
            grid[0, 6]!.setDoodad(Wall())
        })

        let sideRow = 0
        let sideCol = 5
        let sideNode = grid[sideRow, sideCol]!
        let range = 2

        let layers = grid.getNodesInRangeAllDirections(sideNode, range: range)

        XCTAssertEqual(layers.count, range, "Incorrect range obtained")

        let total = checkNodesWithinRangeAllDirections(layers, range: range,
            fromNode: sideNode)

        XCTAssertEqual(total, 2,
            "Incorrect number of nodes in range for all direcitons")
    }

    func testGetNodesInRangeAllDirectionsCorner() {
        let grid = createGrid({ (grid) in () })

        let cornerRow = 0
        let cornerCol = 0
        let cornerNode = grid[cornerRow, cornerCol]!
        let range = 2

        let layers = grid.getNodesInRangeAllDirections(cornerNode, range: range)

        XCTAssertEqual(layers.count, range, "Incorrect range obtained")

        let total = checkNodesWithinRangeAllDirections(layers, range: range,
            fromNode: cornerNode)

        XCTAssertEqual(total, 8,
            "Incorrect number of nodes in range for all direcitons")
    }

    func testGetNodesInRangeAllDirectionsCornerWithObstruction() {
        let grid = createGrid({ (grid) in
            grid[1, 1]!.setDoodad(Wall())
        })

        let cornerRow = 0
        let cornerCol = 0
        let cornerNode = grid[cornerRow, cornerCol]!
        let range = 2

        let layers = grid.getNodesInRangeAllDirections(cornerNode, range: range)

        XCTAssertEqual(layers.count, range, "Incorrect range obtained")

        let total = checkNodesWithinRangeAllDirections(layers, range: range,
            fromNode: cornerNode)
        XCTAssertEqual(total, 4,
            "Incorrect number of nodes in range for all direcitons")
    }

    func testGetAvailableDirectionsCenter() {
        let grid = createGrid({ (grid) in () })

        let directions = grid.getAvailableDirections(grid[5, 5]!)

        XCTAssertEqual(directions.count, 4, "Incorrect number of directions")

        for direction: Direction in [.Top, .Right, .Bottom, .Left] {
            XCTAssertTrue(directions.contains(direction),
                "\(direction.description) should be available")
        }
    }

    func testGetAvailableDirectionsSide() {
        let grid = createGrid({ (grid) in () })

        let directions = grid.getAvailableDirections(grid[0, 5]!)

        XCTAssertEqual(directions.count, 3, "Incorrect number of directions")

        for direction: Direction in [.Top, .Right, .Left] {
            XCTAssertTrue(directions.contains(direction),
                "\(direction.description) should be available")
        }
    }

    func testGetAvailableDirectionsCorner() {
        let grid = createGrid({ (grid) in () })

        let directions = grid.getAvailableDirections(grid[0, 0]!)

        XCTAssertEqual(directions.count, 2, "Incorrect number of directions")

        for direction: Direction in [.Top, .Right] {
            XCTAssertTrue(directions.contains(direction),
                "\(direction.description) should be available")
        }
    }

    func testGetAvailableDirectionsWithObstruction() {
        let grid = createGrid({ (grid) in
            grid.removeNodeFromGraph(grid[4, 5]!)
            grid.removeNodeFromGraph(grid[6, 5]!)
        })

        let directions = grid.getAvailableDirections(grid[5, 5]!)

        XCTAssertEqual(directions.count, 2, "Incorrect number of directions")

        for direction: Direction in [.Left, .Right] {
            XCTAssertTrue(directions.contains(direction),
                "\(direction.description) should be available")
        }
    }
}
