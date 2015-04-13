
/// Modification for cat attribute. Allows for 
/// multiple modifications on a single attribute 
/// that is decayed over a pre-defined turn.
class StatModification {
    
    /// Attribute modification amount.
    var modification: Int = 0
    
    /// Turns this modification will be in effect.
    var life: Int = 0
    
    init(_ modification: Int, life: Int) {
        self.modification = modification
        self.life = life
    }
    
}