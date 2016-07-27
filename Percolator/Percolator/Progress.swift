//
//  Progress.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias EpisodeID = Int
typealias Progress = [EpisodeID : Status]

enum Status: Int {
    case queue = 1      // 想看
    case watched = 2    // 看过
    case drop = 3       // 抛弃
    case none           // 无状态 (撤销）
    
    func toURLParams() -> String {
        switch self {
        case .queue:    return "queue"
        case .watched:  return "watched"
        case .drop:     return "drop"
        case .none:     return "remove"
        }
    }
}

//
//struct Progress {
//    let id: Int         // ep ID
//    var status: Status
//    
//    init(from json: JSON) {
//        self.id = json[BangumiKey.id].intValue
//        self.status = Status(rawValue: json[BangumiKey.status][BangumiKey.id].intValue) ?? .none
//    }
//    
//    init(with episodeID: Int, for status: Status) {
//        self.id = episodeID
//        self.status = status
//    }
//    
//}
//
//extension Progress {
//    
//    enum Status: Int {
//        case queue = 1      // 想看
//        case watched = 2    // 看过
//        case drop = 3       // 抛弃
//        case none           // 无状态 (撤销）
//        
//        func toURLParams() -> String {
//            switch self {
//            case .queue:    return "queue"
//            case .watched:  return "watched"
//            case .drop:     return "drop"
//            case .none:     return "remove"
//            }
//        }
//    }
//    
//}
