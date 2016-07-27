//
//  UIDevice.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-1-12.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension UIDevice {
    
    var deviceType: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(UnicodeScalar(UInt8(value)))
            }
        }
        
        return identifier
    }
    
}
