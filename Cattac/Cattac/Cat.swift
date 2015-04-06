/*
    The Cat object
*/

import Foundation
import SpriteKit

class Cat: TileEntity {
    private var _sprite = SKSpriteNode(imageNamed: "Nala.png")
    private let baseDefence: Int
    private let baseMoveRange: Int
    private let baseFartRange: Int
    
    var name: String!
    var position: GridIndex = GridIndex(0,0)
    var hp: Int
    var puiDmg: Int!
    var fartDmg: Int!
    var poopDmg: Int!
    
    var defenceMods = [StatModification]()
    var dmgMods = [StatModification]()
    var moveRangeMods = [StatModification]()
    var fartRangeMods = [StatModification]()
    
    var defence: Int {
        var def = baseDefence
        for mod in defenceMods {
            def += mod.modification
        }
        return def
    }
    
    var moveRange: Int {
        var range = baseMoveRange
        for mod in moveRangeMods {
            range += mod.modification
        }
        return range
    }
    
    var fartRange: Int {
        var range = baseFartRange
        for mod in fartRangeMods {
            range += mod.modification
        }
        return range
    }
    
    init(catName: String, catHp: Int, catDef: Int, catPuiDmg: Int, catFartDmg: Int) {
        name = catName
        hp = catHp
        baseDefence = catDef
        puiDmg = catPuiDmg
        fartDmg = catFartDmg
        poopDmg = Constants.catAttributes.poopDmg
        baseMoveRange = Constants.catAttributes.moveRange
        baseFartRange = Constants.catAttributes.fartRange
        
        switch catName {
        case Constants.catName.nalaCat:
            _sprite = SKSpriteNode(imageNamed: "Nala.png")
        case Constants.catName.nyanCat:
            _sprite = SKSpriteNode(imageNamed: "Grumpy.png")
        case Constants.catName.grumpyCat:
            _sprite = SKSpriteNode(imageNamed: "Nyan.png")
        case Constants.catName.pusheenCat:
            _sprite = SKSpriteNode(imageNamed: "Pusheen.png")
        default:
            break
        }
    }
    
    func inflict(damage: Int) {
        self.hp -= damage * 1/defence
    }
    
    func heal(hp: Int) {
        self.hp += hp
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKNode {
        return _sprite
    }
    
    func postExecute() {
        moveRangeMods = moveRangeMods.filter {
            (var mod) in
            return --mod.life > 0
        }
    }
}