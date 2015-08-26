//
//  Staff.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-21.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public struct StaffTable {
    public var staffs = [Staff]()
    
    init() {
    }
    
    init(staffArr: [NSDictionary]) {
        for staffDict in staffArr {
            staffs.append(Staff(staffDict: staffDict))
        }
    }
    
    
}

public struct Staff {
    public var id = 0
    public var url = ""
    public var name = ""
    public var nameCN = ""
    public var role_name = ""
    
    public var images = StaffImage()
    public var jobs = StaffJobs()
    init() {
    }
    
    init(staffDict: NSDictionary) {
        id = staffDict[BangumiKey.id] as! Int
        url = staffDict[BangumiKey.url] as! String
        name = staffDict[BangumiKey.name] as! String
        nameCN = staffDict[BangumiKey.nameCN] as! String
        role_name = staffDict[BangumiKey.roleName] as? String ?? ""
        
        
        if let imageDict = staffDict[BangumiKey.imagesDict] as? NSDictionary {
            images = StaffImage(StaffImageDict: imageDict)
        }
        
        if let jobArr = staffDict[BangumiKey.jobs] as? [String] {
            jobs = StaffJobs(jobArr: jobArr)
        }
    }

}

public struct StaffImage {
    public var largeUrl = ""
    public var mediumUrl = ""
    public var smallUrl = ""
    public var gridUrl = ""
    
    init() {
    }
    
    init(StaffImageDict: NSDictionary) {
        largeUrl = StaffImageDict[BangumiKey.largeUrl] as! String
        mediumUrl = StaffImageDict[BangumiKey.mediumUrl] as! String
        smallUrl = StaffImageDict[BangumiKey.smallUrl] as! String
        gridUrl = StaffImageDict[BangumiKey.gridUrl] as! String
    }
}

public struct StaffJobs {
    public var firstJob = ""
    
    init() {
    }
    
    init(jobArr: [String]) {
        if let job = jobArr.first {
            firstJob = job
        }
    }
}