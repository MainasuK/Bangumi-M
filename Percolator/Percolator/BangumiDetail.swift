//
//  BangumiDetail.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation


public struct BangumiDetailSource {
    
    var sourceNameList = [String]()
    var sourceArr = [[Item]]()          // collection source data
    var sourceList = [Item]()           // table souce data
    
    var animeDetailLarge: AnimeDetailLarge?
    var gridStatusTable: GridStatus?
    var subjectStatusDict: SubjectItemStatus?
    
    init() {
    }
    
    // FIXME:
    init(subject: AnimeDetailLarge) {
        
        if let topicTable = subject.topicTable {
            var topicItems = [Item]()
            for topic in topicTable.topics {
                // TODO: time
                topicItems.append(Item(title: topic.title, subtitle: topic.nickname, url: topic.url, img: topic.avatar.largeUrl, reply: topic.replies))
            }
            sourceList = topicItems
        }
        
        if let crtTabel = subject.crtTable {
            var crtItems = [Item]()
            for crt in crtTabel.crts {
                let title = (crt.name == "") ? crt.nameCN : crt.name
                crtItems.append(Item(title: title, subtitle: crt.actors.valueAtKey(0)?.name ?? "", url: crt.url, img: crt.images.gridUrl))
            }
            sourceArr.append(crtItems)
            sourceNameList.append("出场人物")
        }
        
        if let staffTable = subject.staffTable {
            var staffItems = [Item]()
            for staff in staffTable.staffs {
                let title = (staff.name == "") ? staff.nameCN : staff.name
                staffItems.append(Item(title: title, subtitle: staff.jobs.firstJob, url: staff.url, img: staff.images.gridUrl))
            }
            sourceArr.append(staffItems)
            sourceNameList.append("制作人员")
        }
    }
    
    public func markEp(request: BangumiRequest, markEp ep: EpStatus, method: UpdateSatusMethod, _ handler: (ModelModifyStatus) -> Void) {

        request.sendEpStatusRequest([ep.id], method: method) { (status) -> Void in
            switch status {
            case .success:
                handler(ModelModifyStatus.success)
                let key = ep.id
                // FIXME: Not Good
                // Change Model in VC
                handler(ModelModifyStatus.success)
            default:
                handler(ModelModifyStatus.failed)
            }
        }
    }
}

extension BangumiDetailSource {
    public mutating func appendArray(items: [Item], name: String) {
        sourceNameList.append(name)
        sourceArr.append(items)
    }
}

public struct Item {
    // Crt & Staff
    var title = ""
    var subtitle = ""
    var url = ""
    var img = ""
    
    // Topic
    var time = ""
    var reply = 0
    
//    // Eps
//    var status = EpisodeType.normal
//    var id = 0
    
    init() {
    }
    
    init(title: String, subtitle: String = "", url: String = "", img: String = "", time: String = "", reply: Int = 0) {
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.img = img
        self.time = (time == "0000-00-00") ? "" : time
        self.reply = reply
//        self.status = status
//        self.id = id
    }
}