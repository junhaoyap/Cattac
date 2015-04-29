import UIKit

struct AlertBuilder {
    let title: String
    let message: String
    let defaultAction: AlertAction?
    let cancelAction: AlertAction?
    
    init(_ title: String, _ message: String) {
        self.title = title
        self.message = message
    }
    
    init(_ title: String, _ message: String, _ defaultAction: AlertAction) {
        self.title = title
        self.message = message
        self.defaultAction = defaultAction
    }
    
    init(_ title: String, _ message: String, _ defaultAction: AlertAction,
        _ cancelAction: AlertAction) {
            self.title = title
            self.message = message
            self.defaultAction = defaultAction
            self.cancelAction = cancelAction
    }
    
    var controller: UIAlertController {
        let alert = UIAlertController(title: title, message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        if defaultAction != nil {
            alert.addAction(UIAlertAction(title: defaultAction!.text,
                style: .Default, handler: defaultAction!.action))
        }
        if cancelAction != nil {
            alert.addAction(UIAlertAction(title: cancelAction!.text,
                style: .Cancel, handler: cancelAction!.action))
        }
        return alert
    }
}