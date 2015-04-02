/*
    The Cat object
*/

import Foundation
import SpriteKit

class Cat: TileEntity {
    private let _sprite = SKSpriteNode(imageNamed: "Nala.png") //did this to try out only.
    var name: String!
    var hp: Int!
    var puiDmg: Int!
    var fartDmg: Int!
    var poopDmg: Int!
    
    init(catName: String, catHp: Int, catPuiDmg: Int, catFartDmg: Int) {
        name = catName
        hp = catHp
        puiDmg = catPuiDmg
        fartDmg = catFartDmg
        poopDmg = Constants.catAttributes.poopDmg
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKSpriteNode {
        return _sprite
    }
}