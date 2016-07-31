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

//public struct CrtInfo {
//    public let nameCN = ""
//    
//    public let alias = CrtInfoAlias()
//    
//    public let gender = ""
//    public let birth = ""
//    public let bloodtype = ""
//    public let height = ""
//    public let weight = ""
//    public let bwh = ""
//    public let source = ""
//    
//    init() {
//    }
//    
//    init(crtInfoDict: NSDictionary) {
//        nameCN = crtInfoDict[BangumiKey.nameCN] as? String ?? ""
//        
//        if let aliasDict = crtInfoDict[BangumiKey.aliasDict] as? NSDictionary {
//            alias = CrtInfoAlias(crtInfoAliasDict: aliasDict)
//        }
//        
//        gender = crtInfoDict[BangumiKey.gender] as? String ?? ""
//        birth = crtInfoDict[BangumiKey.birth] as? String ?? ""
//        bloodtype = crtInfoDict[BangumiKey.bloodType] as? String ?? ""
//        height = crtInfoDict[BangumiKey.height] as? String ?? ""
//        weight = crtInfoDict[BangumiKey.weight] as? String ?? ""
//        bwh = crtInfoDict[BangumiKey.bwh] as? String ?? ""
//        source = crtInfoDict[BangumiKey.source] as? String ?? ""
//    }
//    
//}
//
//public struct CrtInfoAlias {
//    public let en = ""
//    public let jp = ""
//    public let romaji = ""
//    
//    init() {
//    }
//    
//    init(crtInfoAliasDict: NSDictionary) {
//        en = crtInfoAliasDict[BangumiKey.en] as? String ?? ""
//        jp = crtInfoAliasDict[BangumiKey.jp] as? String ?? ""
//        romaji = crtInfoAliasDict[BangumiKey.romaji] as? String ?? ""
//    }
//}
//
