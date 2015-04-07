//
//  BaseAction.swift
//  Cattac
//
//  Created by Wu Di on 5/4/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation

enum ActionType: Int {
    case Pui = 0, Fart, Poop
    
    private var name: String {
        let names = [
            "pui",
            "fart",
            "poop"
        ]
        
        return names[rawValue]
    }
}

extension ActionType: Printable {
    var description: String {
        return name
    }
    
    static func create(name: String) -> ActionType? {
        let types = [
            "pui": ActionType.Pui,
            "fart": ActionType.Fart,
            "poop": ActionType.Poop
        ]
        
        return types[name]
    }
}

class Action: Equatable {
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

func ==(lhs: Action, rhs: Action) -> Bool {
    return lhs.actionType == rhs.actionType
        && lhs.direction == rhs.direction
        && lhs.range == rhs.range
        && lhs.targetNode == rhs.targetNode
}

class PuiAction: Action {
    var availableDirections: [Direction]!
    
    init(direction: Direction) {
        super.init(actionType: ActionType.Pui)
        self._direction = direction
        self.availableDirections = []
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