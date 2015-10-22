import Foundation
import SpriteKit

/// A tile on the game grid.
class TileNode {
    
    var position: GridIndex
    var sprite: SKSpriteNode
    var doodad: Doodad?
    var item: Item?
    var poop: Poop?
    
    private let grass = SKTexture(imageNamed: "Grass.png")
    private let grassPreview = SKTexture(imageNamed: "GrassPreview.png")
    
    init(row: Int, column: Int) {
        position = GridIndex(row, column)
        sprite = SKSpriteNode(texture: grass)
        sprite.setScale(1.0)
        sprite.zPosition = Constants.Z.tile
    }
    
    /// Highlights tile for indicating reachable tiles.
    func highlight() {
        sprite.texture = grassPreview
    }
    
    /// Removes highlight on this tile.
    func unhighlight() {
        sprite.texture = grass
    }
    
    func setDoodad(doodad: Doodad) {
        self.doodad = doodad
    }
    
    func tileHasDoodad() -> Bool {
        return self.doodad != nil
    }
}

extension TileNode: CustomStringConvertible {
    var description: String {
        return "square:(\(position.row),\(position.col))"
    }
}

extension TileNode: Hashable {
    var hashValue: Int {
        get {
            return (UInt32(position.row) + UInt32(position.col) << 16).hashValue
        }
    }
}

func ==(lhs: TileNode, rhs: TileNode) -> Bool {
    return lhs.hashValue == rhs.hashValue
}