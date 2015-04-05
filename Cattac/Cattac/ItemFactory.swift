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
        var ItemToReturn: Item?
        
        switch nameOfItemToCreate {
        case Constants.itemName.milk:
            ItemToReturn = Item(itemName: nameOfItemToCreate)
        case Constants.itemName.nuke:
            ItemToReturn = Item(itemName: nameOfItemToCreate)
        case Constants.itemName.rock:
            ItemToReturn = Item(itemName: nameOfItemToCreate)
        default:
            break
        }
        
        return ItemToReturn
    }
    
}