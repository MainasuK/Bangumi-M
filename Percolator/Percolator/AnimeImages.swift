//
//  AnimeImages.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct AnimeImages {
    public var largeUrl = ""
    public var commonUrl = ""
    public var mediumUrl = ""
    public var smallUrl = ""
    public var gridUrl = ""
    
    init() {
    }
    
    init(animeImagesDict: NSDictionary) {
        largeUrl = animeImagesDict[BangumiKey.largeUrl] as! String
        commonUrl = animeImagesDict[BangumiKey.commonUrl] as! String
        mediumUrl = animeImagesDict[BangumiKey.mediumUrl] as! String
        smallUrl = animeImagesDict[BangumiKey.smallUrl] as! String
        gridUrl = animeImagesDict[BangumiKey.gridUrl] as! String
    }
}