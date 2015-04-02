/*
    Cat Factory, for creating Cat objects
*/

class CatFactory {
    
    func createCat(nameOfCatToCreate: String) -> Cat? {
        var catToReturn: Cat?
        
        switch nameOfCatToCreate {
        case Constants.catName.nyanCat:
            let catAttributes = Constants.catAttributes.nyanCatAttributes
            catToReturn = Cat(
                catName: nameOfCatToCreate,
                catHp: catAttributes[0],
                catPuiDmg: catAttributes[1],
                catFartDmg: catAttributes[2]
            )
        case Constants.catName.nalaCat:
            let catAttributes = Constants.catAttributes.nalaCatAttributes
            catToReturn = Cat(
                catName: nameOfCatToCreate,
                catHp: catAttributes[0],
                catPuiDmg: catAttributes[1],
                catFartDmg: catAttributes[2]
            )
        case Constants.catName.grumpyCat:
            let catAttributes = Constants.catAttributes.grumpyCatAttributes
            catToReturn = Cat(
                catName: nameOfCatToCreate,
                catHp: catAttributes[0],
                catPuiDmg: catAttributes[1],
                catFartDmg: catAttributes[2]
            )
        case Constants.catName.pusheenCat:
            let catAttributes = Constants.catAttributes.pusheenCatAttributes
            catToReturn = Cat(
                catName: nameOfCatToCreate,
                catHp: catAttributes[0],
                catPuiDmg: catAttributes[1],
                catFartDmg: catAttributes[2]
            )
        default:
            break
        }

        return catToReturn
    }
}