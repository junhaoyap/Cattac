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
    
    let server: Server!
    
    init(firebase urlProvided: String) {
        server = FirebaseServer(urlProvided: urlProvided)
    }
    
    init(server: Server) {
        self.server = server
    }
    
    func readOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        server.readOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func overwrite(childUrl: String, data: [String: AnyObject]) {
        server.overwrite(childUrl, data: data)
    }
    
    func update(childUrl: String, data: [String: AnyObject]) {
        server.update(childUrl, data: data)
    }
    
    func watchUpdateOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        server.watchUpdateOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }

    func watchUpdate(childUrl: String, onComplete: (AnyObject) -> ()) {
        server.watchUpdate(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchNewOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        server.watchNewOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }

    func watchNew(childUrl: String, onComplete: (AnyObject) -> ()) {
        server.watchNew(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func createUser(email: String, password: String,
        onComplete: (NSError!, [NSObject: AnyObject]!) -> ()) {
            server.createUser(email, password: password, onComplete: {
                error, result in
                
                onComplete(error, result)
            })
    }

    func authUser(email: String, password: String,
        onComplete: (NSError!, AnyObject) -> ()) {
            server.authUser(email, password: password, onComplete: {
                error, authdata in
                
                onComplete(error, authdata)
            })
    }
    
    func getAuthId() -> String {
        return server.getAuthId()
    }

    func append(childUrl: String) -> ConnectionManager {
        return server.append(childUrl)
    }

    func removeAllObservers() {
        server.removeAllObservers()
    }
}