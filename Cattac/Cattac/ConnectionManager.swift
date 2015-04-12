/*
    Our library for managing connectivity - ConnectionManager

    Plans to support:
    1. Firebase
    2. Parse
    3. Game Centre
    4. Self written servers (must adhere to our protocol)

    Currently supports:
    1. Firebase
*/

class ConnectionManager {
    let stringUtil: StringUtils = StringUtils()
    let baseFirebaseRef: Firebase?
    
    init(urlProvided: String) {
        baseFirebaseRef = Firebase(url: urlProvided)
    }
    
    func readOnce(childUrl: String, onComplete: (FDataSnapshot) -> ()) {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var readRef = baseFirebaseRef!
        
        for childString in splittedStringsToConstructRef {
            readRef = readRef.childByAppendingPath(childString)
        }
        
        readRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func getAuthId() -> String {
        let uid = baseFirebaseRef!.authData.uid
        
        return uid
    }
    
    func overwrite(childUrl: String, data: [String]) {
        
    }
    
    func update(childUrl: String, data: [String]) {
        
    }
    
    func watch(childUrl: String, withBlock: ()) {
        
    }
}