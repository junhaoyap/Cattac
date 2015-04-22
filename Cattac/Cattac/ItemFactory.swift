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
    var name: String {
        switch self {
        case .Milk:
            return Constants.itemName.milk
        case .Projectile:
            return Constants.itemName.projectile
        case .Nuke:
            return Constants.itemName.nuke
        }
    }
}

private let _itemFactorySharedInstance: ItemFactory = ItemFactory()

class ItemFactory {
    
    private init() {
    }
    
    class var sharedInstance: ItemFactory {
        return _itemFactorySharedInstance
    }
    
    func typeForName(name: String) -> ItemType? {
        switch name {
        case Constants.itemName.milk:
            return .Milk
        case Constants.itemName.nuke:
            return .Nuke
        case Constants.itemName.projectile:
            return .Projectile
        default:
            return nil
        }
    }
    
    func createItem(name: String) -> Item? {
        return createItem(typeForName(name)!)
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