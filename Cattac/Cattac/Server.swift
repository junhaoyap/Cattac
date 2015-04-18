/*
    The Server protocol that servers that uses the ConnectionManager library
    must adhere to
*/

protocol Server {
    
    func readOnce(childUrl: String, onComplete: (AnyObject) -> ())
    
    func overwrite(childUrl: String, data: [String: String])
    
    func update(childUrl: String, data: [String: String])
    
    func watchUpdateOnce(childUrl: String, onComplete: (AnyObject) -> ())
    
    func watchUpdate(childUrl: String, onComplete: (AnyObject) -> ())
    
    func watchNewOnce(childUrl: String, onComplete: (AnyObject) -> ())
    
    func watchNew(childUrl: String, onComplete: (AnyObject) -> ())
    
    func createUser(email: String, password: String,
        onComplete: (NSError!, [NSObject: AnyObject]!) -> ())
    
    func authUser(email: String, password: String,
        onComplete: (NSError!, AnyObject) -> ())
    
    func getAuthId() -> String
    
    func append(childUrl: String) -> ConnectionManager
    
    func removeAllObservers()
}