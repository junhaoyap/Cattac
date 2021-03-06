class GameManager {

    private var _allPlayers: [String:Cat]
    private var _playerPositions: [String:TileNode]
    private var _playerMoveToPositions: [String:TileNode]
    private var _playerActions: [String:Action]
    private var _players: [String:Cat]
    private var _playerNumber: [String:Int]
    private var _playerAIControlled: [String:Cat]
    private var _playerTurnComplete: [String:Cat]
    private var _playerMovementPaths: [String:[TileNode]]
    private var _deconflictMovementPaths: [String:[TileNode]]
    private var _playerItems: [String:Inventory]
    private var _doodadsToRemove: [Int: Doodad]
    private var _playerRanks: [String:Int]
    private var _playersDead: [String:Cat]
    private var _dyingPlayers: [Cat]

    init() {
        _allPlayers = [:]
        _playerPositions = [:]
        _playerMoveToPositions = [:]
        _playerActions = [:]
        _players = [:]
        _playerNumber = [:]
        _playerAIControlled = [:]
        _playerTurnComplete = [:]
        _playerMovementPaths = [:]
        _deconflictMovementPaths = [:]
        _playerItems = [:]
        _doodadsToRemove = [:]
        _playerRanks = [:]
        _playersDead = [:]
        _dyingPlayers = []
    }
    
    subscript(positionOf player:Cat) -> TileNode? {
        set {
            _playerPositions[player.name] = newValue
        }
        get {
            return _playerPositions[player.name]
        }
    }
    
    subscript(playerNumFor player:Cat) -> Int? {
        set {
            _playerNumber[player.name] = newValue
        }
        get {
            return _playerNumber[player.name]
        }
    }
    
    subscript(playerWithNum playerNum:Int) -> Cat? {
        get {
            for (name, num) in _playerNumber {
                if num == playerNum {
                    return _allPlayers[name]
                }
            }
            return nil
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
    
    subscript(inventoryOf player:Cat) -> Inventory? {
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
    
    subscript(deconflictPathOf player:Cat) -> [TileNode]? {
        set {
            _deconflictMovementPaths[player.name] = newValue
        }
        get {
            return _deconflictMovementPaths[player.name]
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

    var allPlayers: [String:Cat] {
        return _allPlayers
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
    
    var allTurnsCompleted: Bool {
        return _playerTurnComplete.count == _players.count
    }

    var dyingPlayers: [Cat] {
        return _dyingPlayers
    }

    var gameEnded: Bool {
        return _players.count <= 1
    }

    var playerRanks: [String:Int] {
        return _playerRanks
    }

    func registerPlayer(player: Cat, playerNum: Int) {
        _allPlayers[player.name] = player
        _players[player.name] = player
        _playerNumber[player.name] = playerNum
        _playerItems[player.name] = Inventory()
    }
    
    func registerAIPlayers(players: [Cat]) {
        for player in players {
            self[aiFor: player] = true
        }
    }

    func clearPlayerTurns() {
        _playerTurnComplete = [:]
    }
    
    func advanceTurn() {
        _playerPositions = _playerMoveToPositions
        _playerActions = [:]
        _playerTurnComplete = [:]

        for (playerName, player) in _allPlayers {
            if _playersDead[playerName] == nil {
                if player.isDead {
                    _playersDead[playerName] = player
                    _players.removeValueForKey(playerName)
                    _playerAIControlled.removeValueForKey(playerName)
                    _playerPositions.removeValueForKey(playerName)
                    _playerMoveToPositions.removeValueForKey(playerName)
                    _dyingPlayers.append(player)
                }
            }
        }

        for player in _dyingPlayers {
            _playerRanks[player.name] = _players.count + 1
        }

        if _players.count == 1 {
            for (playerName, _) in _players {
                _playerRanks[playerName] = 1
            }
        }
    }
    
    func playerTurn(player: Cat, moveTo dest: TileNode, action: Action?) {
        self[moveToPositionOf: player] = dest
        self[actionOf: player] = action
        _playerTurnComplete[player.name] = player
    }

    func precalculate() {
        _playerMoveToPositions = _playerPositions
        _deconflictMovementPaths = [:]
        _playerMovementPaths = [:]
        _dyingPlayers = []

        for (playerName, tileNode) in _playerPositions {
            let player = _players[playerName]!
            
            // effect only move range modification
            if let doodad = tileNode.doodad {
                doodad.premoveEffect(player)

                if doodad.isRemoved() {
                    tileNode.doodad = nil
                    _doodadsToRemove[doodad.getSprite().hashValue] = doodad
                }
            }
        }
    }
    
    func samePlayer(playerA: Cat, _ playerB: Cat) -> Bool {
        return playerA.name == playerB.name
    }
}