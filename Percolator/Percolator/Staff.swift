//
//  Staff.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-21.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Staff {
    let id: Int
    let url: String
    let name: String
    let nameCN: String
    let roleName: String
    
    let images: Images
    let jobs: [String]
    
    
    init(from json: JSON) {
        id = json[BangumiKey.id].intValue
        url = json[BangumiKey.url].stringValue
        name = json[BangumiKey.name].stringValue
        nameCN = json[BangumiKey.nameCN].stringValue
        roleName = json[BangumiKey.roleName].stringValue
        
        let imageDict = json[BangumiKey.imagesDict].dictionaryValue
        images = Images(json: imageDict)
        
        jobs = json[BangumiKey.jobs].arrayValue.flatMap { $0.string }
    }
}
