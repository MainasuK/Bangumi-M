//
//  PercolatorKey.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-22.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

// MARK: - UserDefaultsKey

public struct UserDefaultsKey {
    static let hasLoginKey          = "hasLoginKeyV2"
    
    static let username             = "username"
    static let userNickname         = "userNickName"
    static let userURL              = "user URL"
    static let userSign             = "userSign"
    static let userID               = "userID"
    static let userEmail            = "userEmail"
    static let userAvatarDict       = "userAvatarDict"
    static let userAuth             = "userAuth"
    static let userAuthEncode       = "userAuthEncode"
    static let userLargeAvatar      = "userLargeAvatar"
    static let userMediumAvatar     = "userMediumAvatar"
    static let userSmallAvatar      = "usrSmallAvatar"
}

// MARK: - StoryboardKey
// FIXME: need to unify
public struct StoryboardKey {
    
    static let LoginViewController                  = "LoginViewController"
    
    static let animeTableViewVC                     = "AnimeListTableVC"
    static let AnimeListTableViewCellKey            = "animeCell"
    
    static let DetailNavigationVC                   = "DetailTableViewControllerNaviVC"
    static let DetailTableViewEPSHeaderFooterView   = "DetailTableViewEPSHeaderFooterView"
    static let DetialTableViewControllerKey         = "DetailTableViewController"
    static let DetailTableViewBannerCellKey         = "DetailTableViewBannerCell"
    static let DetailTableViewMoreTopicCellKey      = "DetailTableViewMoreTopicCellKey"
    static let DetailTableViewMoreSubjectCellKey    = "DetailTableViewMoreSubjectCellKey"
    static let DetailTableViewEPSCellKey            = "DetailTableViewEPSCellKey"
    static let DetailTableViewCell_CollectionView   = "DetailTableViewCell_CollectionView"
    static let CMKCollectionViewCell                = "CMKCollectionViewCell"
    
    static let TopicTableViewHeaderFooterView       = "TopicTableViewHeaderFooterView"
    static let TopicTableViewControllerKey          = "TopicTableViewControllerKey"
    static let TopicTableViewCellKey                = "TopicTableViewCellKey"
    
    static let SubjectCollectionViewHeaderView      = "SubjectCollectionReusableHeaderView"
    static let SubjectCollectionViewController      = "SubjectCollectionViewController"
    static let SubjectCollectionViewBookCellKey     = "SubjectCollectionViewBookCellKey"
    static let SubjectCollectionViewNotBookCellKey  = "SubjectCollectionViewNotBookCellKey"
    
    static let searchTabelVC                        = "SearchTableVC"
    static let searchTabelNaviVC                    = "SearchTableNaviVC"
    
    static let SearchBoxTableViewCellKey            = "SearchBoxTableViewCell"
    
    static let CollectTableViewController           = "CollectTableViewController"
    static let CollectNavigationController          = "CollectNavigationController"
    
}

extension StoryboardKey {
    
    static let popToCollectViewController           = "popToCollectViewController"
    
}

public struct PercolatorKey {
    static let typeArr = ["未知类型", "书籍", "动画", "音乐", "游戏", "未知类型", "三次元"]
    static let typeDoingArr = [0 : ["想看", "看过", "在看", "搁置", "抛弃"],
                               1 : ["想读", "读过", "在读", "搁置", "抛弃"],
                               2 : ["想看", "看过", "在看", "搁置", "抛弃"],
                               3 : ["想听", "听过", "在听", "搁置", "抛弃"],
                               4 : ["想玩", "玩过", "在玩", "搁置", "抛弃"],
                               5 : ["想看", "看过", "在看", "搁置", "抛弃"],
                               6 : ["想看", "看过", "在看", "搁置", "抛弃"]
                              ]
    static let searchTypeArr = ["全部", "动画", "书籍", "音乐", "游戏", "三次元"]
    static let searchTypeDict = [0 : 0,   // All
                                 1 : 2,   // Anime
                                 2 : 1,   // Book
                                 3 : 3,   // Music
                                 4 : 4,   // Game
                                 5 : 6    // Can't understand
                                ]
}
