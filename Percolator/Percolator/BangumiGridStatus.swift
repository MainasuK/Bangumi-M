//
//  BangumiGridStatus.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-23.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct GridStatus {

    public var gridTable = [[EpStatus]]()
    
    public var normalTable = [EpStatus]()
    public var spTable = [EpStatus]()
    public var opTable = [EpStatus]()
    public var edTable = [EpStatus]()
    
    
    init() {
    }
    
    init(epsDict: [NSDictionary]) {
        for epDict in epsDict {
            let epStatus = EpStatus(epDict: epDict)
            switch epStatus.type {
            case EpisodeType.normal: normalTable.append(epStatus)
            case EpisodeType.sp: spTable.append(epStatus)
            case EpisodeType.op: opTable.append(epStatus)
            case EpisodeType.ed: edTable.append(epStatus)
            }
        }
        
        gridTable.append(normalTable)
        gridTable.append(spTable)
        gridTable.append(opTable)
        gridTable.append(edTable)
    }
    
    public func lastTouchEP (animeStatus: SubjectItemStatus) -> EpStatus? {
        var lastTouchEP: EpStatus?
        for ep in normalTable {
            let epID = ep.id
            if animeStatus.subjectStatus[epID] == EpStatusType.watched {
                lastTouchEP = ep
            }
        }
        
        return lastTouchEP
    }
    
    public func nextMarkEP (lastTouchEpSort: Int) -> EpStatus? {
        if lastTouchEpSort != 0 {
            for ep in normalTable {
                if ep.sort > lastTouchEpSort { return ep }
            }
        } else { return normalTable.first }
        
        return nil
    }
    
    /// Return ep, sp, op ed counts together
    public func counts() -> Int {
        return normalTable.count + spTable.count + opTable.count + edTable.count
    }
}

public struct EpStatus {
    var id = 0
    var sort = 0
    var sortStr = ""
    var type = EpisodeType.normal
    var typeStr = ""
    var name = ""
    var status = AirState.air   // FIXME: Defalut Value may not suitable
    var airDate = ""
    var comment = 0
    
    init(epDict: NSDictionary) {
        self.id = epDict[BangumiKey.id] as! Int
        self.sort = epDict[BangumiKey.sort] as! Int
//        self.sortStr = "\((epDict[BangumiKey.sort] as! Float))"
        self.type = EpisodeType(rawValue: epDict[BangumiKey.type] as! Int)!
        self.name = epDict[BangumiKey.name] as! String
        // FIXME:
        if let status = epDict[BangumiKey.status] as? String {
            if status != "" {
                self.status = AirState(rawValue: status)!
            }
        }
        self.airDate = epDict[BangumiKey.airDate] as? String ?? ""
        self.comment = epDict[BangumiKey.comment] as? Int ?? 0
        
        switch self.type {
        case .normal:   self.typeStr = "EP"
        case .sp:       self.typeStr = "SP"
        case .op:       self.typeStr = "OP"
        case .ed:       self.typeStr = "ED"
        }
        
        let epNum = epDict[BangumiKey.sort] as! Float
        if epNum % 1 != 0 {
            self.sortStr = "\(epNum)"
        } else {
            self.sortStr = "\(self.sort)"
        }
    }
}