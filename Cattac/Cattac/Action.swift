//
//  BaseAction.swift
//  Cattac
//
//  Created by Wu Di on 5/4/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation

enum ActionType {
    case Pui, Fart, Poop
}

enum Direction: Int {
    case All, Top, Right, Bottom, Left
    private var name: String {
        let names = [
            "all directions",
            "top direction",
            "right direction",
            "bottom direction",
            "left direction"
        ]
        
        return names[rawValue - 1]
    }
}

extension Direction: Printable {
    var description: String {
        return name
    }
}

class Action {
    private var _actionType: ActionType!
    private var _direction: Direction!
    private var _range: Int!
    var targetNode: TileNode?
    
    init(actionType: ActionType) {
        _actionType = actionType
        _direction = Direction.All
        _range = -1
    }
    
    var actionType: ActionType {
        return _actionType
    }
    
    var direction: Direction {
        get {
            return _direction
        }
        set {
            _direction = newValue
        }
    }
    
    var range: Int {
        return _range
    }
}

class PuiAction: Action {
    init() {
        super.init(actionType: ActionType.Pui)
    }
    
    init(direction: Direction) {
        super.init(actionType: ActionType.Pui)
        self._direction = direction
    }
}

extension PuiAction: Printable {
    var description: String {
        return "Pui towards \(direction)"
    }
}

class FartAction: Action {
    init(range: Int) {
        super.init(actionType: ActionType.Fart)
        self._range = range
        self._direction = Direction.All
    }
}

extension FartAction: Printable {
    var description: String {
        return "Fart with range \(range)"
    }
}

class PoopAction: Action {
    init(targetNode: TileNode) {
        super.init(actionType: ActionType.Poop)
        self.targetNode = targetNode
    }
}

extension PoopAction: Printable {
    var description: String {
        return "Poop at \(targetNode)"
    }
}