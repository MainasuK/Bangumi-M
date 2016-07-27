//
//  DetailTableViewModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

final class DetailTableViewModel: DataProvider {
    
    typealias ItemType = Result<DetailItem>
    typealias Error = ModelError
    
    private let request = BangumiRequest.shared
    
    private var subject: Subject?
    private var progress = Progress()
    private weak var tableView: UITableView?
    
    var isReverse = false
    var isEmpty: Bool {
        return subject == nil
    }
    
    // TODO:
    // Init controller without subject (only subjectID) is necessary
    // In latter condition, manual call the something like fetch subject…
    init(tableView: UITableView, with subject: Subject? = nil) {
        self.tableView = tableView
        self.subject = subject
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
            fetchProgress(of: subject)
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
    
    func markEpisode(at indexPath: IndexPath, to status: Status, handler: (ErrorProtocol?) -> Void) {
        
        guard let item = try? item(at: indexPath).resolve(),
        let episode = item~>^=^ else { return }
        
        NetworkSpinner.on()
        request.ep(of: episode.id, with: nil, of: status) { (error: ErrorProtocol?) in
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
    

    private func fetchProgress(of subject: Subject) {
        consolePrint("Fetch progress of subject: \(subject.name) …")
        // Ture on spinner to giver user hint
        NetworkSpinner.on()
        
        request.progress(of: subject.id) { (result: Result<Progress>) in
            assert(Thread.isMainThread, "Model method should be main thread for thread safe")
            consolePrint("… get progress result of subject: \(subject.name)")
            NetworkSpinner.off()
            do {
                self.progress = try result.resolve()
                self.tableView?.reloadData()
            } catch {
                
            }
        }
    }
    
}

// MARK: - DataProvider
extension DetailTableViewModel {
    
    func numberOfSections() -> Int {
        // No.0     --> Banner cell
        // No.1     --> More topic cell
        // No.2     --> More subject cell
        // No.3...6 --> EPS cell
        return 7
    }
    
    func numberOfItems(in section: Int) -> Int {
        switch section {
        // Banner cell
        case 0: fallthrough
        // More topic cell
        case 1: fallthrough
        // More subject cell
        case 2: return isEmpty ? 0 : 1
        // EP
        case 3:
            // API return 1 ep to muisc type
            guard subject?.type != 3 else { return 0 }
            
            return subject?.epTable.count ?? 0
         // SP
        case 4: return subject?.spTable.count ?? 0
        // OP
        case 5: return subject?.opTable.count ?? 0
        // ED
        case 6: return subject?.edTable.count ?? 0
            
        default: return 0
        }
    }
    
    func item(at indexPath: IndexPath) -> DetailTableViewModel.ItemType {
        
        guard let subject = self.subject else {
            return .failure(Error.noSubject)
        }
        
        switch indexPath.section {
        // Banner cell
        case 0: fallthrough
        // More topic cell
        case 1: fallthrough
        // More subject cell
        case 2: return .success(.subject(subject))
        
        // FIXME: Need clean up
        // Note: Not profiled code. Should keep watch
        // EP
        case 3:
            let episode = (isReverse) ? subject.epTableReversed[indexPath.row] : subject.epTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // SP
        case 4:
            let episode = subject.spTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // OP
        case 5:
            let episode = subject.opTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // ED
        case 6:
            let episode = subject.edTable[indexPath.row]
            let status = progress[episode.id]
            return .success(.episode(episode, status))
            
        // Should never ever goto here
        default: return .failure(Error.noSubject)
        }
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        switch indexPath.section {
        // Banner
        case 0: return StoryboardKey.DetailTableViewBannerCellKey
        // More topic
        case 1: return StoryboardKey.DetailTableViewMoreTopicCellKey
        // More subject
        case 2: return StoryboardKey.DetailTableViewMoreSubjectCellKey
        // EP
        case 3: return StoryboardKey.DetailTableViewEPSCellKey
        // SP
        case 4: return StoryboardKey.DetailTableViewEPSCellKey
        // OP
        case 5: return StoryboardKey.DetailTableViewEPSCellKey
        // ED
        case 6: return StoryboardKey.DetailTableViewEPSCellKey
        
        // Should never ever goto here
        default: return "No identifier for this section: \(indexPath.section)"
        }
    }
        
}

extension DetailTableViewModel {
    
    enum DetailItem {
        case subject(Subject)
        case episode(Episode, Status?)
    }
    
    enum ModelError: ErrorProtocol {
        case noSubject
    }
    
}

postfix operator ~>^=^ { }
postfix operator ~>^*^ { }


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
