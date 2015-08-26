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
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        var outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return outputImage
    }
}