//
//  SKDirectionButtonNode.swift
//  Cattac
//
//  Created by Wu Di on 7/4/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation
import SpriteKit

class SKDirectionButtonNode: SKNode {
    private var defaultTexture: SKTexture!
    private var activeTexture: SKTexture!
    var top: SKSpriteNode!
    var right: SKSpriteNode!
    var bottom: SKSpriteNode!
    var left: SKSpriteNode!
    private var buttons: [Direction:SKSpriteNode] = [:]
    private var selectedButton: SKSpriteNode!
    var action: (Direction) -> Void
    
    init(defaultButtonImage: String, activeButtonImage: String, size: CGSize, centerSize: CGSize, hoverAction: (Direction) -> Void, availableDirection: [Direction], selected: Direction) {
        
        self.action = hoverAction
        
        super.init()
        
        self.defaultTexture = SKTexture(imageNamed: defaultButtonImage)
        self.activeTexture = SKTexture(imageNamed: activeButtonImage)
        
        for direction in availableDirection {
            var button: SKSpriteNode
            if direction == selected {
                button = SKSpriteNode(texture: self.activeTexture)
                selectedButton = button
            } else {
                button = SKSpriteNode(texture: self.defaultTexture)
            }
            button.size = size
            button.zRotation = SceneUtils.zRotation(direction)
            
            switch direction {
            case .Top:
                top = button
                button.position = CGPoint(
                    x: 0,
                    y: CGFloat((centerSize.height + size.height) / 2.0)
                )
            case .Right:
                right = button
                button.position = CGPoint(
                    x: CGFloat((centerSize.width + size.width) / 2.0),
                    y: 0
                )
            case .Bottom:
                bottom = button
                button.position = CGPoint(
                    x: 0,
                    y: -CGFloat((centerSize.height + size.height) / 2.0)
                )
            case .Left:
                left = button
                button.position = CGPoint(
                    x: -CGFloat((centerSize.width + size.width) / 2.0),
                    y: 0
                )
            default:
                break
            }
            
            buttons[direction] = button
            addChild(button)
        }
        
        userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.allObjects[0] as UITouch
        processTouchEvent(touch.locationInNode(self))
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.allObjects[0] as UITouch
        processTouchEvent(touch.locationInNode(self))
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.allObjects[0] as UITouch
        processTouchEvent(touch.locationInNode(self))
    }
    
    private func processTouchEvent(location: CGPoint) {
        for (direction, button) in buttons {
            if button.containsPoint(location) {
                action(direction)
                selectedButton.texture = defaultTexture
                button.texture = activeTexture
                selectedButton = button
                break
            }
        }
    }
}
