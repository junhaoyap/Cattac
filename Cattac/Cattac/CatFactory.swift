/*
    Cat Factory, for creating Cat objects
*/

private let _catFactorySharedInstance: CatFactory = CatFactory()

class CatFactory {
    
    private init() {
    }
    
    class var sharedInstance: CatFactory {
        return _catFactorySharedInstance
    }
    
    func createCat(nameOfCatToCreate: String) -> Cat? {
        var catToReturn: Cat?
        let catAttributes = Constants.cat.attributes[nameOfCatToCreate]
        
        if let attr = catAttributes {
            catToReturn = Cat(catName: nameOfCatToCreate, attributes: attr)
        }

        return catToReturn
    }
}