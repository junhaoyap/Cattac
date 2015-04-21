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
        static let defaultItems: Int = 2
        
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
        static let keyEntityType = "entityType"
        static let valueDoodadType = "doodad"
        static let valueItemType = "item"
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
    static let defaultNumberOfMeows = 100
    
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
    
    // for randomising which player get which cat, copy the array before playing with it, only for
    // initial reference
    static let catArray = [catName.nalaCat, catName.nyanCat, catName.grumpyCat, catName.pusheenCat]
    
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
        static let projectile = "projectile"
    }
    
    struct itemEffect {
        static let milkHpIncreaseEffect = 150
        static let nukeDmg = 100
        static let projectileDmg = 150
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
        static let nodePlayerDropped = "dropped"
        
        static let keyMeows = "numberOfMeows"
        
        static let keyTime = "lastActive"
        
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
        
        // max wait time before dropping inactive player
        static let maxDelayBeforeDrop = 10
    }
    
    struct AutoAccount {
        static let username = "b@b.com"
        static let password = "bbb"
    }
    
    struct Segues {
        static let loginToMenuSegueIdentifier = "loginSegue"
    }
    
    struct Z {
        static let background: CGFloat = -100
        
        // Tile/TileEntities/Doodads layer -10 - -1
        static let tile: CGFloat = -10
        static let doodad: CGFloat = -9
        static let items: CGFloat = -8
        static let catPreview: CGFloat = -7
        
        static let poopPreview: CGFloat = 29
        // Cat layer 30 - 39
        static let cat: CGFloat = 30
        
        // Action buttons layer 40 - 49
        static let actionButtons: CGFloat = 40
        // They have to be the same, iOS z-indexing for touch and drawing
        // is different, and apparently buggy. So to prevent wasting time 
        // doing a workaround for something someone else will eventually fix:
        static let itemActivated: CGFloat = actionButtons
        
        // Actions effect layer 70 - 49
        static let fart: CGFloat = 70
        static let pui: CGFloat = 71
        static let poop: CGFloat = 72
        static let targetArrow: CGFloat = 73
        static let targetCrosshair: CGFloat = 74
        
        // Damage layer 90 - 99
        static let damage: CGFloat = 90
    }
    
    struct UI {
        static let buttonSpacing: CGFloat = 220
    }
}