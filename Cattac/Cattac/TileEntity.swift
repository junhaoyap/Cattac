import SpriteKit

protocol TileEntity {
    func isVisible() -> Bool
    func getSprite() -> SKNode
}