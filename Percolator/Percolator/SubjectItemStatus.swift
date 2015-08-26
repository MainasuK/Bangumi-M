//
//  SubjectItemStatus.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct SubjectItemStatus {
    public var subjectId = 0
    
    /// epID : EpStatusType
    public var subjectStatus = [Int: EpStatusType]()    // use epID as key
    public var count = 0
    
    init() {
    }
    
    init(subjectStatusDict: NSDictionary) {
        self.subjectId = subjectStatusDict[BangumiKey.subjectID] as! Int
        
        var index = 0
        
        var epsArr = subjectStatusDict[BangumiKey.eps] as! [NSDictionary]
        for ep in epsArr {
            if let id = ep[BangumiKey.id] as? Int {
                if let statusDict = ep[BangumiKey.statusDict] as? NSDictionary {
                    subjectStatus[id] = EpStatusType(rawValue: (statusDict[BangumiKey.id] as? Int)!)    // statusType
                } else {
                    
                }
            }
            
            index++
        }
        
        self.count = index
    }
}

// MARK: SubjectItemStatus Key
public enum EpStatusType: Int {
    case watched = 2
    case drop = 3
    case queue = 1
}

public enum UpdateSatusMethod: String {
    case remove = "remove"
    case watched = "watched"
    case drop = "drop"
    case queue = "queue"
    
    case doing = "do"
    case hold = "on_hold"
    case dropped = "dropped"
    case wish = "wish"
    case collect = "collect"
    
}

public enum EpisodeType: Int {
    case normal
    case sp
    case op
    case ed
}

public enum AirState: String {
    case air = "Air"
    case notAir = "NA"
    case today = "Today"
}