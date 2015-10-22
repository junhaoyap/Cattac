// Enumeration of all the states of the game.
enum GameState: Int {
    case
    Precalculation,
    PlayerAction,
    ServerUpdate,
    WaitForAll,
    StartMovesExecution,
    MovesExecution,
    DeconflictExecution,
    StartActionsExecution,
    ActionsExecution,
    PostExecution,
    GameEnded

    private var name: String {
        let names = [
            "Precalculation",
            "Player Action",
            "Server Update",
            "Wait for All",
            "Start Moves Execution",
            "Moves Execution",
            "Deconflict Execution",
            "Start Actions Execution",
            "Actions Execution",
            "Post Execution",
            "Game Ended"
        ]

        return names[rawValue]
    }
}

extension GameState: CustomStringConvertible {
    var description: String {
        return name
    }
}