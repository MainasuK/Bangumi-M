//
//  UIImage.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-24.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func imageFromLayer(layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.mainScreen().scale)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return outputImage
    }
}