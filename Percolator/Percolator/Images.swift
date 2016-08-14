//
//  Images.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-12.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Images {
    let largeUrl: String?
    let mediumUrl: String?
    let smallUrl: String?
    let gridUrl: String?
    
    let commonUrl: String?
    
    // Some subjects return null
    init(json: [String : JSON]) {
        largeUrl = json[BangumiKey.largeUrl]?.string
        commonUrl = json[BangumiKey.commonUrl]?.string
        mediumUrl = json[BangumiKey.mediumUrl]?.string
        smallUrl = json[BangumiKey.smallUrl]?.string
        gridUrl = json[BangumiKey.gridUrl]?.string
    }
    
    init(from cdImages: CDImages?) {
        largeUrl = cdImages?.largeUrl
        commonUrl = cdImages?.commonUrl
        mediumUrl = cdImages?.mediumUrl
        smallUrl = cdImages?.smallUrl
        gridUrl = cdImages?.gridUrl
    }
}
