/*
    The Doodad object
*/

import Foundation

enum ItemType {
    case Milk, Rock, Nuke, Laser
}

class Item {
    var name: String!
    
    init(itemName: String) {
        name = itemName
    }
}

class MilkItem: Item {
    
}

class RockItem: Item {
    
}

class NukeItem: Item {
    
}

class LaserItem: Item {
    
}