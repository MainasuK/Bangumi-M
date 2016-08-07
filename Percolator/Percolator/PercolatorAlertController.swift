//
//  PercolatorAlertController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-8-7.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class PercolatorAlertController {
    
    class func notConnectedToInternet(withDescription description: String = "") -> UIAlertController {
        return UIAlertController.simpleErrorAlert(with: NSLocalizedString("not connected to internet", comment: ""), description: description)
    }
    
    class func timeout(withDescription description: String = "") -> UIAlertController {
        return UIAlertController.simpleErrorAlert(with: NSLocalizedString("time out", comment: ""), description: description)
    }
    
    class func dnsLookupFailed() -> UIAlertController {
        return UIAlertController.simpleErrorAlert(with: NSLocalizedString("time out", comment: ""))
    }
    
    class func unknown(_ error: NSError) -> UIAlertController {
        return UIAlertController.simpleErrorAlert(with: NSLocalizedString("unknown error", comment: ""), description: error.localizedDescription, code: error.code)
    }
    
    class func unknown(_ error: URLError) -> UIAlertController {
        return UIAlertController.simpleErrorAlert(with: NSLocalizedString("unknown error", comment: ""), description: error.localizedDescription, code: error.code.rawValue)
    }
    
    class func unknown(_ error: Error) -> UIAlertController {
        return UIAlertController.simpleErrorAlert(with: NSLocalizedString("unknown error", comment: ""), description: error.localizedDescription)
    }
    
}
