/*
    The Cat object
*/

import Foundation

class Cat {
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
}