//
//  AnimeEp.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct AnimeEp {
    public var id = 0
    public var url = ""
    public var type = 0
    public var sort = 0
    public var name = ""
    public var nameCN = ""
    public var duration = ""
    public var airDate = ""
    public var comment = 0
    public var describe = ""
    public var status = ""
    
    init() {
    }
    
    init(epDict: NSDictionary) {
        id = epDict[BangumiKey.id] as! Int
        url = epDict[BangumiKey.url] as! String
        type = epDict[BangumiKey.type] as! Int
        sort = epDict[BangumiKey.sort] as! Int
        name = epDict[BangumiKey.name] as! String
        nameCN = epDict[BangumiKey.nameCN] as! String
        duration = epDict[BangumiKey.duration] as! String
        airDate = epDict[BangumiKey.epAirDate] as! String
        comment = epDict[BangumiKey.comment] as! Int
        describe = epDict[BangumiKey.describe] as! String
        status = epDict[BangumiKey.status] as! String
    }
}