/*
    Where we keep all the constants
*/

import UIKit
import Foundation

struct Constants {
    struct Level {
        static let basicRows: Int = 10
        static let basicColumns: Int = 10
        static let mediumRows: Int = 13
        static let mediumColumns: Int = 13
        static let hardRows: Int = 8
        static let hardColumns: Int = 8
        static let defaultDoodads: Int = 8
        static let defaultWalls: Int = 10
        
        static let invalidDoodadWallLocation: [GridIndex] = [
            GridIndex(0, 0),
            GridIndex(0, 9),
            GridIndex(9, 0),
            GridIndex(9, 9)
        ]
        // magic numbers for now
        
        static let keyRows = "rows"
        static let keyCols = "cols"
        static let keyType = "type"
        
        static let valueTypeBasic = "basic"
        static let valueTypeMedium = "medium"
        static let valueTypeHard = "hard"
        
        static let keyEntities = "entities"
        static let keyGridRow = "row"
        static let keyGridCol = "col"
        static let keyEntityName = "name"
        static let keyWormholeDestNode = "destNode"
        
        static let keyPlayers = "players"
        static let keyPlayer1 = "player1"
        static let keyPlayer2 = "player2"
        static let keyPlayer3 = "player3"
        static let keyPlayer4 = "player4"
    }
    
    // default number of meows, standalone for now
    static let defaultNumberOfMeows = "100"
    
    struct Doodad {
        static let watchTowerActionRangeModification = 2
        static let fortressDefenceModification = 2
        static let trampolineMoveRangeModification = 1
        static let landMineDamage = 10
        
        static let wallString = "wall"
        static let landMineString = "landMine"
        static let fortressString = "fortress"
        static let trampolineString = "trampoline"
        static let watchTowerString = "watchTower"
        static let wormholeString = "wormhole"
        
        static let maxWormhole = 1
    }

    
    struct catAttributes {
        // always hp, defence, puiDmg then fartDmg
        
        static let nyanCatAttributes = [500, 1, 50, 25]
        // nyan cat is the most balanced cat
        
        static let nalaCatAttributes = [600, 1, 45, 20]
        // nala cat is thicker, but does less dmg
        
        static let grumpyCatAttributes = [400, 1, 55, 30]
        // grumpy cat is thinner, but does more dmg
        
        static let pusheenCatAttributes = [500, 1, 40, 30]
        // pusheen cat pui for less dmg, but does more fartdmg, otherwise balanced
        
        static let poopDmg = 15
        static let moveRange = 2
        static let fartRange = 2
    }
    
    struct catName {
        static let nyanCat = "nyanCat"
        static let nalaCat = "nalaCat"
        static let grumpyCat = "grumpyCat"
        static let pusheenCat = "pusheenCat"
    }
    
    struct itemName {
        static let milk = "milk"
        static let nuke = "nuke"
        static let rock = "rock"
    }
    
    struct itemEffect {
        static let milkHpIncreaseEffect = 150
        static let nukeDmg = 100
        static let rockDmg = 150
    }
    
    struct Firebase {
        static let baseUrl = "https://torrid-inferno-1934.firebaseio.com/"
        
        static let nodeMeows = "usersMeow"
        
        static let nodeGames = "games"
        static let nodeUsers = "users"
        
        static let nodeGame = "game"
        static let nodeGameLevel = "gameLevel"
        static let nodeLobby = "lobby"
        static let nodePlayers = "players"
        static let nodePlayerMovements = "movements"
        
        static let keyMeows = "numberOfMeows"
        
        static let keyAttkDir = "attackDir"
        static let keyAttkDmg = "attackDmg"
        static let keyAttkRange = "attackRange"
        static let keyAttkType = "attackType"
        static let keyMoveFromRow = "fromRow"
        static let keyMoveFromCol = "fromCol"
        static let keyMoveToRow = "toRow"
        static let keyMoveToCol = "toCol"
        static let keyTargetRow = "targetNodeRow"
        static let keyTargetCol = "targetNodeCol"
    }
    
    struct AutoAccount {
        static let username = "b@b.com"
        static let password = "bbb"
    }
    
    struct Segues {
        static let loginToMenuSegueIdentifier = "loginSegue"
    }
}