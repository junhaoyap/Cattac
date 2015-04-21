/*
    The Server protocol that servers that uses the ConnectionManager library
    must adhere to
*/

protocol Server {
    
    func readOnce(childUrl: String, onComplete: (AnyObject) -> ())
    
    func overwrite(childUrl: String, data: [String: AnyObject])
    
    func update(childUrl: String, data: [String: AnyObject])
    
    func watchUpdateOnce(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference
    
    func watchUpdate(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference
    
    func watchNewOnce(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference
    
    func watchNew(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference
    
    func watchRemovedOnce(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference
    
    func createUser(email: String, password: String,
        onComplete: (NSError!, [NSObject: AnyObject]!) -> ())
    
    func authUser(email: String, password: String,
        onComplete: (NSError!, AnyObject?) -> ())
    
    func getAuthId() -> String
    
    func getEmail() -> String
    
    func append(childUrl: String) -> ConnectionManager
    
    func removeAllObservers()
}