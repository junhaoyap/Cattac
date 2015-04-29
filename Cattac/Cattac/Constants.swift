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
        
        // indicates the avg number of spawns per 10 turns
        // if spawns on tile with doodad/item, spawn is invalid
        static let itemSpawnProbability: Int = 8
        
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

    // time for each turn
    static let turnDuration = 5

    struct Images {
        static let fortress = "Fortress.png"
        static let tower = "Tower.png"
        static let trampoline = "Trampoline.png"
        static let wormholeBlue = "WormholeBlue.png"
        static let wormholeOrange = "WormholeOrange.png"
        static let milk = "Milk.png"
        static let nuke = "Nuke.png"
        static let projectile = "Projectile.png"
        static let wall = "Rock.png"
    }

    struct Entities {
        struct Title {
            static let fortress = "Fortress"
            static let tower = "Tower"
            static let trampoline = "Trampoline"
            static let wormholeBlue = "WormholeBlue"
            static let wormholeOrange = "WormholeOrange"
            static let milk = "Milk"
            static let nuke = "Nuke"
            static let projectile = "Projectile"
            static let wall = "Wall"
            static let eraser = "Eraser"
        }

        static func getImage(title: String) -> String? {
            switch title {
            case Title.fortress:
                return Images.fortress
            case Title.tower:
                return Images.tower
            case Title.trampoline:
                return Images.trampoline
            case Title.wormholeBlue:
                return Images.wormholeBlue
            case Title.wormholeOrange:
                return Images.wormholeOrange
            case Title.milk:
                return Images.milk
            case Title.nuke:
                return Images.nuke
            case Title.projectile:
                return Images.projectile
            case Title.wall:
                return Images.wall
            default:
                return nil
            }
        }

        static func getObject(title: String) -> TileEntity? {
            switch title {
            case Title.fortress:
                return FortressDoodad()
            case Title.tower:
                return WatchTowerDoodad()
            case Title.trampoline:
                return TrampolineDoodad()
            case Title.wormholeBlue, Title.wormholeOrange:
                return WormholeDoodad()
            case Title.milk:
                return MilkItem()
            case Title.nuke:
                return NukeItem()
            case Title.projectile:
                return ProjectileItem()
            case Title.wall:
                return Wall()
            default:
                return nil
            }
        }
    }
    
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
    static let catArray = [cat.grumpyCat, cat.nyanCat, cat.kittyCat, cat.octoCat]
    
    struct cat {
        static let grumpyCat = "Grumpy"
        static let nyanCat = "Nyan"
        static let kittyCat = "Hello Kitty"
        static let octoCat = "Octocat"

        static let attributes: [String:(hp: Int, defense: Int, puiDmg: Int,
        fartDmg: Int, poopDmg: Int, moveRange: Int, fartRange: Int)] = [
            grumpyCat: (400, 1, 55, 30, 15, 2, 2),
            nyanCat:   (500, 1, 50, 25, 15, 2, 2),
            kittyCat:  (600, 1, 45, 20, 15, 2, 2),
            octoCat:   (500, 1, 40, 30, 15, 2, 2)
        ]

        static let images = [
            grumpyCat: "Grumpy.png",
            nyanCat: "Nyan.png",
            kittyCat: "HelloKitty.png",
            octoCat: "Octocat.png"
        ]
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
        static let nodeSpawnedItems = "nodeSpawnedItems"
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
        
        static let keyItemRow = "itemRow"
        static let keyItemCol = "itemCol"
        static let keyItemName = "itemName"
        static let keyItemVictim = "itemVictim"
        
        // max wait time before dropping inactive player
        static let maxDelayBeforeDrop: NSTimeInterval = 8
    }
    
    struct AutoAccount {
        static let username = "b@b.com"
        static let password = "bbb"
        static let username1 = "superman@cartoon.com"
        static let password1 = "superman"
        static let username2 = "wonderwoman@cartoon.com"
        static let password2 = "wonderwoman"
        static let username3 = "batman@cartoon.com"
        static let password3 = "batman"
        static let username4 = "ironman@cartoon.com"
        static let password4 = "ironman"
    }
    
    struct Segues {
        static let loginToMenuSegueIdentifier = "loginSegue"
    }
    
    struct Z {
        static let background: CGFloat = -100
        
        // Tile/TileEntities/Doodads layer -10 - -1
        static let tile: CGFloat = -10
        static let backDoodad: CGFloat = -9
        static let items: CGFloat = -8
        
        static let poopPreview: CGFloat = 29
        // Cat layer 30 - 39
        static let cat: CGFloat = 30
        static let frontDoodad: CGFloat = 31
        static let catPreview: CGFloat = 30
        
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
        static let targetTouchOverlay: CGFloat = 75
        
        // Damage layer 90 - 99
        static let damage: CGFloat = 90
    }

    struct UI {
        struct bottomBoard {
            static let position = CGPoint(x: 54, y: 32)

            private static let width: CGFloat = 640
            private static let height: CGFloat = 140

            private static let firstSection: CGFloat = 200

            static let puiButtonPosition =
                CGPoint(x: firstSection / 2, y: height / 2)


            private static let secondSection: CGFloat = 200

            static let fartButtonPosition =
                CGPoint(x: firstSection + secondSection / 2, y: 3 * height / 4)
            static let poopButtonPosition =
            CGPoint(x: firstSection + secondSection / 2,  y: height / 4)

            private static let thirdSection: CGFloat = 240

            private static let inventoryPosition =
                CGPoint(x: firstSection + secondSection + thirdSection / 2,
                    y: height / 2)

            static let inventoryLabelPosition = CGPoint(x: inventoryPosition.x,
                y: inventoryPosition.y + 30)

            static let milkPosition = CGPoint(x: inventoryPosition.x - 60,
                y: inventoryPosition.y)
            static let projectilePosition = CGPoint(x: inventoryPosition.x,
                y: inventoryPosition.y)
            static let nukePosition = CGPoint(x: inventoryPosition.x + 60,
                y: inventoryPosition.y)
        }
    }
}