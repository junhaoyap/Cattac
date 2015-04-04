/*
    The Cat object
*/

import Foundation
import SpriteKit

class Cat: TileEntity {
    private let _sprite = SKSpriteNode(imageNamed: "Nala.png") //did this to try out only.
    var name: String!
    var position: GridIndex = GridIndex(0,0)
    private var _moveRange: Int = 2
    private var _actionRange: Int = 1
    var hp: Int!
    var puiDmg: Int!
    var fartDmg: Int!
    var poopDmg: Int!
    var dmgMods = [StatModification]()
    var moveRangeMods = [StatModification]()
    var actionRangeMods = [StatModification]()
    
    var moveRange: Int {
        var range = _moveRange
        for mod in moveRangeMods {
            range += mod.modification
        }
        return range
    }
    
    init(catName: String, catHp: Int, catPuiDmg: Int, catFartDmg: Int) {
        name = catName
        hp = catHp
        puiDmg = catPuiDmg
        fartDmg = catFartDmg
        poopDmg = Constants.catAttributes.poopDmg
    }
    
    func inflict(damage: Int) {
        hp = hp - damage
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKSpriteNode {
        return _sprite
    }
    
    func postExecute() {
        moveRangeMods = moveRangeMods.filter {
            (var mod) in
            return --mod.life > 0
        }
    }
}