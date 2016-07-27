//
//  UIFont.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-18.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//
// Ref: https://github.com/hoppenichu/FontDownloader/blob/master/FontDownloader/FontDownloader.swift

import UIKit

extension UIFont {
    
    public class func downloadableFontNames() -> [String] {
        let downloadableDescriptor = CTFontDescriptorCreateWithAttributes([(kCTFontDownloadableAttribute as NSString): kCFBooleanTrue])
        
        guard let cfMatchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil),
        let matchedDescriptors = (cfMatchedDescriptors as NSArray) as? [CTFontDescriptor] else {
            return []
        }
        return matchedDescriptors.flatMap { (descriptor) -> String? in
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary
            return attributes[kCTFontNameAttribute as String] as? String
        }
    }
    
}
