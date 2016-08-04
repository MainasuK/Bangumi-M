//
//  UIAlertController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func simpleErrorAlert(with title: String, description: String, code: Int = 0) -> UIAlertController {
        let cancelButtonTitle = NSLocalizedString("dismiss", comment: "")
        let codeString = (code != 0) ? "\(code)" : ""
        let message: String? = ("" == codeString && "" == description) ? nil : "\(codeString) \(description)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            consolePrint("The simple alert's cancel action occured.")
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}
