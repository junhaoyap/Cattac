/*
    Cattac's Basic Level
*/

import Foundation

class BasicLevel {
    
    let numColumns = Constants.BasicLevel.numColumns
    let numRows = Constants.BasicLevel.numRows
    
    private var nodes: Array2D<TileNode>!
    
    init() {
        nodes = Array2D<TileNode>(columns: numColumns, rows: numRows)
    }
    
    func nodeAtColumn(column: Int, row: Int) -> TileNode? {
        assert(column >= 0 && column < numColumns)
        assert(row >= 0 && row < numRows)
        return nodes[column, row]
    }
}