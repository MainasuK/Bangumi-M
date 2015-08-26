//
//  BangumiAnime.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation


public struct Anime {
    
    public var name = ""
    public var epStatus = 0
    public var lastTouch = 0

    public var subject = AnimeSubject()
    
    init(json: NSDictionary) {
        name = json[BangumiKey.name] as! String
        epStatus = json[BangumiKey.epStatus] as! Int
        lastTouch = json[BangumiKey.lastTouch] as! Int
        
        let subjectDict = json[BangumiKey.subject] as! NSDictionary
        subject = AnimeSubject(animeSubjectDict: subjectDict)
    }
    
    // FIXME: Anime need fix
    init(subject: AnimeSubject) {
        name = subject.name
        epStatus = -1
        lastTouch = -1
        self.subject = subject
    }
    
    init() {
        
    }
}