//
//  Rating.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-12.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

// New item added to API in 2016 Summer
struct Rating {
    let count: [String : Int]
    let score: Double
    let total: Int
    
    init(json: [String : JSON]) {
        var tempCount = [String : Int]()
        if let countDict = json[BangumiKey.count]?.dictionaryValue {
            for (index, subJSON) in countDict {
                tempCount[index] = subJSON.intValue
            }
        }

        count = tempCount
        score = json[BangumiKey.score]?.doubleValue ?? 0.0
        total = json[BangumiKey.total]?.intValue ?? 0
    }
    
    init(from cdRating: CDRating?) {
        count = cdRating?.count as? [String : Int] ?? [:]
        score = cdRating?.score ?? 0
        total = Int(cdRating?.total ?? 0)
    }
}
