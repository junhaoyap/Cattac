/*
    Based upon the ConnectionManager, used for things pertaining directly
    for Cattac
*/

class GameConnectionManager {
    
    let connectionManager: ConnectionManager!
    
    init(urlProvided: String) {
        connectionManager = ConnectionManager(firebase: urlProvided)
    }
    
    // TODO: Start adding abstracted connectivity commands within Cattac
}
