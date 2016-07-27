//
//  AnimeEps.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct AnimeEps {
    public var eps = [NSDictionary]()
    
    public var count: Int {
        return eps.count
    }
    
    public var typeCount: [Int: Int] {
        var normalCount = 0
        var spCount = 0
        var opCount = 0
        var edCount = 0
        var dict = [Int: Int]()
        
        
        for ep in self.eps {
            if let type = ep[BangumiKey.type] as? Int {
                switch type {
                case EpisodeType.normal.rawValue: normalCount += 1
                case EpisodeType.sp.rawValue: spCount += 1
                case EpisodeType.op.rawValue: opCount += 1
                case EpisodeType.ed.rawValue: edCount += 1
                default: print("^ AnimeEpsUndefined ep type \(type)")
                }
            }
        }
        
        dict[EpisodeType.normal.rawValue] = normalCount
        dict[EpisodeType.sp.rawValue] = spCount
        dict[EpisodeType.op.rawValue] = opCount
        dict[EpisodeType.ed.rawValue] = edCount
        
        return dict
    }
    
    
    init() {
    }
    
    init(epsArr: [NSDictionary]) {
        eps = epsArr
    }
    
    /// FIXME: this method get AnimeEp in self.eps with default order which is from 0 to epsCount but it's not always right (with op/sp/ed or something)
    public func valueAtKey(_ key: Int) -> AnimeEp? {
        if key <= eps.count && key >= 0 {
            let epDict = eps[key] as NSDictionary
            
            return AnimeEp(epDict: epDict)
        }
        
        return nil
    }
    
    public func getEpIDwith(_ type: Int, sort: Int) -> Int? {
        for ep in self.eps {
            if let epType = ep[BangumiKey.type] as? Int,
                let epSort = ep[BangumiKey.sort] as? Int {
                    
                    if epType == type && epSort == sort {
                        return ep[BangumiKey.id] as? Int
                    }
            }
        }
        
        return nil
    }
    
    //    public func episodeType(key: Int) -> EpisodeType? {
    //        let ep = self.valueAtKey(key)
    //        if let type = ep?.type {
    //            switch type {
    //            case 0: return EpisodeType.normal
    //            case 1: return EpisodeType.sp
    //            case 2: return EpisodeType.op
    //            case 3: return EpisodeType.ed
    //            default: return EpisodeType.normal
    //            }
    //        }
    //
    //        return EpisodeType.normal
    //    }
    //
    //
    //    FIXME: the ep is not in Episode order
    //    public func episodeID(index: Int) -> Int {
    //        if let ep = self.valueAtKey(index) {
    //            return ep.id
    //        }
    //
    //        return -1
    //    }
    //
    //    public func episodeTypeAndIndex(row: Int) -> (EpisodeType, Int) {
    //        if let ep = self.valueAtKey(row) {
    //            let type = EpisodeType(rawValue: ep.type)!
    //            return (type, ep.sort)
    //        }
    //        
    //        return (EpisodeType.normal, -1)
    //    }
}
