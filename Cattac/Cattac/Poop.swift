
import SpriteKit

class Poop {
    private let _pooper: Cat
    private let _damage: Int
    
    var pooper: Cat {
        return _pooper
    }
    
    init(_ pooper: Cat, _ damage: Int) {
        _pooper = pooper
        _damage = damage
    }
    
    /// Execute poop effects on given player
    ///
    /// :param: player Player to apply effect on
    func effect(player: Cat) {
        player.inflict(_damage)
        println("\(player.name) stumbled upon poop laid by \(pooper.name)")
    }
    
}