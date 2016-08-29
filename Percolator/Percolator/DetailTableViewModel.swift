//
//  DetailTableViewModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

final class DetailTableViewModel: NSObject, DataProvider {
    
    typealias ItemType = Result<DetailItem>
    typealias ErrorType = ModelError
    
    fileprivate let request = BangumiRequest.shared
    
    fileprivate var subject: Subject?
    fileprivate var progress = Progress()
    
    var collectionItems: [(String, [CollectionItem])] {
        var items: [(String, [CollectionItem])] = []
        
        if let crts = subject?.crts, !crts.isEmpty {
            items.append( ("出场人物", crts.map { CollectionItem.crt($0) }) )
        }
        if let staffs = subject?.staffs, !staffs.isEmpty {
            items.append( ("制作人员", staffs.map { CollectionItem.staff($0) }) )
        }
        
        return items
    }
    
    fileprivate weak var tableView: UITableView?
    fileprivate weak var collectionViewDelegate: UICollectionViewDelegate?
    
    var isReverse = false
    var isEmpty: Bool {
        return subject == nil
    }
    
    // TODO:
    // Init controller without subject (only subjectID) is necessary
    // In latter condition, manual call the something like fetch subject…
    init(tableView: UITableView, collectionViewDelegate delegate: UICollectionViewDelegate, with subject: Subject? = nil) {
        self.tableView = tableView
        self.subject = subject
        self.collectionViewDelegate = delegate
    }
    
    deinit {
        consolePrint("DetailTableViewModel deinit")
    }
    
}

extension DetailTableViewModel {
    
    // Will not give user any error alert now due to refetch is automatically called
    func refetch(with subject: Subject) {

        guard subject.responseGroup != .large else {
            consolePrint("Subject-large is already exists")
            
            self.fetchProgress(of: subject)
            
            return
        }
        
        // Ture on spinner to giver user hint
        NetworkSpinner.on()
        request.subject(of: subject.id) { (result: Result<Subject>) in
            assert(Thread.isMainThread, "Model method should be main thread for thread safe")
            
            NetworkSpinner.off()
            do {
                var subject = try result.resolve()
                
                subject.responseGroup = .large
                self.subject = subject
                self.tableView?.reloadData()
                
                self.fetchProgress(of: subject)
            } catch {
                consolePrint("Refetch subject occurred error: \(error)")
            }
        }
    }
    
    func markEpisode(at indexPath: IndexPath, to status: Status, handler: @escaping (Error?) -> Void) {
        
        guard let item = try? item(at: indexPath).resolve(),
        let episode = item~>^=^ else { return }
        
        NetworkSpinner.on()
        request.ep(of: episode.id, with: nil, of: status) { (error: Error?) in
            NetworkSpinner.off()
            
            assert(Thread.isMainThread, "Model method should be main thread for thread safe")
            
            guard error == nil else {
                handler(error)
                return
            }
            
            self.progress[episode.id] = status
            self.tableView?.reloadRows(at: [indexPath], with: .none)
            handler(nil)
        }
    }
    
}

extension DetailTableViewModel {
    
    fileprivate func fetchProgress(of subject: Subject) {
        consolePrint("Fetch progress of subject: \(subject.name) …")
        // Ture on spinner to giver user hint
        NetworkSpinner.on()
        
        request.progress(of: subject.id) { (result: Result<Progress>) in
            assert(Thread.isMainThread, "Model method should be main thread for thread safe")
            consolePrint("… get progress result of subject: \(subject.name)")
            NetworkSpinner.off()
            do {
                let progress = try result.resolve()
                
                // Prevent tableView scrolling lag issue
                DispatchQueue.main.async { [weak self] in
                    self?.progress = progress
                    self?.tableView?.reloadData()
                }
                
            } catch {
                consolePrint(error)
            }
        }
    }
    
}

// MARK: - DataProvider
extension DetailTableViewModel {
    
    func numberOfSections() -> Int {
        // No.0     --> Banner cell
        // No.1     --> Characters + Staff cell
        // No.2     --> More topic cell
        // No.3     --> More subject cell
        // No.4...7 --> EPS cell
        return 8
    }
    
    func numberOfItems(in section: Int) -> Int {
        switch section {
        // Banner cell
        case 0: return isEmpty ? 0 : 1
        // Collection cell
        case 1: return collectionItems.count
        // More topic cell
        case 2: return isEmpty ? 0 : 1
        // More subject cell
        case 3: return isEmpty ? 0 : 1
        // EP
        case 4:
            // API return 1 ep to muisc type
            guard subject?.type != 3 else { return 0 }
            
            return subject?.epTable.count ?? 0
         // SP
        case 5: return subject?.spTable.count ?? 0
        // OP
        case 6: return subject?.opTable.count ?? 0
        // ED
        case 7: return subject?.edTable.count ?? 0
            
        default: return 0
        }
    }
    
    func item(at indexPath: IndexPath) -> DetailTableViewModel.ItemType {
        
        guard let subject = self.subject else {
            return .failure(ErrorType.noSubject)
        }
        
        switch indexPath.section {
        // Banner cell
        case 0: return .success(.subject(subject))
        // Collection cell
        case 1:
            let headline = collectionItems[indexPath.row].0
            let item = DetailItem.collection(self, collectionViewDelegate, headline, indexPath)
            return .success(item)
        // More topic cell
        case 2: return .success(.subject(subject))
        // More subject cell
        case 3: return .success(.subject(subject))
        // FIXME: Not profiled code snip. Should keep watching
        // EP
        case 4:
            let episode = (isReverse) ? subject.epTableReversed[indexPath.row] : subject.epTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // SP
        case 5:
            let episode = subject.spTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // OP
        case 6:
            let episode = subject.opTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // ED
        case 7:
            let episode = subject.edTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // Should never ever goto here
        default: return .failure(ErrorType.noSubject)
        }
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        switch indexPath.section {
        // Banner
        case 0: return StoryboardKey.DetailTableViewBannerCellKey
        // Collection cell
        case 1: return StoryboardKey.DetailTableViewCell_CollectionView
        // More topic
        case 2: return StoryboardKey.DetailTableViewMoreTopicCellKey
        // More subject
        case 3: return StoryboardKey.DetailTableViewMoreSubjectCellKey
        // EP
        case 4: return StoryboardKey.DetailTableViewEPSCellKey
        // SP
        case 5: return StoryboardKey.DetailTableViewEPSCellKey
        // OP
        case 6: return StoryboardKey.DetailTableViewEPSCellKey
        // ED
        case 7: return StoryboardKey.DetailTableViewEPSCellKey
        
        // Should never ever goto here
        default: return "No identifier for this section: \(indexPath.section)"
        }
    }
        
}

extension DetailTableViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems[collectionView.tag].1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryboardKey.CMKCollectionViewCell, for: indexPath) as! CMKCollectionViewCell
        
        let item = (collectionItems[collectionView.tag].1)[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
}

extension DetailTableViewModel {
    
    enum CollectionItem {
        case crt(Crt)
        case staff(Staff)
    }
    
    enum DetailItem {
        case subject(Subject)
        case episode(Episode, Status?)
        case collection(UICollectionViewDataSource, UICollectionViewDelegate?, String, IndexPath)
    }
    
    enum ModelError: Error {
        case noSubject
    }
    
}

// FIXME: Use case let
postfix operator ~>^=^
postfix operator ~>^*^


// Happy coding
postfix func ~>^=^(left: DetailTableViewModel.DetailItem) -> Episode? {
    switch left {
    case .episode(let episode, _):
        return episode
    default:
        return nil
    }
}

postfix func ~>^*^(left: DetailTableViewModel.DetailItem) -> Status? {
    switch left {
    case .episode(_, let status):
        return status
    default:
        return nil
    }
}
