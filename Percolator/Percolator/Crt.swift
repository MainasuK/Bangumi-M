//
//  Crt.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct CrtTable {
    public var crts = [Crt]()
    
    init() {
    }
    
    init(crtArr: [NSDictionary]) {
        for crtDict in crtArr {
            crts.append(Crt(crtDict: crtDict))
        }
    }
    
    //    public func valueAtKey(key: Int) -> Crt? {
    //        if key <= crts.count && key >= 0 {
    //            let crtDict = crts[key] as NSDictionary
    //
    //            return Crt(crtDict: crtDict)
    //        }
    //
    //        return nil
    //    }
}

public struct Crt {
    public var id = 0
    public var url = ""
    public var name = ""
    public var nameCN = ""
    public var role_name = ""
    
    public var images = CrtImage()
    
    public var comment = 0
    public var collects = 0
    
    public var info = CrtInfo()
    public var actors = CrtActors()
    
    init() {
    }
    
    init(crtDict: NSDictionary) {
        id = crtDict[BangumiKey.id] as! Int
        url = crtDict[BangumiKey.url] as! String
        name = crtDict[BangumiKey.name] as! String
        nameCN = crtDict[BangumiKey.nameCN] as! String
        role_name = crtDict[BangumiKey.roleName] as? String ?? ""
        
        if let imageDict = crtDict[BangumiKey.imagesDict] as? NSDictionary {
            images = CrtImage(crtImageDict: imageDict)
        }
        
        comment = crtDict[BangumiKey.comment] as! Int
        collects = crtDict[BangumiKey.collects] as! Int
        
        if let infoDict = crtDict[BangumiKey.infoDict] as? NSDictionary {
            info = CrtInfo(crtInfoDict: infoDict)
        }
        
        if let actorsDict = crtDict[BangumiKey.actorDict] as? [NSDictionary] {
            actors = CrtActors(actorArr: actorsDict)
        }
    }
}

public struct CrtImage {
    public var largeUrl = ""
    public var mediumUrl = ""
    public var smallUrl = ""
    public var gridUrl = ""
    
    init() {
    }
    
    init(crtImageDict: NSDictionary) {
        largeUrl = crtImageDict[BangumiKey.largeUrl] as! String
        mediumUrl = crtImageDict[BangumiKey.mediumUrl] as! String
        smallUrl = crtImageDict[BangumiKey.smallUrl] as! String
        gridUrl = crtImageDict[BangumiKey.gridUrl] as! String
    }
}

public struct CrtInfo {
    public var nameCN = ""
    
    public var alias = CrtInfoAlias()
    
    public var gender = ""
    public var birth = ""
    public var bloodtype = ""
    public var height = ""
    public var weight = ""
    public var bwh = ""
    public var source = ""
    
    init() {
    }
    
    init(crtInfoDict: NSDictionary) {
        nameCN = crtInfoDict[BangumiKey.nameCN] as? String ?? ""
        
        if let aliasDict = crtInfoDict[BangumiKey.aliasDict] as? NSDictionary {
            alias = CrtInfoAlias(crtInfoAliasDict: aliasDict)
        }
        
        gender = crtInfoDict[BangumiKey.gender] as? String ?? ""
        birth = crtInfoDict[BangumiKey.birth] as? String ?? ""
        bloodtype = crtInfoDict[BangumiKey.bloodType] as? String ?? ""
        height = crtInfoDict[BangumiKey.height] as? String ?? ""
        weight = crtInfoDict[BangumiKey.weight] as? String ?? ""
        bwh = crtInfoDict[BangumiKey.bwh] as? String ?? ""
        source = crtInfoDict[BangumiKey.source] as? String ?? ""
    }
    
}

public struct CrtInfoAlias {
    public var en = ""
    public var jp = ""
    public var romaji = ""
    
    init() {
    }
    
    init(crtInfoAliasDict: NSDictionary) {
        en = crtInfoAliasDict[BangumiKey.en] as? String ?? ""
        jp = crtInfoAliasDict[BangumiKey.jp] as? String ?? ""
        romaji = crtInfoAliasDict[BangumiKey.romaji] as? String ?? ""
    }
}

public struct CrtActors {
    public var actors = [NSDictionary]()
    
    init() {
    }
    
    init(actorArr: [NSDictionary]) {
        actors = actorArr
    }
    
    // FIXME:
    public func valueAtKey(key: Int) -> Actor? {
        if key < actors.count && key >= 0 {
            if let actorDict = actors[key] as? NSDictionary {
                return Actor(actorDict: actorDict)
            }
        }
        
        return nil
    }
}