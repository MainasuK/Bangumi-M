//
//  Avatar.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct Avatar {
    public var largeUrl = ""
    public var mediumUrl = ""
    public var smallUrl = ""
    
    init() {
    }
    
    init(avatarDict: NSDictionary) {
        largeUrl    = avatarDict[BangumiKey.avatarLargeUrl]     as! String
        mediumUrl   = avatarDict[BangumiKey.avatarMediumUrl]    as! String
        smallUrl    = avatarDict[BangumiKey.avatarSmallUrl]     as! String
    }
}
