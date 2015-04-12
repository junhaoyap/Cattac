/*
    Doodad Factory, for creating Doodad objects
*/

enum DoodadType: Int {
    // let LandMine forever be the last doodad so the count works. any better implementation?
    case Trampoline, WatchTower, Fortress, Wormhole, LandMine
    static var count: Int {
        return DoodadType.LandMine.hashValue + 1
    }
}

private let _doodadFactorySharedInstance: DoodadFactory = DoodadFactory()

class DoodadFactory {
    
    private init() {
    }
    
    class var sharedInstance: DoodadFactory {
        return _doodadFactorySharedInstance
    }
    
    func createDoodad(doodadType: DoodadType) -> Doodad? {
        var doodadToReturn: Doodad?
        
        switch doodadType {
        case .WatchTower:
            return WatchTowerDoodad()
        case .Trampoline:
            return TrampolineDoodad()
        case .LandMine:
            return LandMineDoodad()
        case .Fortress:
            return FortressDoodad()
        case .Wormhole:
            return WormholeDoodad()
        default:
            return nil
        }
    }
    
    func createDoodad(doodadName: String) -> Doodad? {
        switch doodadName {
        case Constants.Doodad.wallString:
            return Wall()
        case Constants.Doodad.landMineString:
            return LandMineDoodad()
        case Constants.Doodad.fortressString:
            return FortressDoodad()
        case Constants.Doodad.trampolineString:
            return TrampolineDoodad()
        case Constants.Doodad.watchTowerString:
            return WatchTowerDoodad()
        case Constants.Doodad.wormholeString:
            return WormholeDoodad()
        default:
            return nil
        }
    }
    
    func generateWall() -> Doodad {
        return Wall()
    }
    
    func randomDoodad() -> Doodad {
        return randomDoodad([])
    }
    
    func randomDoodad(excludeDoodads: [DoodadType]) -> Doodad {
        var type = randomDoodadType()
        while contains(excludeDoodads, type) {
            type = randomDoodadType()
        }
        return createDoodad(type)!
    }
    
    func randomDoodadType() -> DoodadType {
        return DoodadType(rawValue: Int(arc4random_uniform(UInt32(DoodadType.count))))!
    }
}