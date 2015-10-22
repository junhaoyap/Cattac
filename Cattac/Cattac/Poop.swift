
import SpriteKit

class Poop {
    private let _pooper: Cat?
    private let _damage: Int
    var victim: Cat?
    
    var pooper: Cat? {
        return _pooper
    }

    var damage: Int {
        return _damage
    }
    
    init(_ pooper: Cat?, _ damage: Int) {
        _pooper = pooper
        _damage = damage
    }
    
    /// Execute poop effects on given player
    ///
    /// - parameter player: Player to apply effect on
    func effect(player: Cat) {
        player.inflict(_damage)
        print("\(player.name) stumbled upon poop laid by \(pooper?.name)")
    }
    
}