class GameManager {

    private var _playerPositions: [String:TileNode]
    private var _playerMoveToPositions: [String:TileNode]
    private var _playerActions: [String:Action]
    private var _players: [String:Cat]
    private var _playerMovementPaths: [String:[TileNode]]
    private var _doodadsToRemove: [Int: Doodad]

    init() {
        _playerPositions = [:]
        _playerMoveToPositions = [:]
        _playerActions = [:]
        _players = [:]
        _playerMovementPaths = [:]
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
            _playerActions[player.name] = newValue
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

    func registerPlayer(player: Cat) {
        _players[player.name] = player
    }

    func advanceTurn() {
        _playerPositions = _playerMoveToPositions
        _playerActions = [:]
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
        }
    }
}