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
            
            // moveto position of player has to be set for action generation.
            gameEngine.gameManager[moveToPositionOf: player] = moveToNode
            
            var action: Action?
            // if has item, use item
            let inventory = gameEngine.gameManager[inventoryOf: player]!
            if let itemType = inventory.firstItem {
                let item = inventory.getItem(itemType)
                action = aiUseItem(item, onPlayer: player)
            } else {
                action = getRandomAction(player)
            }
            
            gameEngine.triggerAIPlayerMove(player,
                dest: moveToNode, action: action)
        }
    }
    
    private func getRandomAction(player: Cat) -> Action? {
        let actionNum = Int(arc4random_uniform(UInt32(3)))
        switch actionNum {
        case 0:
            let directions = gameEngine.getAvailablePuiDirections(player)
            if directions.isEmpty {
                return nil
            }
            let dirNum = Int(arc4random_uniform(UInt32(directions.count)))
            return PuiAction(direction: directions[dirNum])
        case 1:
            return FartAction(range: player.fartRange)
        case 2:
            let node = gameEngine.gameManager[positionOf: player]!
            return PoopAction(targetNode: node)
        default:
            return nil
        }
        
    }
    
    private func aiUseItem(item: Item, onPlayer player: Cat) -> ItemAction {
        if item.canTargetOthers() && !item.shouldTargetAll() {
            let targetPlayerNum = Int(arc4random_uniform(UInt32(4))) + 1
            let target = gameEngine.gameManager[playerWithNum: targetPlayerNum]!
            let node = gameEngine.gameManager[moveToPositionOf: player]!
            return ItemAction(item: item,
                targetNode: node, targetPlayer: target)
        } else {
            let node = gameEngine.gameManager[moveToPositionOf: player]!
            return ItemAction(item: item,
                targetNode: node, targetPlayer: player)
        }
    }
}
