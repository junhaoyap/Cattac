/*
    The Doodad object
*/

import SpriteKit

class Doodad: TileEntity {
    
    private var dictionaryName = ""
    private var removed = false
    private var sprite: SKNode = SKSpriteNode(imageNamed: "Nala.png")
    
    /// Inheriting doodads to implement effect, if any.
    /// effected by destination tile
    /// after player move has been calculated.
    ///
    /// :param: player Player to apply effect on
    func postmoveEffect(cat: Cat) {
    }
    
    /// Inheriting doodads to implement effect, if any.
    /// effected by position tile
    /// before player move has been calculated.
    ///
    /// :param: player Player to apply effect on
    func premoveEffect(cat: Cat) {
    }
    
    func isRemoved() -> Bool {
        return removed
    }
    
    func setRemoved() {
        removed = true
    }
    
    func getSprite() -> SKNode {
        return sprite
    }
    
    func setSprite(sprite: SKNode) {
        self.sprite = sprite
    }
    
    func isVisible() -> Bool {
        // inheriting doodads to override.
        return true
    }
    
    func getName() -> String {
        return dictionaryName
    }
    
    func setName(newName: String) {
        dictionaryName = newName
    }
}