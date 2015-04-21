protocol InventoryListener {
    func onItemAdded(Item)
}

class Inventory {
    private var _milkItem: [MilkItem] = []
    private var _projectileItem: [ProjectileItem] = []
    private var _nukeItem: [NukeItem] = []

    var milkItemListener: InventoryListener?
    var projectileItemListener: InventoryListener?
    var nukeItemListener: InventoryListener?

    func addItem(item: Item) {
        switch item {
        case is MilkItem:
            _milkItem.append(item as MilkItem)
        case is ProjectileItem:
            _projectileItem.append(item as ProjectileItem)
        case is NukeItem:
            _nukeItem.append(item as NukeItem)
        default:
            break
        }
    }

    func removeMilkItem() -> MilkItem? {
        return _milkItem.removeLast()
    }
}