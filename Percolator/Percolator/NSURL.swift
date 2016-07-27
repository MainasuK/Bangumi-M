//
//  NSURL.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension NSURL {
    
    static var documentsURL: NSURL {
        return try! FileManager.default.urlForDirectory(.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
}
