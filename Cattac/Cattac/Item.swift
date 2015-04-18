/*
    The Item object
*/

import SpriteKit

class Item: TileEntity {
    var name: String!
    var sprite: SKSpriteNode
    
    private init(itemName: String, _ sprite: SKSpriteNode) {
        self.name = itemName
        self.sprite = sprite
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKNode {
        return sprite
    }
    
    func effect(cat: Cat) {
        assertionFailure("Item.effect() not implemented!")
    }
}

class MilkItem: Item {
    init() {
        super.init(itemName: Constants.itemName.milk,
            SKSpriteNode(imageNamed: "Milk.png"))
    }
    
    override func effect(cat: Cat) {
        cat.heal(Constants.itemEffect.milkHpIncreaseEffect)
    }
}

class ProjectileItem: Item {
    init() {
        super.init(itemName: Constants.itemName.projectile,
            SKSpriteNode(imageNamed: "Projectile.png"))
    }
    
    override func effect(cat: Cat) {
        cat.inflict(Constants.itemEffect.projectileDmg)
    }
}

class NukeItem: Item {
    init() {
        super.init(itemName: Constants.itemName.nuke,
            SKSpriteNode(imageNamed: "Nuke.png"))
    }
    
    override func effect(cat: Cat) {
        cat.inflict(Constants.itemEffect.nukeDmg)
    }
}