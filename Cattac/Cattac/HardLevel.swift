/*
    Cattac's Hard Level
*/

import Foundation

class HardLevel: GameLevel {
    init() {
        super.init(rows: Constants.Level.hardRows, columns: Constants.Level.hardColumns)
    }
    
    override init(rows: Int, columns: Int) {
        super.init(rows: rows, columns: columns)
    }
}