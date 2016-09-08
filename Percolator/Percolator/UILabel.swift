//
//  UILabel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-18.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//
//  Ref: http://mesu.apple.com/assets/com_apple_MobileAsset_Font/com_apple_MobileAsset_Font.xml
//  https://developer.apple.com/library/ios/samplecode/DownloadFont/Introduction/Intro.html#//apple_ref/doc/uid/DTS40013404-Intro-DontLinkElementID_2

import UIKit

extension UILabel {
    
    func asyncSetFont(with fontName: String, placeholderFontName: String, size: CGFloat, toLanguage language: [String]) {
        
        guard let detectLanguage = self.text?.detectLanguage(), language.contains(detectLanguage) else {
            font = UIFont(name: placeholderFontName, size: size)
            return
        }
        
        asyncSetFont(with: fontName, placeholderFontName: placeholderFontName, size: size)
    }
    
    func isFontExist(fontName: String) -> Bool {
        guard let font = UIFont(name: fontName, size: 17.0),
        font.fontName.compare(fontName) == .orderedSame ||
        font.familyName.compare(fontName) == .orderedSame else {
            return false
        }
        
        return true
    }
    
    // Assert call on weak self
    func asyncSetFont(with fontName: String, placeholderFontName: String, size: CGFloat) {
        let networkStatus = BangumiRequest.shared.networkStatus
        
        if !isFontExist(fontName: fontName) {
            self.font = UIFont(name: placeholderFontName, size: size)
            
            // Demand fetch font when Wi-Fi connection
            if networkStatus != ReachableViaWiFi { return }
            
            // Create a new font descriptor
            // Fallback to 'Helvetica' when font is not downloadable
            
            let descs = [CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute as NSString : fontName] as CFDictionary)] as CFArray
            
            var isFailWithError = false
            
            // Async
            CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descs, nil) {
                (state :CTFontDescriptorMatchingState, dict: CFDictionary) -> Bool in
                
                switch state {
                case .didBegin: // called once at the beginning.
                    //consolePrint("Begin match font…")
                    break
                case .didFinish: // called once at the end.
                    //consolePrint("Finish match font")
                    guard let font = UIFont(name: fontName, size: size) else {
                        return isFailWithError
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.font = font
                    }
                    break
                    
                case .willBeginQuerying: // called once before talking to the server.  Skipped if not necessary.
                    //consolePrint("Will begin querying…")
                    break
                case .stalled: // called when stalled. (e.g. while waiting for server response.)
                    //consolePrint("Waiting for server…")
                    break
                // Downloading and activating are repeated for each descriptor.
                case .willBeginDownloading: // Downloading part may be skipped if all the assets are already downloaded
                    //consolePrint("Will begin downloading…")
                    break
                case .downloading:
                    //consolePrint("Downloading")
                    break
                case .didFinishDownloading:
                    //consolePrint("Did finish downloading")
                    break
                case .didMatch: // called when font descriptor is matched.
                    //consolePrint("Mathed font")
                    break
                    
                case .didFailWithError: // called when an error occurred.  (may be called multiple times.)
                    if let error = (dict as NSDictionary).value(forKey: String(kCTFontDescriptorMatchingError)) as? NSError {
                        consolePrint("Fial with error: \(error.description)")
                    } else {
                        consolePrint("Fail with no error info")
                    }
                    
                    isFailWithError = true
                }
                
                return true
            }
            
        } else {
            font = UIFont(name: fontName, size: size)
        }
    }

    private func printFontDebugLog() {
        consolePrint("Set font \(fontName) for \(text ?? "")")
    }

}
