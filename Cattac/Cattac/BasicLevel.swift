/*
    Cattac's Basic Level
*/

import Foundation

class BasicLevel: GameLevel {
    init() {
        super.init(columns: Constants.Level.basicColumns, rows: Constants.Level.basicRows)
    }
}