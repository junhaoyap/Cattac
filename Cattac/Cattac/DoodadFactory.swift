/*
    Doodad Factory, for creating Doodad objects
*/

class DoodadFactory {
    
    func createCat(nameOfDoodadToCreate: String) -> Doodad? {
        var doodadToReturn: Doodad?
        
        switch nameOfDoodadToCreate {
        case Constants.doodadName.watchTower:
            doodadToReturn = Doodad(doodadName: nameOfDoodadToCreate)
        case Constants.doodadName.trampoline:
            doodadToReturn = Doodad(doodadName: nameOfDoodadToCreate)
        case Constants.doodadName.fortress:
            doodadToReturn = Doodad(doodadName: nameOfDoodadToCreate)
        case Constants.doodadName.wormhole:
            doodadToReturn = Doodad(doodadName: nameOfDoodadToCreate)
        default:
            break
        }
        
        return doodadToReturn
    }
}