//
//  BangumiKey.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

// MARK: User
struct BangumiKey {
    static let id = "id"
    static let url = "url"
    static let username = "username"
    static let nickname = "nickname"
    static let avatar = "avatar"
    static let avatarLargeUrl = "large"
    static let avatarMediumUrl = "medium"
    static let avatarSmallUrl = "small"
    static let sign = "sign"
}

extension BangumiKey {
    // auth key
    static let auth = "auth"
    static let authEncode = "auth_encode"
}

// MARK: Anime
extension BangumiKey {
    static let name = "name"
    static let epStatus = "ep_status"
    static let lastTouch = "lasttouch"
}

extension BangumiKey {
    // subject key
    static let subject = "subject"
    static let type = "type"
    static let nameCN = "name_cn"
    static let summary = "summary"
    static let eps = "eps"
    static let airDate = "air_date"
    static let airWeekday = "air_weekday"
    static let rank = "rank"
}

extension BangumiKey {
    // SubjectRating key
    static let subjectRating = "rating"
    static let count = "count"
    static let score = "score"
    static let total = "total"
}

extension BangumiKey {
    // subjectImages key
    static let subjectImages = "images"
    static let largeUrl = "large"
    static let commonUrl = "common"
    static let mediumUrl = "medium"
    static let smallUrl = "small"
    static let gridUrl = "grid"
}

extension BangumiKey {
    // subjectCollection key
    static let subjectCollection = "collection"
    static let wish = "wish"
    static let collect = "collect"
    static let doing = "doing"
    static let onHold = "on_hold"
    static let dropped = "dropped"
}

// MARK: Anime Detail key
extension BangumiKey {
    // detail ep key
    static let epsDict = "eps"
    static let epAirDate = "airdate" // special key
    static let sort = "sort"
    static let duration = "duration"
    static let comment = "comment"
    static let describe = "desc"
    static let status = "status"
}

extension BangumiKey {
    // detail dict key
    static let imagesDict = "images"
    static let collectionDict = "collection"
    static let crtDict = "crt"
    static let staffDict = "staff"
    static let topicDict = "topic"
    static let blogDict = "blog"
}


extension BangumiKey {
    // crt key
    static let roleName = "role_name"
    static let collects = "collects"
}

extension BangumiKey {
    // crt dict key
    static let infoDict = "info"
    static let actorDict = "actors"
}

extension BangumiKey {
    // crtInfo key
    static let aliasDict = "alias"
    
    static let gender = "gender"
    static let birth = "birth"
    static let bloodType = "bloodtype"
    static let height = "height"
    static let weight = "weight"
    static let bwh = "bwh"
    static let source = "source"
}

extension BangumiKey {
    // crtInfoAlias key
    static let en = "en"
    static let jp = "jp"
    static let romaji = "romaji"
}

extension BangumiKey {
    // status key
    static let statusDict = "status"
    static let subjectID = "subject_id"
}

extension BangumiKey {
    static let subjectCrt = "crt"
}

extension BangumiKey {
    static let jobs = "jobs"
}

extension BangumiKey {
    static let title = "title"
    static let mainID = "main_id"
    static let timestamp = "timestamp"
    static let lastpost = "lastpost"
    static let replies = "replies"
    
    static let user = "user"
}

extension BangumiKey {
    static let cssName = "css_name"
    static let urlName = "url_name"
    static let cnName = "cn_name"
}
