class GameManager {

    private var _playerPositions: [String:TileNode]
    private var _playerMoveToPositions: [String:TileNode]
    private var _playerActions: [String:Action]
    private var _players: [String:Cat]
    private var _playerAIControlled: [String:Cat]
    private var _playerTurnComplete: [String:Cat]
    private var _playerMovementPaths: [String:[TileNode]]
    private var _playerMovementAnimationCompleted: [String:Bool]
    private var _playerActionAnimationCompleted: [String:Bool]
    private var _playerItems: [String:Item]
    private var _doodadsToRemove: [Int: Doodad]

    init() {
        _playerPositions = [:]
        _playerMoveToPositions = [:]
        _playerActions = [:]
        _players = [:]
        _playerAIControlled = [:]
        _playerTurnComplete = [:]
        _playerMovementPaths = [:]
        _playerMovementAnimationCompleted = [:]
        _playerActionAnimationCompleted = [:]
        _playerItems = [:]
        _doodadsToRemove = [:]
    }

    subscript(positionOf player:Cat) -> TileNode? {
        set {
            _playerPositions[player.name] = newValue
        }
        get {
            return _playerPositions[player.name]
        }
    }

    subscript(moveToPositionOf player:Cat) -> TileNode? {
        set {
            _playerMoveToPositions[player.name] = newValue
        }
        get {
            return _playerMoveToPositions[player.name]
        }
    }
    
    subscript(actionOf player:Cat) -> Action? {
        set {
            if newValue == nil {
                _playerActions.removeValueForKey(player.name)
            } else {
                _playerActions[player.name] = newValue
            }
        }
        get {
            return _playerActions[player.name]
        }
    }
    
    subscript(itemOf player:Cat) -> Item? {
        set {
            if newValue == nil {
                _playerItems.removeValueForKey(player.name)
            } else {
                _playerItems[player.name] = newValue
            }
        }
        get {
            return _playerItems[player.name]
        }
    }

    subscript(name: String) -> Cat? {
        return _players[name]
    }
    
    subscript(movementPathOf player:Cat) -> [TileNode]? {
        set {
            _playerMovementPaths[player.name] = newValue
        }
        get {
            return _playerMovementPaths[player.name]
        }
    }
    
    subscript(aiFor player:Cat) -> Bool {
        set {
            if newValue {
                _playerAIControlled[player.name] = player
            } else {
                _playerAIControlled.removeValueForKey(player.name)
            }
        }
        get {
            return _playerAIControlled[player.name] != nil
        }
    }
    
    var players: [String:Cat] {
        return _players
    }
    
    var aiPlayers: [String:Cat] {
        return _playerAIControlled
    }
    
    var playersTurnCompleted: [String: Cat] {
        return _playerTurnComplete
    }

    var doodadsToRemove: [Int:Doodad] {
        set {
            _doodadsToRemove = newValue
        }
        get {
            return _doodadsToRemove
        }
    }

    var movementsCompleted: Bool {
        var allCompleted = true
        
        for completed in _playerMovementAnimationCompleted.values {
            allCompleted = allCompleted && completed
        }
        
        return allCompleted
    }
    
    var allTurnsCompleted: Bool {
        return _playerTurnComplete.count == 3
    }

    var actionsCompleted: Bool {
        var allCompleted = true

        for completed in _playerActionAnimationCompleted.values {
            allCompleted = allCompleted && completed
        }

        return allCompleted
    }

    func registerPlayer(player: Cat) {
        _players[player.name] = player
    }
    
    func registerAIPlayers(players: [Cat]) {
        for player in players {
            self[aiFor: player] = true
        }
    }

    func advanceTurn() {
        _playerPositions = _playerMoveToPositions
        _playerActions = [:]
        _playerTurnComplete = [:]
    }
    
    func playerTurn(player: Cat, moveTo dest: TileNode, action: Action?) {
        self[moveToPositionOf: player] = dest
        self[actionOf: player] = action
        _playerTurnComplete[player.name] = player
    }

    func precalculate() {
        _playerMoveToPositions = _playerPositions
        _playerMovementPaths = [:]

        for (playerName, tileNode) in _playerPositions {
            var player = _players[playerName]!
            
            // effect only move range modification
            if let doodad = tileNode.doodad {
                doodad.premoveEffect(player)

                if doodad.isRemoved() {
                    tileNode.doodad = nil
                    _doodadsToRemove[doodad.getSprite().hashValue] = doodad
                }
            }
            
            _playerMovementAnimationCompleted[playerName] = false
            _playerActionAnimationCompleted[playerName] = false
        }
    }

    func completeMovementOf(player: Cat) {
        _playerMovementAnimationCompleted[player.name] = true
    }

    func completeActionOf(player: Cat) {
        _playerActionAnimationCompleted[player.name] = true
    }
    
    func samePlayer(playerA: Cat, _ playerB: Cat) -> Bool {
        return playerA.name == playerB.name
    }
}