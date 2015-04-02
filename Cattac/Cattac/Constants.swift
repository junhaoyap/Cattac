/*
    Where we keep all the constants
*/

import UIKit
import Foundation

struct Constants {
    struct BasicLevel {
        static let numRows: Int = 10
        static let numColumns: Int = 10
    }
    
    // for randomising which player get which cat, copy the array before playing with it, only for
    // initial reference
    static let catArray = [catName.nyanCat, catName.nalaCat, catName.grumpyCat, catName.pusheenCat]
    
    struct catAttributes {
        // always hp, puiDmg then fartDmg
        
        static let nyanCatAttributes = [500, 50, 25]
        // nyan cat is the most balanced cat
        
        static let nalaCatAttributes = [600, 45, 20]
        // nala cat is thicker, but does less dmg
        
        static let grumpyCatAttributes = [400, 55, 30]
        // grumpy cat is thinner, but does more dmg
        
        static let pusheenCatAttributes = [500, 40, 30]
        // pusheen cat pui for less dmg, but does more fartdmg, otherwise balanced
        
        static let poopDmg = 15
    }
    
    struct catName {
        static let nyanCat = "nyanCat"
        static let nalaCat = "nalaCat"
        static let grumpyCat = "grumpyCat"
        static let pusheenCat = "pusheenCat"
    }
    
    struct doodadName {
        static let watchTower = "watchTower"
        static let trampoline = "trampoline"
        static let fortress = "fortress"
        static let wormhole = "wormhole"
    }
    
    struct itemName {
        static let milk = "milk"
        static let nuke = "nuke"
        static let rock = "rock"
    }
    
    struct itemEffect {
        static let milkHpIncreaseEffect = 150
        static let nukeDmg = 100
        static let rockDmg = 150
    }
}