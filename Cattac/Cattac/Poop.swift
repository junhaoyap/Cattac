
class Poop: TileEntity {
    private let _pooper: Cat
    private let _damage: Int
    private var _removed: Bool
    
    var pooper: Cat {
        return _pooper
    }
    
    var removed: Bool {
        return _removed
    }
    
    init(_ pooper: Cat, _ damage: Int) {
        _pooper = pooper
        _damage = damage
    }
    
    func effect(player: Cat) {
        player.inflict(_damage)
        _removed = true
    }
}