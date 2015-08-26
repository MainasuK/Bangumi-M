//
//  PercolatorKey.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-22.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

// MARK: -
// MARK: UserDefaultsKey

public struct UserDefaultsKey {
    static let request              = "request"
    static let hasLoginKey          = "hasLoginKey"
    static let userData             = "userData"
    static let userID               = "userID"
    static let userEmail            = "userEmail"
    static let userAuth             = "userAuth"
    static let userAuthEncode       = "userAuthEncode"
}

// MARK: StoryboardKey

public struct StoryboardKey {
    
    static let initTabBarVC                     = "initTabBarVC"
    
    static let showAnimeListVC                  = "showAnimeListVC"
    static let showAnimeDetailVC                = "showDetailVC"
    static let showLoginVC                      = "showLoginVC"
    
    static let animeDetailTitleCell             = "animeDetailTitleCell"
    static let animeDetailSummayTableViewCell   = "animeDetailSummayCell"
    
    static let loginVC                          = "LoginVC"
    static let animeTableViewVC                 = "AnimeListTableVC"
    static let animeDetailVC                    = "AnimeDetailView"
    static let DetialVC                         = "DetailViewController"
    static let AnimeDetailTableVC               = "AnimeDetailTableVC"
    static let searchTabelVC                    = "SearchTableVC"
    static let favoritesTableVC                 = "FavoritesTableVC"
    static let GridCollectionVC                 = "GridCollectionVC"
    static let AnimeCollectVC                   = "AnimeCollectVC"
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
}