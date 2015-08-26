//
//  BangumiAnimeDetail.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-16.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct AnimeDetailLarge {
    
    public var id = 0
    public var url = ""
    public var type = 0
    public var name = ""
    public var nameCN = ""
    public var summary = ""
    
    public var eps = AnimeEps()
    public var images = AnimeImages()
    public var collection = AnimeCollection()
    
    public var crtTable = CrtTable?()
    public var staffTable = StaffTable?()
    public var topicTable = TopicTabel?()
//    public var blogDict = [NSDictionary]()
    
    public var airDate = ""
    public var airWeekday = 0
    
    // FIXME:
//    public var section: Int {
//        var defaultSection = 1
//        if summary != "" {
//            defaultSection++
//        }
//        if (crtTable != nil) {
//            defaultSection++
//        }
//        
//        return defaultSection
//    }
    
    init() {
    }
    
    init(json: NSDictionary) {
        id = json[BangumiKey.id] as! Int
        url = json[BangumiKey.url] as! String
        type = json[BangumiKey.type] as! Int
        name = json[BangumiKey.name] as! String
        nameCN = json[BangumiKey.nameCN] as! String
        summary = json[BangumiKey.summary] as! String
        
        airDate = json[BangumiKey.airDate] as? String ??
        ""
        airWeekday = json[BangumiKey.airWeekday] as? Int ?? 0
        
        if let epsArr = json[BangumiKey.eps] as? [NSDictionary] {
            eps = AnimeEps(epsArr: epsArr)
        }

        if let imagesDict = json[BangumiKey.imagesDict] as? NSDictionary {
            images = AnimeImages(animeImagesDict: imagesDict)
        }
        
        if let collectionDict = json[BangumiKey.collectionDict] as? NSDictionary {
            collection = AnimeCollection(animeCollectionDict: collectionDict)
        }
        
        if let crtArr = json[BangumiKey.crtDict] as? [NSDictionary] {
            crtTable = CrtTable(crtArr: crtArr)
        }
        
        if let staffArr = json[BangumiKey.staffDict] as? [NSDictionary] {
            staffTable = StaffTable(staffArr: staffArr)
        }
        
        if let topicArr = json[BangumiKey.topicDict] as? [NSDictionary] {
            topicTable = TopicTabel(topicArr: topicArr)
        }
    }
}