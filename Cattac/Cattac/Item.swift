/*
    The Item object
*/

import SpriteKit

enum ItemType {
    case Milk, Rock, Nuke
}

class Item: TileEntity {
    var name: String!
    
    init(itemName: String) {
        name = itemName
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKNode {
        return SKLabelNode(text: "?")
    }
    
    func effect(cat: Cat) {
        assertionFailure("Item.effect() not implemented!")
    }
}

class MilkItem: Item {
    override func effect(cat: Cat) {
        cat.heal(Constants.itemEffect.milkHpIncreaseEffect)
    }
    
    override func getSprite() -> SKNode {
        return SKLabelNode(text: "H")
    }
}

class RockItem: Item {
    override func effect(cat: Cat) {
        cat.inflict(Constants.itemEffect.rockDmg)
    }
    
    override func getSprite() -> SKNode {
        return SKLabelNode(text: "R")
    }
}

class NukeItem: Item {
    override func effect(cat: Cat) {
        cat.inflict(Constants.itemEffect.nukeDmg)
    }
    
    override func getSprite() -> SKNode {
        return SKLabelNode(text: "N")
    }
}