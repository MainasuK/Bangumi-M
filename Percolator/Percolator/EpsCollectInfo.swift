//
//  EpsCollectInfo.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct EpsCollectInfo {
    public let status: Status
    public let rating: Int
    public let comment: String
    public let tags: [String]
    
    init(infoDict: NSDictionary) {
        status = Status(statusDict: infoDict["status"] as! NSDictionary)
        rating = infoDict["rating"] as! Int
        comment = infoDict["comment"] as? String ?? ""
        tags = infoDict["tag"] as? [String] ?? [String]()
    }
    
    public struct Status {
        let id: Int
        let type: UpdateSatusMethod
        let name: String
        
        init(statusDict: NSDictionary) {
            id = statusDict["id"] as! Int
            type = UpdateSatusMethod(rawValue: (statusDict["type"] as! String))!
            name = statusDict["name"] as? String ?? ""  // it maybe null
        }
    }
}
