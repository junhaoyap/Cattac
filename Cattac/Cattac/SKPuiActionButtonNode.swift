import Foundation
import SpriteKit

/// Button for Pui Action, extension of Action Button.
///
/// Adds functionality to register swiping from the button to register the pui
/// direction.
class SKPuiActionButtonNode: SKActionButtonNode {
    /// Called to set the puiAction in the provided direction
    private var buttonAction: (Direction) -> Void

    /// Called to clear the puiAction
    private var unselectAction: () -> ()

    /// Called to retrieve all the available directions for the cat
    private var getAvailableDirections: () -> [Direction]

    /// The direction arrows
    private var directionNode: SKDirectionButtonNode?

    /// The point where the user begins touching the button
    private var initialTouchLocation: CGPoint?

    /// The minimum distance before registering a direction
    private let minimumTriggerDistance: CGFloat = 20

    /// Hijacks the buttonAction and unselectAction from the superclass as
    /// we will be calling them under different conditions.
    init(actionText: String, size: CGSize, buttonAction: (Direction) -> Void,
        unselectAction: () -> Void, getAvailableDirections: () -> [Direction]) {
            self.getAvailableDirections = getAvailableDirections
            self.buttonAction = buttonAction
            self.unselectAction = unselectAction

            super.init(
                actionText: actionText,
                size: size,
                buttonAction: {},
                unselectAction: {}
            )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Resets the direction arrow on PuiActionButton, highlights the provided
    /// direction, if any.
    ///
    /// - parameter selected: Direction to select, nil if unselect all.
    func resetDirectionNode(selected: Direction?) {
        directionNode?.removeFromParent()
        directionNode = SKDirectionButtonNode(
            defaultButtonImage: "DirectionArrow.png",
            activeButtonImage: "DirectionArrowSelected.png",
            size: CGSize(width: 30, height: 30),
            centerSize: self.calculateAccumulatedFrame().size,
            availableDirection: getAvailableDirections())
        if selected != nil {
            directionNode?.selectDirection(selected!)
        }
        self.addChild(directionNode!)
    }

    /// Removes the directional arrows in addition to unselecting the button
    override func unselect() {
        super.unselect()
        if directionNode != nil {
            directionNode!.removeFromParent()
            directionNode = nil
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isEnabled {
            return
        }

        super.touchesBegan(touches, withEvent: event)

        /// Register the inital touch point to calculate swipe direction later
        let touch = touches.first!
        initialTouchLocation = touch.locationInNode(self)

        /// Resets the direction on touch begin or create the direction arrows
        /// if they do not exist
        if directionNode == nil {
            resetDirectionNode(nil)
        } else {
            directionNode!.unselectDirection()
            unselectAction()
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /// directionNode will be cleared when the gameState changes, so we
        /// need to disable all touchesMoved operations
        if !isEnabled || directionNode == nil {
            return
        }

        let touch = touches.first!
        let location = touch.locationInNode(self)

        /// If the minimumTriggerDistance is met, selects the arrow in that 
        /// direction and trigger the buttonAction, else trigger the clearing 
        /// of the puiAction
        if distanceBetween(fromPoint: initialTouchLocation!,
            toPoint: location) > minimumTriggerDistance {
                let degree = CGPointToDegree(fromPoint: initialTouchLocation!,
                    toPoint: location)

                switch degree {
                case -180...(-135):
                    directionNode!.selectDirection(.Right)
                case -135...(-45):
                    directionNode!.selectDirection(.Top)
                case -45..<45:
                    directionNode!.selectDirection(.Left)
                case 45..<135:
                    directionNode!.selectDirection(.Bottom)
                case 135...180:
                    directionNode!.selectDirection(.Right)
                default:
                    break
                }
                
                if directionNode!.selectedDirection != nil {
                    buttonAction(directionNode!.selectedDirection!)
                }
        } else {
            directionNode!.unselectDirection()
            unselectAction()
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /// directionNode will be cleared when the gameState changes, so we
        /// need to disable touchesEnded operation
        if !isEnabled || directionNode == nil {
            return
        }

        /// Calls buttonAction to trigger the puiAction if a direction is set,
        /// else unselects the button and clear the direction arrows.
        if let direction = directionNode!.selectedDirection {
            buttonAction(direction)
        } else {
            unselect()
            unselectAction()
        }
    }

    private func distanceBetween(fromPoint  fromPoint: CGPoint, toPoint: CGPoint)
        -> CGFloat {
            return hypot(fromPoint.x - toPoint.x, fromPoint.y - toPoint.y)
    }

    private func CGPointToDegree(fromPoint  fromPoint: CGPoint, toPoint: CGPoint)
        -> CGFloat {
            let x = fromPoint.x - toPoint.x
            let y = fromPoint.y - toPoint.y
            let bearingRadians = atan2(y, x);
            let bearingDegrees = bearingRadians * (180 / CGFloat(M_PI));
            return bearingDegrees;
    }
}
