/*
    String utility methods
*/

class StringUtils {
    
    func splitOnSlash(stringWithSlashes: String) -> [String] {
        var slashIndexes: [String.Index] = []
        var stringsToReturn: [String] = []
        let endStringIndex: String.Index = stringWithSlashes.endIndex.predecessor()
        
        for index in indices(stringWithSlashes) {
            if stringWithSlashes[index] == "/" {
                slashIndexes.append(index)
            }
        }
        
        var stringToAppend = ""
        
        for index in indices(stringWithSlashes) {
            let character = stringWithSlashes[index]
            
            if contains(slashIndexes, index) {
                stringsToReturn.append(stringToAppend)
                stringToAppend = ""
            } else if (index == endStringIndex) {
                stringToAppend.append(character)
                stringsToReturn.append(stringToAppend)
            } else {
                stringToAppend.append(character)
            }
        }
        
        return stringsToReturn
    }
}