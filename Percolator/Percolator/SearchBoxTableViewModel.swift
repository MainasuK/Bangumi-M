//
//  SearchBoxTableViewModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData

final class SearchBoxTableViewModel: DataProvider {
    
    typealias ItemType = (Subject, Result<CollectInfoSmall>)
    typealias CollectDict = BangumiRequest.CollectDict
    
    private weak var tableView: UITableView?
    
    private let request = BangumiRequest.shared
    private weak var context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.context
    private let kLimit = 10
    
    private var items = [Subject]()
    private lazy var localItems: [Subject] = {
        let fetchRequest: NSFetchRequest<CDSubject> = CDSubject.fetchRequest()
        
        guard let context = self.context,
        let cdSubjects = try? context.fetch(fetchRequest) else {
            return []
        }

        return cdSubjects.map { $0.toSubject() }.reversed()
    }()
    private var collectDict: CollectDict = [:]

    private var subjectsIDArray = [Int]()
    private var startIndex = 0
    private var lastSearchText = ""
    private var noMoreData = false
    private var lastSearchType = 0
    
    /// Change it to true only. Never ever to false
    private(set) var isSearching = false {
        didSet {
            if oldValue == false {
                // Prevent view not refresh
                tableView?.reloadData()
            }
        }
    }
    
    var isEmpty: Bool {
        return items.isEmpty && localItems.isEmpty
    }
    
    private var count: Int {
        return items.count
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    deinit {
        consolePrint("SearchBoxTableViewModel deinit")
    }
    
}

extension SearchBoxTableViewModel {
    
    typealias Subjects = (Int, [Subject])
    typealias SearchError = BangumiRequest.SearchError
    typealias AlamofireError = BangumiRequest.AlamofireError

    
    func removeAll() {
        self.startIndex = 0
        self.lastSearchText = ""
        self.noMoreData = false
        self.subjectsIDArray.removeAll()
        self.items.removeAll()
        self.lastSearchType = 0
        
        self.tableView?.reloadData()
    }
    
    // MARK: - Search method
    func search(for keywords: String, type searchType: Int, handler: (Error?) -> Void)  {
        isSearching = true
        tableView?.reloadData()
        
        if lastSearchText != keywords || searchType != lastSearchType {
            removeAll()
        }
        
        guard !noMoreData else {
            handler(ModelError.noMoreData)
            return
        }
        
        request.search(for: keywords, startIndex: startIndex, resultLimit: kLimit, type: searchType) { (result: Result<Subjects>) in
    
            do {
                let (total, subjects) = try result.resolve()
                
                if subjects.count + self.startIndex >= total || subjects.isEmpty {
                    self.noMoreData = true  // No more data
                }
                
                // Makeuser no duplicate
                let uniqueID = subjects.map { $0.id }.filter { !self.subjectsIDArray.contains($0) }
                let uniqueSubjects = subjects.filter { uniqueID.contains($0.id) }
                
                self.startIndex += subjects.count
                self.lastSearchText = keywords
                self.lastSearchType = searchType
                
                // BangumiRequest callback should run in main Queue
                assert(Thread.isMainThread, "Request callback should be main thread")
                self.subjectsIDArray.append(contentsOf: uniqueID)
                self.items.append(contentsOf: uniqueSubjects)
                self.tableView?.reloadData()
                
                self.fetchCollectInfo(for: uniqueID)
                
                handler(nil)
                
            } catch SearchError.notFound {
                if self.isEmpty {
                    handler(ModelError.noResult)
                }
            } catch AlamofireError.contentTypeValidationFailed {
                handler(ModelError.needRetry)
            } catch {
                handler(error)
            }
        }
    }
    
}

extension SearchBoxTableViewModel {
    
    typealias CollectionError = BangumiRequest.CollectionError
    
    private func fetchCollectInfo(for subjectIDs: [SubjectID]) {
        request.collection(of: subjectIDs) { (result: Result<CollectDict>) in
            do {
                let dict = try result.resolve()
                dict.forEach { (key: SubjectID, value: CollectInfoSmall) in
                    self.collectDict[key] = value
                }
                
                self.tableView?.reloadData()
                
            } catch CollectionError.noCollection {
                consolePrint("No collect info")
            } catch {
                // Jush print it
                consolePrint(error)
            }
        }
    }
    
}

extension SearchBoxTableViewModel {
    
    /// Remove item at indexPath from Core Data
    func removeItem(at indexPath: IndexPath) -> Bool {
        let (item, _) = self.item(at: indexPath)
        let isSuccess = item.deleteFromCoreData()
        if let index = (localItems.index { $0.id == item.id }) {
            localItems.remove(at: index)
        }
        if isSearching {
            tableView?.reloadRows(at: [indexPath], with: .fade)
        } else {
            tableView?.deleteRows(at: [indexPath], with: .left)
        }
        
        return isSuccess
    }
    
}

// MARK: - DataProvider
extension SearchBoxTableViewModel {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return isSearching ? items.count : localItems.count
    }
    
    func item(at indexPath: IndexPath) -> SearchBoxTableViewModel.ItemType {
        let subject = isSearching ? items[indexPath.row] : localItems[indexPath.row]
        if let collect = collectDict[subject.id] {
            return (subject, .success(collect))
        } else {
            return (subject, .failure(ModelCollectError.unknown))
        }
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        return StoryboardKey.SearchBoxTableViewCellKey
    }
    
}

// MARK: - Error
/// Controller must handle model error
extension SearchBoxTableViewModel {
    
    enum ModelError: Error {
        case noMoreData
        case needRetry
        case noResult
    }
    
    enum ModelCollectError: Error {
        case unknown
    }
    
}
