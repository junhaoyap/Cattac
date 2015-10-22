/*
    String utility methods
*/

class StringUtils {
    
    func splitOnSlash(stringWithSlashes: String) -> [String] {
        var stringsToReturn: [String] = []
        
        if stringWithSlashes == "" {
            return stringsToReturn
        } else {
            var slashIndexes: [String.Index] = []
            
            let endStringIndex: String.Index = stringWithSlashes.endIndex
                .predecessor()
            
            for index in stringWithSlashes.characters.indices {
                if stringWithSlashes[index] == "/" {
                    slashIndexes.append(index)
                }
            }
            
            var stringToAppend = ""
            
            for index in stringWithSlashes.characters.indices {
                let character = stringWithSlashes[index]
                
                if slashIndexes.contains(index) {
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
    
    func getNameFromEmail(email: String) -> String {
        var stringToReturn = ""
        
        var atIndex = email.startIndex
        
        for index in email.characters.indices {
            if email[index] == "@" {
                atIndex = index
            }
        }
        
        for index in email.characters.indices {
            let character = email[index]
            
            if index == atIndex {
                break
            } else {
                stringToReturn.append(character)
            }
        }
        
        return stringToReturn
    }
}