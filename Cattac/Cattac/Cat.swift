/*
    The Cat object
*/

import Foundation
import SpriteKit

enum CatType: Int {
    case MAIN
}

class Cat: TileEntity {
    private let _id: String
    private let _type: CatType
    private let _sprite = SKSpriteNode(imageNamed: "Nala.png") //did this to try out only.
    
    var id: String {
        return _id
    }
    
    var type: CatType {
        return _type
    }
    
    init(_ id: String, _ type: CatType) {
        _id = id
        _type = type
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKSpriteNode {
        return _sprite
    }
}

//class Cat {
//    var name: String!
//    var hp: Int!
//    var puiDmg: Int!
//    var fartDmg: Int!
//    var poopDmg: Int!
//    
//    init(catName: String, catHp: Int, catPuiDmg: Int, catFartDmg: Int) {
//        name = catName
//        hp = catHp
//        puiDmg = catPuiDmg
//        fartDmg = catFartDmg
//        poopDmg = Constants.catAttributes.poopDmg
//    }
//}