/*
    The packaged firebase server that contains the Firebase methods
*/
import Firebase

class FirebaseServer: Server {
    
    let stringUtil: StringUtils = StringUtils()
    let ref: Firebase?
    let baseUrl: String!
    
    init(urlProvided: String) {
        baseUrl = urlProvided
        ref = Firebase(url: urlProvided)
    }
    
    func readOnce(childUrl: String, onComplete: (AnyObject) -> ()) {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var readRef = ref!
        
        for childString in splittedStringsToConstructRef {
            readRef = readRef.childByAppendingPath(childString)
        }
        
        readRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            onComplete(snapshot)
        })
    }
    
    func overwrite(childUrl: String, data: [String: AnyObject]) {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var overwriteRef = ref!
        
        for childString in splittedStringsToConstructRef {
            overwriteRef = overwriteRef.childByAppendingPath(childString)
        }
        
        overwriteRef.setValue(data)
    }
    
    func update(childUrl: String, data: [String: AnyObject]) {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var updateRef = ref!
        
        for childString in splittedStringsToConstructRef {
            updateRef = updateRef.childByAppendingPath(childString)
        }
        
        updateRef.updateChildValues(data)
    }
    
    func watchUpdateOnce(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var changeRef = ref!
        
        for childString in splittedStringsToConstructRef {
            changeRef = changeRef.childByAppendingPath(childString)
        }
        
        changeRef.observeSingleEventOfType(.ChildChanged, withBlock: {
            snapshot in
            
            onComplete(snapshot)
        })
            
        return ObserverReference(unregister: {
            changeRef.removeAllObservers()
        })
    }
    
    func watchUpdate(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var changeRef = ref!
        
        for childString in splittedStringsToConstructRef {
            changeRef = changeRef.childByAppendingPath(childString)
        }
        
        changeRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            onComplete(snapshot)
        })
        
        return ObserverReference(unregister: {
            changeRef.removeAllObservers()
        })
    }
    
    func watchRemovedOnce(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var changeRef = ref!
        
        for childString in splittedStringsToConstructRef {
            changeRef = changeRef.childByAppendingPath(childString)
        }
        
        changeRef.observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            
            onComplete(snapshot)
        })
        
        return ObserverReference(unregister: {
            changeRef.removeAllObservers()
        })
    }
    
    func watchNewOnce(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference {
        let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
        var changeRef = ref!
        
        for childString in splittedStringsToConstructRef {
            changeRef = changeRef.childByAppendingPath(childString)
        }
        
        changeRef.observeSingleEventOfType(.ChildAdded, withBlock: {
            snapshot in
            
            onComplete(snapshot)
        })
            
        return ObserverReference(unregister: {
            changeRef.removeAllObservers()
        })
    }
    
    func watchNew(childUrl: String,
        onComplete: (AnyObject) -> ()) -> ObserverReference {
            let splittedStringsToConstructRef = stringUtil.splitOnSlash(childUrl)
        
            var changeRef = ref!
        
            for childString in splittedStringsToConstructRef {
                changeRef = changeRef.childByAppendingPath(childString)
            }
        
            changeRef.observeEventType(.ChildAdded, withBlock: {
                snapshot in
            
                onComplete(snapshot)
            })
            
            return ObserverReference(unregister: {
                changeRef.removeAllObservers()
            })
    }
    
    func createUser(email: String, password: String,
        onComplete: (NSError!, [NSObject: AnyObject]!) -> ()) {
            ref!.createUser(email, password: password,
                withValueCompletionBlock: {
                    error, result in
                    
                    onComplete(error, result)
            })
    }
    
    func authUser(email: String, password: String,
        onComplete: (NSError!, AnyObject?) -> ()) {
            ref!.authUser(email, password: password) {
                error, authData in
                
                onComplete(error, authData)
            }
    }
    
    func getAuthId() -> String {
        let uid = ref!.authData.uid
        
        return uid
    }
    
    func getEmail() -> String {
        let authData = ref!.authData
        let providerData = authData.providerData
        let email = providerData["email"] as? String
        
        return email!
    }
    
    func append(childUrl: String) -> ConnectionManager {
        let appendedUrl = baseUrl + childUrl + "/"
        
        return ConnectionManager(firebase: appendedUrl)
    }
    
    func removeAllObservers() {
        ref!.removeAllObservers()
    }
}