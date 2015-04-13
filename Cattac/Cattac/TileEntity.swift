import SpriteKit

/// Protocol for classes that are added to game tiles to conform.
protocol TileEntity {
    
    /// Used by game UI to determine if entity should be drawn.
    func isVisible() -> Bool
    
    /// Called by game UI to obtain entity SpriteNode to be drawn.
    func getSprite() -> SKNode
}