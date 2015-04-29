import UIKit

struct AlertAction {
    let action: ((UIAlertAction!) -> ())?
    let text: String
    
    init (_ text: String, _ action: ((UIAlertAction!) -> ())?) {
        self.action = action
        self.text = text
    }
}