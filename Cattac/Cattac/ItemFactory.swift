/*
    ItemFactory, for creating Item objects
*/

private let _itemFactorySharedInstance: ItemFactory = ItemFactory()

class ItemFactory {
    
    private init() {
    }
    
    class var sharedInstance: ItemFactory {
        return _itemFactorySharedInstance
    }
    
    func createItem(nameOfItemToCreate: String) -> Item? {
        var itemToReturn: Item?
        
        switch nameOfItemToCreate {
        case Constants.itemName.milk:
            itemToReturn = MilkItem()
        case Constants.itemName.nuke:
            itemToReturn = NukeItem()
        case Constants.itemName.projectile:
            itemToReturn = ProjectileItem()
        default:
            break
        }
        
        return itemToReturn
    }
    
}