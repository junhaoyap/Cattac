import UIKit

struct AlertAction {
    let action: ((UIAlertAction!) -> ())?
    let text: String
    
    init (_ action: ((UIAlertAction!) -> ())?, _ text: String) {
        self.action = action
        self.text = text
    }
}