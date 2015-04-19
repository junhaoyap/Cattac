/*
    Based upon the ConnectionManager, used for things pertaining directly
    for Cattac
*/

class GameConnectionManager {
    
    let connectionManager: ConnectionManager!
    
    init(urlProvided: String) {
        connectionManager = ConnectionManager(firebase: urlProvided)
    }
    
    func readOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.readOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func overwrite(childUrl: String, data: [String: String]) {
        connectionManager.overwrite(childUrl, data: data)
    }
    
    func update(childUrl: String, data: [String: String]) {
        connectionManager.update(childUrl, data: data)
    }
    
    func watchUpdateOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchUpdateOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchUpdate(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchUpdate(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchNewOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchNewOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchNew(childUrl: String, onComplete: (AnyObject) -> ()) {
        connectionManager.watchNew(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func createUser(email: String, password: String,
        onComplete: (NSError!, [NSObject: AnyObject]!) -> ()) {
            connectionManager.createUser(email, password: password, onComplete: {
                error, result in
                
                onComplete(error, result)
            })
    }
    
    func authUser(email: String, password: String,
        onComplete: (NSError!, AnyObject) -> ()) {
            connectionManager.authUser(email, password: password, onComplete: {
                error, authdata in
                
                onComplete(error, authdata)
            })
    }
    
    func getAuthId() -> String {
        return connectionManager.getAuthId()
    }
    
    func append(childUrl: String) -> ConnectionManager {
        return connectionManager.append(childUrl)
    }
    
    func removeAllObconnectionManagers() {
        connectionManager.removeAllObservers()
    }
    
    // TODO: Abstract specific connectivity commands within Cattac
    // on top of the more generic ones above
}
