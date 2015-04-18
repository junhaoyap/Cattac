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
    
    func overwrite(childUrl: String, data: [String: String]) {
        firebaseServer!.overwrite(childUrl, data: data)
    }
    
    func update(childUrl: String, data: [String: String]) {
        firebaseServer!.update(childUrl, data: data)
    }
    
    func watchUpdateOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        firebaseServer!.watchUpdateOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }

    func watchUpdate(childUrl: String, onComplete: (AnyObject) -> ()) {
        firebaseServer!.watchUpdate(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func watchNewOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        firebaseServer!.watchNewOnce(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }

    func watchNew(childUrl: String, onComplete: (AnyObject) -> ()) {
        firebaseServer!.watchNew(childUrl, onComplete: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func createUser(email: String, password: String,
        onComplete: (NSError!, [NSObject: AnyObject]!) -> ()) {
            firebaseServer!.createUser(email, password: password, onComplete: {
                error, result in
                
                onComplete(error, result)
            })
    }

    func authUser(email: String, password: String,
        onComplete: (NSError!, AnyObject) -> ()) {
            firebaseServer!.authUser(email, password: password, onComplete: {
                error, authdata in
                
                onComplete(error, authdata)
            })
    }
    
    func getAuthId() -> String {
        return firebaseServer!.getAuthId()
    }

    func append(childUrl: String) -> ConnectionManager {
        return firebaseServer!.append(childUrl)
    }

    func removeAllObservers() {
        firebaseServer!.removeAllObservers()
    }
}