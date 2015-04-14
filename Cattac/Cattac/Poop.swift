
import SpriteKit

class Poop {
    private let _pooper: Cat
    private let _damage: Int
    private let _sprite: SKSpriteNode
    
    var pooper: Cat {
        return _pooper
    }
    
    var sprite: SKSpriteNode {
        return _sprite
    }
    
    init(_ pooper: Cat, _ damage: Int) {
        _pooper = pooper
        _damage = damage
        _sprite = SKSpriteNode(imageNamed: "Poop.png")
        _sprite.alpha = 0.5
    }
    
    /// Execute poop effects on given player
    ///
    /// :param: player Player to apply effect on
    func effect(player: Cat) {
        player.inflict(_damage)
        println("\(player.name) stumbled upon poop laid by \(pooper.name)")
    }
    
}