import Foundation
import SpriteKit

class TileNode {
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    var doodad: Doodad?
    
    init(row: Int, column: Int) {
        self.column = column
        self.row = row
    }
    
    func setDoodad(doodad: Doodad) {
        self.doodad = doodad
    }
    
    func tileHasDoodad() -> Bool {
        return self.doodad != nil
    }
}

extension TileNode: Printable {
    var description: String {
        return "square:(\(row),\(column))"
    }
}

extension TileNode: Hashable {
    var hashValue: Int {
        get {
            return (UInt32(row) + UInt32(column) << 16).hashValue
        }
    }
}

func ==(lhs: TileNode, rhs: TileNode) -> Bool {
    return lhs.hashValue == rhs.hashValue
}