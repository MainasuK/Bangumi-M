//
//  Episode.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Episode {
    
    static let sortFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 0
        
        return formatter
    }()
    
    let id: EpisodeID
    
    let url: String
    let type: Type
    let sort: Double
    let name: String
    let nameCN: String
    let duration: String
    let airDate: String
    let comment: Int
    let desc: String
    let status: State
    
    var typeString: String {
        switch type {
        case .ep:       return "EP"
        case .sp:       return "SP"
        case .op:       return "OP"
        case .ed:       return "ED"
        }
    }
    
    var sortString: String {
        // Remove .0 for episode sort
        return Episode.sortFormatter.string(from: sort as NSNumber) ?? ""
    }
    
    var mobileURL: String {
        return "http://bangumi.tv/m/topic/subject/\(id)"
    }
    var webURL: String {
        return "http://bangumi.tv/ep/\(id)"
    }
    
    init(from json: JSON) {
        // ID should exists all the time
        id = json[BangumiKey.id].int!
        
        url = json[BangumiKey.url].stringValue
        type = Type(rawValue: json[BangumiKey.type].intValue) ?? .ep
        sort = json[BangumiKey.sort].doubleValue
        name = json[BangumiKey.name].stringValue
        nameCN = json[BangumiKey.nameCN].stringValue
        duration = json[BangumiKey.duration].stringValue
        airDate = json[BangumiKey.airDate].stringValue.replacingOccurrences(of: "0000-00-00", with: "")
        comment = json[BangumiKey.comment].intValue
        desc = json[BangumiKey.describe].stringValue
        status = State(rawValue: json[BangumiKey.status].stringValue) ?? .notAir
    }
}

extension Episode {
    
    enum `Type`: Int {
        case ep = 0
        case sp = 1
        case op = 2
        case ed = 3
    }
    
    enum State: String {
        case air = "Air"
        case notAir = "NA"
        case today = "Today"
    }
        
}

