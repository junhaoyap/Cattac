//
//  SKButtonNode.swift
//  Cattac
//
//  Created by Wu Di on 7/4/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation
import SpriteKit

class SKActionButtonNode: SKNode {
    private var defaultButton: SKSpriteNode!
    private var activeButton: SKSpriteNode!
    private var action: () -> Void
    private var unselectAction: () -> Void
    private var isSelected: Bool
    
    init(defaultButtonImage: String, activeButtonImage: String,
        buttonAction: () -> Void, unselectAction: () -> Void) {
        self.defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        self.activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        self.action = buttonAction
        self.unselectAction = unselectAction
        self.activeButton.hidden = true
        self.isSelected = false
        
        super.init()
        
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }

    func unselect() {
        activeButton.hidden = true
        defaultButton.hidden = false
        isSelected = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        activeButton.hidden = false ^ isSelected
        defaultButton.hidden = true ^ isSelected
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.allObjects[0] as UITouch
        var location = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            activeButton.hidden = false ^ isSelected
            defaultButton.hidden = true ^ isSelected
        } else {
            activeButton.hidden = true ^ isSelected
            defaultButton.hidden = false ^ isSelected
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.allObjects[0] as UITouch
        let location = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            if !isSelected {
                action()
                isSelected = true
            } else {
                unselectAction()
                unselect()
            }
        } else {
            activeButton.hidden = true ^ isSelected
            defaultButton.hidden = false ^ isSelected
        }
    }
}