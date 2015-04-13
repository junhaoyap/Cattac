class GameManager {

    private var _playerPositions: [String:TileNode]
    private var _playerMoveToPositions: [String:TileNode]
    private var _playerActions: [String:Action]
    private var _players: [String:Cat]
    private var _playerMovementPaths: [String:[TileNode]]
    private var _playerMovementAnimationCompleted: [String:Bool]
    private var _playerActionAnimationCompleted: [String:Bool]
    private var _doodadsToRemove: [Int: Doodad]

    init() {
        _playerPositions = [:]
        _playerMoveToPositions = [:]
        _playerActions = [:]
        _players = [:]
        _playerMovementPaths = [:]
        _playerMovementAnimationCompleted = [:]
        _playerActionAnimationCompleted = [:]
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

    var players: [String:Cat] {
        return _players
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

    func advanceTurn() {
        _playerPositions = _playerMoveToPositions
        _playerActions = [:]
        
        // might need to move all these calculations (with those
        // in precalculate) back to game engine, to call UI
        // animations when effect
        for (playerName, tileNode) in _playerPositions {
            var player = _players[playerName]!
            
            if let poop = tileNode.poop {
                poop.effect(player)
                tileNode.poop = nil
            }
        }
    }

    func precalculate() {
        _playerMoveToPositions = _playerPositions
        _playerMovementPaths = [:]

        for (playerName, tileNode) in _playerPositions {
            var player = _players[playerName]!

            if let doodad = tileNode.doodad {
                doodad.effect(player)

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
}