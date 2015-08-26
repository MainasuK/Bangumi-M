//
//  Actor.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct Actor {
    public var id = 0
    public var url = ""
    public var name = ""
    
    public var image = CrtImage()
    
    init() {
    }
    
    init(actorDict: NSDictionary) {
        id = actorDict[BangumiKey.id] as! Int
        url = actorDict[BangumiKey.url] as! String
        name = actorDict[BangumiKey.name] as! String
        
        if let imageDict = actorDict[BangumiKey.imagesDict] as? NSDictionary {
            image = CrtImage(crtImageDict: imageDict)
        }
    }
}