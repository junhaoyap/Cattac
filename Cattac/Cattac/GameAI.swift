class GameAI {

    private var grid: Grid
    private var gameManager: GameManager
    private var currentPlayer: Cat

    init(grid: Grid, gameManager: GameManager, currentPlayer: Cat) {
        self.grid = grid
        self.gameManager = gameManager
        self.currentPlayer = currentPlayer
    }

    func calculateTurn() {
        for (playerName, player) in gameManager.players {
            if playerName == currentPlayer.name {
                continue
            }

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
