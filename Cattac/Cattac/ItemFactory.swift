/*
    ItemFactory, for creating Item objects
*/

class ItemFactory {
    
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