/*
    The Cat object
*/

import Foundation
import SpriteKit

protocol HpListener {
    func onHpUpdate(hp: Int)
}

class Cat: TileEntity {
    private let _spriteImage: String
    private let _sprite: SKSpriteNode
    private let _previewSprite: SKSpriteNode
    private let maxHp: Int
    private let baseDefence: Int
    private let baseMoveRange: Int
    private let baseFartRange: Int
    private var basePuiDmg: Int
    private var baseFartDmg: Int
    private var basePoopDmg: Int
    
    var name: String!
    var hp: Int

    var hpListener: HpListener?
    
    var defenceMods = [AttrModification]()
    var dmgMods = [AttrModification]()
    var moveRangeMods = [AttrModification]()
    var fartRangeMods = [AttrModification]()
    
    /// Cat's defence attribute with modifications
    var defence: Int {
        return applyAttrMods(baseDefence, mods: defenceMods)
    }
    
    /// Cat's movement range attribute with modifications
    var moveRange: Int {
        return applyAttrMods(baseMoveRange, mods: moveRangeMods)
    }
    
    /// Cat's fart range attribute with modifications
    var fartRange: Int {
        return applyAttrMods(baseFartRange, mods: fartRangeMods)
    }
    
    /// Cat's Pui damage attribute with modifications
    var puiDmg: Int {
        return applyAttrMods(basePuiDmg, mods: dmgMods)
    }
    
    /// Cat's Fart damage attribute with modifications
    var fartDmg: Int {
        return applyAttrMods(baseFartDmg, mods: dmgMods)
    }
    
    /// Cat's Poop damage attribute with modifications
    var poopDmg: Int {
        return applyAttrMods(basePoopDmg, mods: dmgMods)
    }

    /// Name of the sprite image used to draw the cat
    var spriteImage: String {
        return _spriteImage
    }
    
    /// Movement preview sprite
    var previewSprite: SKSpriteNode {
        return _previewSprite
    }

    var isDead: Bool {
        return hp <= 0
    }
    
    /// Constructs a cat with its base attributes
    ///
    /// - parameter catName: Name speicifying cat type
    /// - parameter catHp: Base HP
    /// - parameter catDef: Base defence
    /// - parameter catPuiDmg: Base Pui damage
    /// - parameter catFartDmg: Base Fart damage
    init(catName: String, attributes: (hp: Int, defense: Int, puiDmg: Int,
        fartDmg: Int, poopDmg: Int, moveRange: Int, fartRange: Int)) {
        name = catName
        maxHp = attributes.hp
        hp = maxHp
        baseDefence = attributes.defense
        basePuiDmg = attributes.puiDmg
        baseFartDmg = attributes.fartDmg
        basePoopDmg = attributes.poopDmg
        baseMoveRange = attributes.moveRange
        baseFartRange = attributes.fartRange

        _spriteImage = Constants.cat.images[catName]!

        _sprite = SKTouchSpriteNode(imageNamed: _spriteImage)
        _previewSprite = SKTouchSpriteNode(imageNamed: _spriteImage)

        _sprite.zPosition = Constants.Z.cat
        _previewSprite.zPosition = Constants.Z.catPreview
        _previewSprite.alpha = 0.5
    }
    
    /// Inflicts the damage on to cat's hp,
    /// after applying cat's defence attribute.
    /// cat.hp -= damage * 1/defence
    ///
    /// - parameter damage: Points to be reduced from hp
    /// - returns: The amount of actual damage inflicted
    func inflict(damage: Int) -> Int {
        if hp > 0 {
            let realDamage = damage * 1/defence
            hp -= realDamage
            hpListener?.onHpUpdate(hp)
            return realDamage
        }
        return 0
    }
    
    /// Heals cat's HP directly.
    /// cat.hp += hp
    ///
    /// - parameter health: Points to increase the hp
    /// - returns: The amount of health restored
    func heal(health: Int) -> Int {
        let diff = maxHp - hp

        if diff > health {
            hp += health
            hpListener?.onHpUpdate(hp)
            return health
        } else {
            hp = maxHp
            hpListener?.onHpUpdate(hp)
            return diff
        }
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKNode {
        return _sprite
    }
    
    /// Called after execution of each game turn, to decay
    /// attribute modifications.
    func postExecute() {
        moveRangeMods = moveRangeMods.filter {
            (mod) in
            return --mod.life > 0
        }
        defenceMods = defenceMods.filter {
            (mod) in
            return --mod.life > 0
        }
        fartRangeMods = fartRangeMods.filter {
            (mod) in
            return --mod.life > 0
        }
        dmgMods = dmgMods.filter {
            (mod) in
            return --mod.life > 0
        }
    }
    
    /// Helper method to apply attribute modifications.
    ///
    /// - parameter baseValue: Base attribute of the cat
    /// - parameter mods: StatModifications to be applied to base attribute value
    private func applyAttrMods(baseValue: Int, mods: [AttrModification]) -> Int {
        var value = baseValue
        for mod in mods {
            value += mod.modification
        }
        return value
    }
}