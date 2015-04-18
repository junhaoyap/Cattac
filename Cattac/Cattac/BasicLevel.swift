/*
    Cattac's Basic Level
*/

import Foundation

class BasicLevel: GameLevel {
    init() {
        super.init(rows: Constants.Level.basicRows, columns: Constants.Level.basicColumns)
    }
    
    override init(rows: Int, columns: Int) {
        super.init(rows: rows, columns: columns)
    }
}