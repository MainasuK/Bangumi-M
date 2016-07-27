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
func setSVProgressHUD(style: SVProgressHUDStyle) {
    
    switch style {
    case .custom:
        // Configure HUD
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setBackgroundColor(UIColor.white())
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
    
    default:
        SVProgressHUD.setDefaultStyle(style)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
    }
    
}
