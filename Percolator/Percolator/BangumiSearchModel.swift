//
//  BangumiSearchModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-12.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit

public class BangumiSearchModel {
    
    let limit = 10
    
    var startIndex = 0
    var lastSearchText = ""
    var noMoreData = false
    
    var subjectIDList = [Int]()
    /// subjectID : AnimeSubject
    var subjectsList = [Int : AnimeSubject]()
    
    /// User saved subject ( Core Data )
    var subjectLocalList = [AnimeSubject]()

    
    // - MARK: Singleton
    private static let instance = BangumiSearchModel()
    
    private init() {
        
    }
    
    public static var shared: BangumiSearchModel {
        return self.instance
    }
    
    public func dropModel() {
        self.startIndex = 0
        self.lastSearchText = ""
        self.noMoreData = false
        self.subjectIDList = [Int]()
        self.subjectsList = [Int : AnimeSubject]()
        self.subjectLocalList = [AnimeSubject]()
    }
    
    // MARK: - Model method
    private func getSubjectToSearchBox(index: Int) -> AnimeSubject {
        return self.subjectsList[self.subjectIDList[index]]!
    }
    
    // FIXME:
    public func getSubjectAndSavedInfoToSearchBox(index: Int, _ isSearching: Bool) -> (subject: AnimeSubject, isSaved: Bool) {
        
        if !isSearching {
            return (subjectLocalList[index], true)
        } else {
            let subject = getSubjectToSearchBox(index)
            let isSaved = Subject.searchSubjectInLocal(subject.id)
            return (subject, isSaved)
        }
    }
    
    
    // MARK: - Search method
    public func sendSearchRequest(request: BangumiRequest, searchText: String, _ handler: (NSError?) -> Void) {
        
        if noMoreData {
            handler(NSError(domain: "sendSearchRequest", code: 1, userInfo: nil))
            return
        }
        
        request.getSearchWith(searchText, startIndex: startIndex, resultLimit: limit) { (subjectListData, count, error) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                // error
                handler(error)
                
            } else {
                
                self.startIndex += subjectListData!.count
                self.lastSearchText = searchText
                for subject in subjectListData! {
                    if self.subjectIDList.indexOf(subject.id) == nil {
                        self.subjectIDList.append(subject.id)
                        self.subjectsList[subject.id] = subject
                    }
                }
                
                if (subjectListData!.count + self.startIndex >= count) {
                    // No more data
                    self.noMoreData = true
                }
                
                // success
                handler(nil)
            }   // if error != nil … else
        }
    }

    
}
