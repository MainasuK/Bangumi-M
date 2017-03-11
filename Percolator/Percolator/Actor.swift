//
//  Actor.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Actor {
    var id: Int
    var url: String
    var name: String

//    var image = CrtImage()

    init(from json: JSON) {
        id = json[BangumiKey.id].intValue
        url = json[BangumiKey.url].stringValue
        name = json[BangumiKey.name].stringValue

//        if let imageDict = actorDict[BangumiKey.imagesDict] as? NSDictionary {
//            image = CrtImage(crtImageDict: imageDict)
//        }
    }
}
