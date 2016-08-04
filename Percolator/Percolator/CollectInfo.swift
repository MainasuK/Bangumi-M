//
//  CollectInfo.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CollectInfo {
    // Status
    let id: Int
    let type: StatusType
    let name: String
    
    let rating: Int
    let comment: String
    let tags: [String]
    
    let epStatus: Int
    let lastTouch: Int
    
    init(from json: JSON) {
        id = json[BangumiKey.status][BangumiKey.id].int!
        type = StatusType(rawValue: json[BangumiKey.status][BangumiKey.type].stringValue)!
        name = json[BangumiKey.status][BangumiKey.name].stringValue
        
        rating = json["rating"].intValue
        comment = json["comment"].stringValue
        tags = json["tag"].arrayObject as? [String] ?? [String]()
        
        epStatus = json[BangumiKey.epStatus].intValue
        lastTouch = json[BangumiKey.lastTouch].intValue
    }
    
    enum StatusType: String {
        case doing = "do"
        case hold = "on_hold"
        case dropped = "dropped"
        case wish = "wish"
        case collect = "collect"
    }
}

struct CollectInfoSmall {
    let id: Int
    let type: String
    let name: String
    
    init(from json: JSON) {
        id = json[BangumiKey.id].intValue
        type = json[BangumiKey.type].stringValue
        name = json[BangumiKey.name].stringValue
    }
}
