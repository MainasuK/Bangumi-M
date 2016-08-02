//
//  NetworkSpinner.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

struct NetworkSpinner {
    
    static func on() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    static func off() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
