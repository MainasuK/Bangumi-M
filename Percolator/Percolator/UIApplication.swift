//
//  UIApplication.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-14.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension UIApplication {

    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}