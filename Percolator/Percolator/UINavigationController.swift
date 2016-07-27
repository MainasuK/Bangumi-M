//
//  UINavigationController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-11.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

extension UINavigationController{

    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.topViewController
    }
    
    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return self.topViewController
    }

}
