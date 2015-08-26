//
//  Topic.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-21.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct TopicTabel {
    public var topics = [Topic]()
    
    init() {
    }
    
    init(topicArr: [NSDictionary]) {
        for topicDict in topicArr {
            topics.append(Topic(topicDict: topicDict))
        }
    }
}

public struct Topic {
    public var id = 0
    public var url = ""
    public var title = ""
    public var mainID = 0
    public var timestamp = 0
    public var lastpost = 0
    public var replies = 0
    
    public var nickname = ""
    public var username = ""
    public var userUrl = ""
    public var uid = 0
    public var avatar = Avatar()
    
    
    init() {
    }
    
    init(topicDict: NSDictionary) {
        id = topicDict[BangumiKey.id] as! Int
        url = topicDict[BangumiKey.url] as! String
        title = topicDict[BangumiKey.title] as! String
        mainID = topicDict[BangumiKey.mainID] as! Int
        timestamp = topicDict[BangumiKey.timestamp] as! Int
        lastpost = topicDict[BangumiKey.lastpost] as! Int
        replies = topicDict[BangumiKey.replies] as! Int
        
        if let userDict = topicDict[BangumiKey.user] as? NSDictionary {
            uid = userDict[BangumiKey.id] as! Int
            userUrl = userDict[BangumiKey.url] as! String
            username = userDict[BangumiKey.userName] as! String
            nickname = userDict[BangumiKey.nickName] as! String
            avatar = Avatar(avatarDict: userDict[BangumiKey.avatar] as! NSDictionary)
        }
    }
}


