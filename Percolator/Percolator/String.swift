//
//  String.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-18.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension String {
    
    func detectLanguage() -> String {
        let range = CFRangeMake(0, min(self.characters.count, 100))
        guard let language = CFStringTokenizerCopyBestStringLanguage(self as CFString, range) else {
            return ""
        }
        
        return language as NSString as String
    }
    
}
