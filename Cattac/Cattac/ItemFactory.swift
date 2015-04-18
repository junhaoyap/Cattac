/*
    ItemFactory, for creating Item objects
*/

enum ItemType: Int {
    // let Nuke forever be the last item so the count works. 
    // any better implementation?
    case Milk, Projectile, Nuke
    static var count: Int {
        return ItemType.Nuke.hashValue + 1
    }
}

private let _itemFactorySharedInstance: ItemFactory = ItemFactory()

class ItemFactory {
    
    private init() {
    }
    
    class var sharedInstance: ItemFactory {
        return _itemFactorySharedInstance
    }
    
    func createItem(type: ItemType) -> Item? {
        switch type {
        case .Milk:
            return MilkItem()
        case .Nuke:
            return NukeItem()
        case .Projectile:
            return ProjectileItem()
        default:
            return nil
        }
    }
    
    func randomItem() -> Item {
        return createItem(randomItemType())!
    }
    
    func randomItemType() -> ItemType {
        return ItemType(rawValue: Int(arc4random_uniform(UInt32(ItemType.count))))!
    }
    
}