// Enumeration of all the states of the game.
enum GameState: Int {
    case
    Precalculation,
    PlayerAction,
    ServerUpdate,
    WaitForAll,
    StartMovesExecution,
    MovesExecution,
    StartActionsExecution,
    ActionsExecution,
    PostExecution

    private var name: String {
        let names = [
            "Precalculation",
            "Player Action",
            "Server Update",
            "Wait for All",
            "Start Moves Execution",
            "Moves Execution",
            "Start Actions Execution",
            "Actions Execution",
            "Post Execution"
        ]

        return names[rawValue]
    }
}

extension GameState: Printable {
    var description: String {
        return name
    }
}