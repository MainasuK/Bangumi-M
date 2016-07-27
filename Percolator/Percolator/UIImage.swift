//
//  UIImage.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-13.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func fromColor(_ color: UIColor, size: CGSize) -> UIImage {
        let imgSize = (size.equalTo(CGSize.zero)) ? CGSize(width: 500, height: 500) : size
        
        if #available(iOS 10.0, *) {
            let render = UIGraphicsImageRenderer(size: imgSize)
            return render.image { (context: UIGraphicsImageRendererContext) in
                context.cgContext.setFillColor(color.cgColor)
                context.fill(CGRect(origin: CGPoint.zero, size: imgSize))
            }
        } else {
            // Fallback on earlier versions
            UIGraphicsBeginImageContext(imgSize)
            let context = UIGraphicsGetCurrentContext()
            
            context!.setFillColor(color.cgColor)
            context!.fill(CGRect(origin: CGPoint.zero, size: imgSize))
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img!
        }
    }
    
}
