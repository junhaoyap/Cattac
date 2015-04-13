// Enumeration of all the states of the game.
enum GameState: Int {
    case
    Initialization,
    Precalculation,
    PlayerAction,
    ServerUpdate,
    WaitForAll,
    AICalculation,
    StartMovesExecution,
    MovesExecution,
    StartActionsExecution,
    ActionsExecution,
    PostExecution

    private var name: String {
        let names = [
            "Initialization",
            "Precalculation",
            "Player Action",
            "Server Update",
            "Wait for All",
            "AI Calculation",
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