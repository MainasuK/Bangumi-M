//
//  Color.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-7-25.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit

extension UIColor {
    
    @available(*, deprecated, message: "Use percolatorPink instead")
    class func myPinkColor() -> UIColor {
        return UIColor(red: 237.0/255.0, green: 150.0/255.0, blue: 159.0/255.0, alpha: 0.5)
    }
    
    class func percolatorPink() -> UIColor {
        return UIColor(red: 237.0/255.0, green: 150.0/255.0, blue: 159.0/255.0, alpha: 0.5)
    }
    
    class func myGreenColor() -> UIColor {
        return UIColor(red: 84.0/255.0, green: 195.0/255.0, blue: 91.0/255.0, alpha: 0.75)
    }
    
    class func myRedColor() -> UIColor {
        return UIColor(red: 227.0/255.0, green: 63.0/255.0, blue: 64.0/255.0, alpha: 0.5)
    }
    
    class func myPurpleColor() -> UIColor {
        return UIColor(red: 130.0/255.0, green: 50.0/255.0, blue: 226.0/255.0, alpha: 0.5)
    }
    
    class func myPurePinkColor() -> UIColor {
        return UIColor(red: 237.0/255.0, green: 150.0/255.0, blue: 159.0/255.0, alpha: 1)
    }
    
    @available(*, deprecated, message: "Use navigationBarBlue instead")
    class func myGrayColor() -> UIColor {
        return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }
    
    class func percolatorGray() -> UIColor {
        return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }
    
    class func percolatorLightGray() -> UIColor {
        return UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.00)
    }
    
    @available(*, deprecated, message: "Use navigationBarBlue instead")
    class func myNavigationBarColor() -> UIColor {
        return UIColor(red: 57.0/255.0, green: 156.0/255.0, blue: 254.0/255.0, alpha: 1.0)
    }

    class func navigationBarBlue() -> UIColor {
        return UIColor(red: 57.0/255.0, green: 156.0/255.0, blue: 254.0/255.0, alpha: 1.0)
    }
    
    class func myProgressBarColor() -> UIColor {
        return UIColor.navigationBarLooksLike()
    }
    
    @available(*, deprecated, message: "Use navigationBarLooksLike instead")
    class func myNavigatinBarLooksLikeColor() -> UIColor {
        return UIColor(red: 84.0/255.0, green: 168.0/255.0, blue: 252.0/255.0, alpha: 1.0)
    }
    
    class func myQueue() -> UIColor {
//        return UIColor(red: 253.0/255.0, green: 204.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        return UIColor.myPurePinkColor()
    }
    
    class func myDrop() -> UIColor {
        return UIColor.darkGray()
    }
    
    class func myWatched() -> UIColor {
        return UIColor(hue: 0.58, saturation: 0.86, brightness: 0.78, alpha: 1.0)
    }
    
    class func myAnimeListBackground() -> UIColor {
        return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }
    
    class func collectButtonTint() -> UIColor {
        return UIButton().tintColor
    }
    
    class func placeholder() -> UIColor {
        return .groupTableViewBackground()
    }
    
    class func navigationBarLooksLike() -> UIColor {
        return UIColor(red: 84.0/255.0, green: 168.0/255.0, blue: 252.0/255.0, alpha: 1.0)
    }
    
//    class func myNaviBackgroundColor() -> UIColor {
//        return UIColor.myNaviBackgroundColor().colorWithAlphaComponent(0.25)
//    }
}

