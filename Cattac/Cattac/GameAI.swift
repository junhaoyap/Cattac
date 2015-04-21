/// AI for single player mode.
///
/// Generates movement and actions for bots.
class GameAI {

    private var grid: Grid
    private var gameEngine: GameEngine
    private var currentPlayer: Cat

    /// Intializes the game AI.
    ///
    /// :param: grid The game level grid.
    /// :param: gameManager The game engine.
    /// :param: currentPlayer The Cat object of the current player.
    init(grid: Grid, gameEngine: GameEngine, currentPlayer: Cat) {
        self.grid = grid
        self.gameEngine = gameEngine
        self.currentPlayer = currentPlayer
    }

    /// Calculates the movement and action for the bots based on their current
    /// positions.
    func calculateTurn() {
        for (playerName, player) in gameEngine.gameManager.aiPlayers {
            let reachableNodes = grid.getNodesInRange(
                gameEngine.gameManager[positionOf: player]!,
                range: player.moveRange
            )

            let index = Int(arc4random_uniform(UInt32(reachableNodes.count)))
            let moveToNode = Array(reachableNodes.values)[index]
            gameEngine.triggerAIPlayerMove(player,
                dest: moveToNode, action: nil)
        }
    }
}
