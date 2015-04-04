//
//  File.swift
//  Cattac
//
//  Created by Steven Khong on 27/3/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import SpriteKit

protocol TileEntity {
    func isVisible() -> Bool
    func getSprite() -> SKNode
}