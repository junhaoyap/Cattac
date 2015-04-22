//
//  SKButtonNode.swift
//  Cattac
//
//  Created by Wu Di on 7/4/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation
import SpriteKit

protocol ActionButton {
    func unselect()
}

class SKActionButtonNode: SKNode, ActionButton {
    private var defaultButton: SKSpriteNode!
    private var activeButton: SKSpriteNode!
    private var action: () -> Void
    private var unselectAction: () -> Void
    var isEnabled = false
    var isSelected: Bool
    
    init(actionText: String, size: CGSize, buttonAction: () -> Void,
        unselectAction: () -> Void) {
            self.defaultButton = SKSpriteNode()
            self.defaultButton.size = size
            self.activeButton = SKSpriteNode(imageNamed: "ButtonSelect.png")
            self.activeButton.size = self.defaultButton.size
            self.defaultButton.zPosition = Constants.Z.actionButtons
            self.activeButton.zPosition = Constants.Z.actionButtons
            self.action = buttonAction
            self.unselectAction = unselectAction
            self.activeButton.hidden = true
            self.isSelected = false
            
            super.init()
            
            userInteractionEnabled = true
            addChild(defaultButton)
            addChild(activeButton)

            let actionText = SKLabelNode(text: actionText)
            actionText.fontColor = UIColor.blackColor()
            actionText.fontName = "LuckiestGuy-Regular"
            actionText.verticalAlignmentMode = .Center
            defaultButton.addChild(actionText)
    }

    private init(defaultButtonImage: String, size: CGSize, buttonAction: () -> Void,
        unselectAction: () -> Void) {
            self.defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
            self.defaultButton.size = size
            self.activeButton = SKSpriteNode(imageNamed: "ButtonSelect.png")
            self.activeButton.size = self.defaultButton.size
            self.defaultButton.zPosition = Constants.Z.actionButtons
            self.activeButton.zPosition = Constants.Z.actionButtons
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
        isSelected = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if !isEnabled {
            return
        }

        activeButton.hidden = false ^ isSelected
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if !isEnabled {
            return
        }

        var touch = touches.allObjects[0] as UITouch
        var location = touch.locationInNode(self)

        if defaultButton.containsPoint(location) {
            activeButton.hidden = false ^ isSelected
        } else {
            activeButton.hidden = true ^ isSelected
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !isEnabled {
            return
        }

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
        }
    }
}


class SKInventoryItemNode: SKActionButtonNode {
    private var itemCount: Int
    private var itemCountLabel: SKLabelNode

    override init(defaultButtonImage: String, size: CGSize, buttonAction: () -> Void,
        unselectAction: () -> Void) {
            itemCount = 0
            itemCountLabel = SKLabelNode(text: "x\(itemCount)")
            itemCountLabel.fontName = "BubblegumSans-Regular"
            itemCountLabel.fontColor = UIColor.blackColor()
            itemCountLabel.fontSize = 12
            itemCountLabel.verticalAlignmentMode = .Bottom
            itemCountLabel.horizontalAlignmentMode = .Left
            itemCountLabel.position = CGPoint(x: 20, y: -20)

            super.init(
                defaultButtonImage: defaultButtonImage,
                size: size, buttonAction:
                buttonAction,
                unselectAction: unselectAction
            )

            addChild(itemCountLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func decrease() {
        itemCount--
        itemCountLabel.text = "x\(itemCount)"
    }

    func increase() {
        itemCount++
        itemCountLabel.text = "x\(itemCount)"
    }
}