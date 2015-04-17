/*
    Cattac's Medium Level
*/

import Foundation

class MediumLevel: GameLevel {
    init() {
        super.init(rows: Constants.Level.mediumRows, columns: Constants.Level.mediumColumns)
    }
    
    override init(rows: Int, columns: Int) {
        super.init(rows: rows, columns: columns)
    }
}