/*
    Cattac's Basic Level
*/

import Foundation

class BasicLevel {
    
    let numColumns = Constants.BasicLevel.numColumns
    let numRows = Constants.BasicLevel.numRows
    
    var grid: Grid<TileNode>!
    
    private var _cats = [String : Cat]()
    
    var cats: [Cat] {
        return [Cat](_cats.values)
    }
    
    init() {
        grid = Grid<TileNode>(columns: numColumns, rows: numRows)
    }
    
    func nodeAtColumn(column: Int, row: Int) -> TileNode? {
        assert(column >= 0 && column < numColumns)
        assert(row >= 0 && row < numRows)
        return grid[row, column]
    }
    
    func addCat(type: CatType, _ posX: Int, _ posY: Int, _ id: String) {
        let cat = Cat(id, type)
        
        let node  = nodeAtColumn(posX, row: posY)
        node!.occupants.append(cat)
        
        _cats.updateValue(cat, forKey: cat.id)
    }
}