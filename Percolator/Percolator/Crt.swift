//
//  Crt.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Crt {
    let id: Int
    let url: String
    let name: String
    let nameCN: String
    let roleName: String
    
    let images: Images
    let actors: [Actor]
    
    let comment: Int
    let collects: Int
    
    // TODO:
//    let info = CrtInfo()
//    let actors = CrtActors()
    
    init(from json: JSON) {
        id = json[BangumiKey.id].intValue
        url = json[BangumiKey.url].stringValue
        name = json[BangumiKey.name].stringValue
        nameCN = json[BangumiKey.nameCN].stringValue
        roleName = json[BangumiKey.roleName].stringValue
        
        let imageDict = json[BangumiKey.imagesDict].dictionaryValue
        images = Images(json: imageDict)
        
        actors = json[BangumiKey.actorDict].arrayValue.map { Actor(from: $0) }
        
        comment = json[BangumiKey.comment].intValue
        collects = json[BangumiKey.collects].intValue
        
//        if let infoDict = json[BangumiKey.infoDict] as? NSDictionary {
//            info = CrtInfo(crtInfoDict: infoDict)
//        }
//        
//        if let actorsDict = json[BangumiKey.actorDict] as? [NSDictionary] {
//            actors = CrtActors(actorArr: actorsDict)
//        }
    }
}
