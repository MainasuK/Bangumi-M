//
//  SVProgress+Style.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-18.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SVProgressHUD

/// Don't forget set it back when controller dismiss
func setSVProgressHUD(style: CMKProgressHUDStyle) {
    
    switch style {
    case .customLogin:
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.gradient)
    
    case .dark:
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.none)
    }
    
}

enum CMKProgressHUDStyle {
    case customLogin
    case dark
}
