//
//  BangumiAnimeModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-7-12.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Haneke

public class BangumiAnimeModel {
    
    /// [Anime]
    public var animeList = [Anime]()
    
    /// [subjectID: AnimeDetailLarge]
    public var animeDetailList = [Int: AnimeDetailLarge]()
    
    /// [subjectID: SubjectItemSattus]
    public var subjectAllStatusList = [Int: SubjectItemStatus]()
    
    /// [subjectID: GridStatus]
    public var animeGridStatusList = [Int: GridStatus]()
    
    /// [subjectID: Bool (posting status)]
    public var animePostingStatusList = [Int: Bool]()
    
    private var completedTasksCount: Int = 0
    private let className = "$ BangumiAnimeModel: "
    
    // MARK: -
    // MARK: Singleton
    private static let instance = BangumiAnimeModel()
    
    private init() {
        
    }
    
    public static var shared: BangumiAnimeModel {
        return self.instance
    }
    
    public func dropModel() {
        self.animeList.removeAll()
        self.animeDetailList.removeAll()
        self.subjectAllStatusList.removeAll()
        self.animeGridStatusList.removeAll()
        self.animePostingStatusList.removeAll()
        self.completedTasksCount = 0
    }
    
    // MARK: Model fetch method
    public func fetchAnimeListTabelVCModel(request: BangumiRequest, handler: (Bool) -> Void) {
        completedTasksCount = 0
        debugPrint(className + "Fetch method called", terminator: "")
        
        guard let user = request.userData else {
            handler(false)
            return
        }

        // Task 1: fetch user watching list
        request.getUserWatching(user.id) { (animeArr) -> Void in
            if (animeArr != nil) {
                self.animeList = animeArr!
                self.completedTasksCount += 1
                debugPrint(self.className + "animeList get")
                self.fetchAnimeDetailList(request, handler)
            } else {
                // Failed
                handler(false)
            }
        }
        
        // Task 2: fetch user watching status
        request.getSubjectStatus(user.id, authEncode: user.authEncode) { (statusDict) -> Void in
            self.subjectAllStatusList = statusDict
            self.completedTasksCount += 1
            debugPrint(self.className + "subjectAllStatusList get")
            self.fetchAnimeDetailList(request, handler)
        }

        
    }
    
    private func isPreconditionCompleted(taskCount: Int) -> Bool {
        return (completedTasksCount == 2) ? true : false
    }
    
    // Task 3: fetch all user watching anime detail info
    // and gridStatus info
    private func fetchAnimeDetailList(request: BangumiRequest, _ handler: (Bool) -> Void) {
        
        if isPreconditionCompleted(self.completedTasksCount) {
            
            var tempAnimeDetailList = animeDetailList
            var tempAnimeGridStatusList = animeGridStatusList
            var tempAnimePostingStatusList = animePostingStatusList
            
            tempAnimeDetailList.removeAll()
            tempAnimeGridStatusList.removeAll()
            tempAnimePostingStatusList.removeAll()
            
            NSNotificationCenter.defaultCenter().postNotificationName("setProgress", object: nil)
            var index = Float(0.0)
            let count = Float(self.animeList.count)
            for anime in self.animeList {
                
                request.getSubjectDetailLarge(anime.subject.id) { (animeDetailLargeData) -> Void in
            
                    if let detailData = animeDetailLargeData {
                        tempAnimeDetailList[anime.subject.id] = detailData
                        tempAnimeGridStatusList[anime.subject.id] = GridStatus(epsDict: detailData.eps.eps)
                        tempAnimePostingStatusList[anime.subject.id] = false
                        index += 1
                        NSNotificationCenter.defaultCenter().postNotificationName("setProgress", object: index/count)
                    } else {
                        // Failed
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        NSNotificationCenter.defaultCenter().postNotificationName("setProgress", object: nil)
                        handler(false)
                    }
                    
                    if self.animeList.count == tempAnimeDetailList.count {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        
                        self.animeDetailList = tempAnimeDetailList
                        self.animeGridStatusList = tempAnimeGridStatusList
                        self.animePostingStatusList = tempAnimePostingStatusList
                        handler(true)
                    }
                }
                
            }   // for anime in self.animeList
        }   // if isPreconditionCompleted(…)
        
    }
    
    // MARK: -
    // MARK: Model modify method
    public func markEpWatched(request: BangumiRequest, animeItem: Anime, markEp ep: EpStatus, _ handler: (ModelModifyStatus) -> Void) {
        animePostingStatusList[animeItem.subject.id]! = true
        
        request.sendEpStatusRequest([ep.id], method: .watched) { (status) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            switch status {
            case SendRequestStatus.success:
                if self.subjectAllStatusList[animeItem.subject.id] == nil {
                    self.subjectAllStatusList[animeItem.subject.id] = SubjectItemStatus()
                }
                self.subjectAllStatusList[animeItem.subject.id]!.subjectId = animeItem.subject.id
                self.subjectAllStatusList[animeItem.subject.id]!.subjectStatus[ep.id] = .watched
                self.subjectAllStatusList[animeItem.subject.id]!.count += 1
            
                handler(.success)
                
            case SendRequestStatus.failed:      handler(.failed)
            case SendRequestStatus.timeout:     handler(.timeout)
            }
        }
    
    }
    
    // For Detail VC
    public func markEpWatched(request: BangumiRequest, subjectID: Int, markEpID epID: Int, method: UpdateSatusMethod, _ handler: (Bool) -> Void) {
        
        request.sendEpStatusRequest([epID], method: method) { (status) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            switch status {
            case SendRequestStatus.success:
                if self.subjectAllStatusList[subjectID] == nil {
                    self.subjectAllStatusList[subjectID] = SubjectItemStatus()
                }
                self.subjectAllStatusList[subjectID]!.subjectId = subjectID
                self.subjectAllStatusList[subjectID]!.subjectStatus[epID] = .watched
                
                handler(true)
                
            case SendRequestStatus.failed:      handler(false)
            case SendRequestStatus.timeout:     handler(false)
            }
        }
        
    }
    
    public func markEpsWatched(request: BangumiRequest, animeItem: Anime, _ method: UpdateSatusMethod, _ rating: Int?, _ comment: String?, _ tags: [String]?,  _ handler: (ModelModifyStatus) -> Void) {
        
        request.sendEpsStatusRequest(animeItem, method, rating, comment, tags) { (status) -> Void in
         
            switch status {
            case .success:
                handler(.success)
                
            case .failed:
                handler(.failed)
            case .timeout:
                handler(.failed)
            }
            
        }
        
    }
    
}

public enum ModelModifyStatus: String {
    case timeout = "timeout"
    case failed = "failed"
    case success = "success"
}