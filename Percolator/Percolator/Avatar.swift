//
//  Avatar.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Avatar {

    let largeUrl: String
    let mediumUrl: String
    let smallUrl: String

    // Server always return avatar
    init(avatarDict: [String : JSON]) {
        largeUrl    = avatarDict[BangumiKey.avatarLargeUrl]!.stringValue
        mediumUrl   = avatarDict[BangumiKey.avatarMediumUrl]!.stringValue
        smallUrl    = avatarDict[BangumiKey.avatarSmallUrl]!.stringValue
    }
    
    init(largeURL large: String, mediumURL medium: String, smallURL small: String) {
        largeUrl = large
        mediumUrl = medium
        smallUrl = small
    }
    
}
