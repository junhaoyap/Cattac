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
    let baseRef: Firebase?
    
    // For now because we only support Firebase, we will just use Stirng
    // to init the baseReference
    init(urlProvided: String) {
        baseRef = Firebase(url: urlProvided)
        // the url provided must point to your Firebase's root reference
        // will insert more of such comments so that when we package
        // it up we know what to write / defend
    }
    
    // For reading a value once from a given reference point
    func readOnce(childUrl: String, data: [String]) {
        // does nothing for now
    }
    
    // For overwriting all the data from a given reference point
    func overwrite(childUrl: String, data: [String]) {
        // does nothing for now
    }
    
    // For updating or adding data to a given reference point, differs
    // from overwrite in that it doesn't delete all other fields
    func update(childUrl: String, data: [String]) {
        // does nothing for now
    }
    
    // For watching a change to data from the given reference point, accepts
    // an extra block to execute when any of the data does change
    func watch(childUrl: String, data: [String], withBlock: ()) {
        // does nothing for now
    }
}