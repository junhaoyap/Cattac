//
//  SKButtonNode.swift
//  Cattac
//
//  Created by Wu Di on 7/4/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation
import SpriteKit

class SKActionButtonnNode: SKNode {
    var defaultButton: SKSpriteNode!
    var activeButton: SKSpriteNode!
    var action: () -> Void
    
    init(defaultButtonImage: String, activeButtonImage: String, buttonAction: () -> Void) {
        self.defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        self.activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        self.action = buttonAction
        self.activeButton.hidden = true
        
        super.init()
        
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        activeButton.hidden = false
        defaultButton.hidden = true
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.allObjects[0] as UITouch
        var location = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            activeButton.hidden = false
            defaultButton.hidden = true
        } else {
            activeButton.hidden = true
            defaultButton.hidden = false
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.allObjects[0] as UITouch
        let location = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            action()
        }
        
        activeButton.hidden = true
        defaultButton.hidden = false
    }
}