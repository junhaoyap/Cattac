//
//  TileNode.swift
//  Cattac
//
//  Created by Steven Khong on 27/3/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation

import SpriteKit

enum NodeType: Int, Printable {
    case Unknown = 0, Grass
    var spriteName: String {
        let spriteNames = [
            "Grass.jpg"
        ]
        
        return spriteNames[rawValue - 1]
    }
    
    var description: String {
        return spriteName
    }
}

class TileNode: Printable {
    var column: Int
    var row: Int
    let nodeType: NodeType
    var sprite: SKSpriteNode?
    
    var occupants = [TileEntity]()
    
    init(column: Int, row: Int, nodeType: NodeType) {
        self.column = column
        self.row = row
        self.nodeType = nodeType
    }
    
    var description: String {
        return "type:\(nodeType) square:(\(column),\(row))"
    }
}