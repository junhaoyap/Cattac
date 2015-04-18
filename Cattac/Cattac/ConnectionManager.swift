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
    
    let firebaseServer: FirebaseServer?
    
    init(typeOfService: String, urlProvided: String) {
        if (typeOfService == "Firebase") {
            firebaseServer = FirebaseServer(urlProvided: urlProvided)
        } else {
            // TODO: Support other types of servers
            
            // For now, just let the program crash
        }
    }
    
    func readOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        firebaseServer!.readOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
//    func overwrite(childUrl: String, data: [String: String])
//    
//    func update(childUrl: String, data: [String: String])
//    
//    func watchUpdateOnce(childUrl: String, onComplete: (AnyObject) -> ())
//    
//    func watchUpdate(childUrl: String, onComplete: (AnyObject) -> ())
//    
//    func watchNewOnce(childUrl: String, onComplete: (AnyObject) -> ())
//    
//    func watchNew(childUrl: String, onComplete: (AnyObject) -> ())
//    
//    func createUser(email: String, password: String,
//        onComplete: (NSError!, [NSObject: AnyObject]!) -> ())
//    
//    func authUser(email: String, password: String,
//        onComplete: (NSError!, AnyObject) -> ())
//    
//    func getAuthId() -> String
//    
//    func append(childUrl: String) -> ConnectionManager
//    
//    func removeAllObservers()
}