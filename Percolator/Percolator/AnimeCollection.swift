//
//  AnimeCollection.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct AnimeCollection {
    public var wish = 0
    public var collect = 0
    public var doing = 0
    public var onHold = 0
    public var dropped = 0
    
    init() {
    }
    
    init(animeCollectionDict: NSDictionary) {
        wish = animeCollectionDict[BangumiKey.wish] as! Int
        collect = animeCollectionDict[BangumiKey.collect] as! Int
        doing = animeCollectionDict[BangumiKey.doing] as! Int
        onHold = animeCollectionDict[BangumiKey.onHold] as! Int
        dropped = animeCollectionDict[BangumiKey.dropped] as! Int
    }
}