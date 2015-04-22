class Inventory {
    private var _milkItemCount: Int = 0
    private var _projectileItemCount: Int = 0
    private var _nukeItemCount: Int = 0
    
    init() {
        
    }
    
    var selectedItem: ItemType?
    
    var firstItem: ItemType? {
        if _milkItemCount > 0 {
            return .Milk
        } else if _projectileItemCount > 0 {
            return .Projectile
        } else if _nukeItemCount > 0 {
            return .Nuke
        } else {
            return nil
        }
    }
    
    func addItem(item: Item) {
        return addItem(typeForItem(item)!)
    }
    
    func addItem(type: ItemType) {
        switch type {
        case .Milk:
            _milkItemCount++
        case .Projectile:
            _projectileItemCount++
        case .Nuke:
            _nukeItemCount++
        }
    }
    
    func useItem(item: Item) {
        return useItem(typeForItem(item)!)
    }
    
    func useItem(type: ItemType) {
        switch type {
        case .Milk:
            _milkItemCount--
        case .Projectile:
            _projectileItemCount--
        case .Nuke:
            _nukeItemCount--
        }
    }
    
    func getItem(type: ItemType) -> Item {
        switch type {
        case .Milk:
            return MilkItem()
        case .Projectile:
            return ProjectileItem()
        case .Nuke:
            return NukeItem()
        }
    }
    
    func count(type: ItemType) -> Int {
        switch type {
        case .Milk:
            return _milkItemCount
        case .Projectile:
            return _projectileItemCount
        case .Nuke:
            return _nukeItemCount
        }
    }
    
    func typeForItem(item: Item?) -> ItemType? {
        switch item {
        case is MilkItem:
            return .Milk
        case is ProjectileItem:
            return .Projectile
        case is NukeItem:
            return .Nuke
        default:
            return nil
        }
    }
}