//
//  UINavigationBar.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-23.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    class func addMyButtonBackgroundView() {
        let backgroundImage = UIImage(named: "naviBarbackground")!
        self.appearance().setBackgroundImage(backgroundImage, forBarMetrics: UIBarMetrics.Default)
    }
    
    class func removeMyButtonBackgroundView() {
        self.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
    }
}