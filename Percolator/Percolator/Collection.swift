//
//  Collection.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-12.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Collection {
    let wish: Int
    let collect: Int
    let doing: Int
    let onHold: Int
    let dropped: Int
    
    init(json: [String : JSON]) {
        wish = json[BangumiKey.wish]?.intValue ?? 0
        collect = json[BangumiKey.collect]?.intValue ?? 0
        doing = json[BangumiKey.doing]?.intValue ?? 0
        onHold = json[BangumiKey.onHold]?.intValue ?? 0
        dropped = json[BangumiKey.dropped]?.intValue ?? 0
    }
    
    init(from cdCollection: CDCollection?) {
        wish = Int(cdCollection?.wish ?? 0)
        collect = Int(cdCollection?.collect ?? 0)
        doing = Int(cdCollection?.doing ?? 0)
        onHold = Int(cdCollection?.onHold ?? 0)
        dropped = Int(cdCollection?.dropped ?? 0)
    }
}
