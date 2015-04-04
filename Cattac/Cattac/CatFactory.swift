/*
    Cat Factory, for creating Cat objects
*/

class CatFactory {
    
    func createCat(nameOfCatToCreate: String) -> Cat? {
        var catToReturn: Cat?
        var catAttributes: [Int]?
        
        switch nameOfCatToCreate {
        case Constants.catName.nyanCat:
            catAttributes = Constants.catAttributes.nyanCatAttributes
        case Constants.catName.nalaCat:
            catAttributes = Constants.catAttributes.nalaCatAttributes
        case Constants.catName.grumpyCat:
            catAttributes = Constants.catAttributes.grumpyCatAttributes
        case Constants.catName.pusheenCat:
            catAttributes = Constants.catAttributes.pusheenCatAttributes
        default:
            break
        }
        
        if let attr = catAttributes {
            catToReturn = Cat(
                catName: nameOfCatToCreate,
                catHp: attr[0],
                catDef: attr[1],
                catPuiDmg: attr[2],
                catFartDmg: attr[3]
            )
        }

        return catToReturn
    }
}