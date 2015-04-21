/// AI for single player mode.
///
/// Generates movement and actions for bots.
class GameAI {

    private var grid: Grid
    private var gameManager: GameManager
    private var currentPlayer: Cat

    /// Intializes the game AI.
    ///
    /// :param: grid The game level grid.
    /// :param: gameManager The game manager of the game engine.
    /// :param: currentPlayer The Cat object of the current player.
    init(grid: Grid, gameManager: GameManager, currentPlayer: Cat) {
        self.grid = grid
        self.gameManager = gameManager
        self.currentPlayer = currentPlayer
    }

    /// Calculates the movement and action for the bots based on their current
    /// positions.
    func calculateTurn() {
        for (playerName, player) in gameManager.aiPlayers {
            let reachableNodes = grid.getNodesInRange(
                gameManager[positionOf: player]!,
                range: player.moveRange
            )

            let index = Int(arc4random_uniform(UInt32(reachableNodes.count)))
            let moveToNode = Array(reachableNodes.values)[index]
            gameManager[moveToPositionOf: player] = moveToNode
        }
    }
}
