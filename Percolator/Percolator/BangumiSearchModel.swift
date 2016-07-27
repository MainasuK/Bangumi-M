//
//  BangumiSearchModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-12.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

public class BangumiSearchModel {
    
    let request = BangumiRequest.shared
    let kLimit = 10
    
    // # warning
    // UITableView and ArrayDataSource reference
    // Break program immediately if not set in controller
    var tableView: UITableView!
    var subjectDataSource: ArrayDataSource<Subject, SearchBoxTableViewCell>!
    
    private var subjectsIDArray = [Int]()
    private var startIndex = 0
    private var lastSearchText = ""
    private var noMoreData = false

    // - MARK: Singleton
    private static let instance = BangumiSearchModel()
    
    private init() {
    }
    
    public static var shared: BangumiSearchModel {
        return self.instance
    }

    // MARK: - Model method
    public func dropModel() {
        startIndex = 0
        lastSearchText = ""
        noMoreData = false
        subjectsIDArray = [Int]()
        
        self.subjectDataSource.clean()
        // FIXME: Never ever do this
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    public func count() -> Int {
        return subjectsIDArray.count
    }

//    private func getSubjectToSearchBox(index: Int) -> AnimeSubject {
//        return self.subjectsList[self.subjectIDList[index]]!
//    }
//    
//    // FIXME:
//    public func getSubjectAndSavedInfoToSearchBox(index: Int, _ isSearching: Bool) -> (subject: AnimeSubject, isSaved: Bool) {
//        
//        if !isSearching {
//            return (subjectLocalList[index], true)
//        } else {
//            let subject = getSubjectToSearchBox(index)
//            let isSaved = Subject.searchSubjectInLocal(subject.id)
//            return (subject, isSaved)
//        }
//    }
//    
//    
    

}




