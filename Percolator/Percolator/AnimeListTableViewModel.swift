//
//  AnimeListTableViewModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-17.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

final class AnimeListTableViewModel: DataProvider {
    
    typealias ItemType = (Subject, Result<SubjectHistory>)
    typealias Subjects = BangumiRequest.CollectionSubjects
    typealias Progresses = [SubjectID : Progress]
    
    typealias NetworkError = BangumiRequest.NetworkError
    typealias RequestError = BangumiRequest.RequestError
    typealias ProgressError = BangumiRequest.ProgressError
    
    private let request = BangumiRequest.shared
    
    private weak var tableView: UITableView?
    private var subjects = Subjects()
    private var progresses = Progresses()
    private var progressesStatus: ProgressesStatus = .none
    private var isMarkingStatus = [SubjectID : Bool]()
    
    var isEmpty: Bool {
        return subjects.count == 0
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    deinit {
        consolePrint("AnimeListTableViewModel deinit")
    }
    
}

// MARK: - Refresh
extension AnimeListTableViewModel {
    
    func refresh(handler: (ErrorProtocol?) -> Void) {
        fetchProgresses()
        
        request.userCollection { (result: Result<Subjects>) in
            
            do {
                let subjects = try result.resolve()
                
                // BangumiRequest callback should run in main Queue
                assert(Thread.isMainThread, "Request callback should be main thread")
                self.subjects = subjects
                self.tableView?.reloadData()
                
                handler(nil)
                self.replaceCollection(with: subjects.map { $0.id } )
            
                
            } catch {
                // No model error need to handle
                handler(error)
            }

        }   // end request.userCollection { … }
    }   // end func refresh
    
    func mark(_ episode: Episode, of subject: Subject, handler: (ErrorProtocol?) -> Void) {
        isMarkingStatus[subject.id] = true
        consolePrint("Mark episode: EP.\(episode.sortString) \(episode.name)…")
        request.ep(of: episode.id, with: nil, of: .watched) { (error: ErrorProtocol?) in
            
            assert(Thread.isMainThread, "Model method should be main thread for thread safe")
            self.isMarkingStatus[subject.id] = false
            
            guard error == nil else {
                handler(error)
                self.tableView?.reloadData()
                consolePrint("… fail")
                return
            }
            
            guard let index = self.subjects.index(where: { subject.id == $0.id }) else {
                handler(ModelError.mark)
                self.tableView?.reloadData()
                consolePrint("… fail")
                return
            }
            consolePrint("… success")
            let indexPath = IndexPath(row: index, section: 0)
            if self.progresses[subject.id] == nil {
                self.progresses[subject.id] = [episode.id : .watched]
            } else {
                self.progresses[subject.id]?[episode.id] = .watched
            }
            self.tableView?.reloadRows(at: [indexPath], with: .none)
            handler(nil)
        }
    }
    
}

extension AnimeListTableViewModel {
    
    func removeAll() {
        subjects = Subjects()
        progresses = Progresses()
        progressesStatus = .none
        isMarkingStatus = [SubjectID : Bool]()
        
        tableView?.reloadData()
    }
    
}

extension AnimeListTableViewModel {
    
    private func fetchProgresses() {
        consolePrint("Fetching progresses…")
        progressesStatus = .fetching
        
        request.progresses { (result: Result<Progresses>) in
            consolePrint("… fetched result …")
            
            assert(Thread.isMainThread, "Model method should be main thread for thread safe")
            
            defer {
                self.tableView?.reloadData()
            }
            
            do {
                let progresses = try result.resolve()
                
                self.progresses = progresses
                self.progressesStatus = .fetched
                
            } catch NetworkError.timeout {
                self.progressesStatus = .timeout
                consolePrint("… timeout")
            } catch ProgressError.noProgress {
                self.progressesStatus = .fetched
            } catch {
                self.progressesStatus = .unknownError
                consolePrint("… get unknown error: \(error)")
            }
        }
    }
    
    // Fetch large subject to replace collection version subject
    // Note: Use Alamofire with *cache*
    private func replaceCollection(with subjectIDs: [Int]) {
        subjectIDs.forEach {
            consolePrint("Fetching subject with id: \($0)…")
            request.subject(of: $0) { (result: Result<Subject>) in
                consolePrint("… fetched result …")
                
                assert(Thread.isMainThread, "Model method should be main thread for thread safe")

                do {
                    var subject = try result.resolve()
                    let index = self.subjects.index(where: { $0.id == subject.id } ) ?? -1
                    consolePrint("… with id \(subject.id) at subjects[\(index)]")
                    
                    guard index != -1 else {
                        consolePrint("Subject isn't exists in array. Insert action canceled")
                        return
                    }
                    
                    let indexPath = IndexPath(row: index, section: 0)   // Note: section 0 is first section
                    subject.responseGroup = .large
                    self.subjects[index] = subject
                    self.tableView?.reloadRows(at: [indexPath], with: .none)
                } catch {
                    consolePrint("Fetch subject large get error: \(error)")
                }
            }
        }
    }
}

// MARK: - DataProvider
extension AnimeListTableViewModel {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return subjects.count
    }
    
    func item(at indexPath: IndexPath) -> AnimeListTableViewModel.ItemType {
        guard progressesStatus == .fetched else {
            return (subjects[indexPath.row], .failure(progressesStatus))
        }
        
        guard isMarkingStatus[indexPath.row] != true else {
            return (subjects[indexPath.row], .failure(ProgressesStatus.fetching))
        }
        
        let subject = subjects[indexPath.row]
        
        return (subject, lookupSubjectHistory(for: subject))
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        return StoryboardKey.AnimeListTableViewCellKey
    }
    
}

extension AnimeListTableViewModel {
    
    // Compute the subject history
    private func lookupSubjectHistory(for subject: Subject) -> Result<SubjectHistory> {
        guard progressesStatus == .fetched else {
            return .failure(progressesStatus)
        }
        
        guard let progress = progresses[subject.id] else {
            // No progress exists
            return .success(SubjectHistory(lastEpisode: nil, nextEpisode: subject.epTable.first))
        }
        
        let lastTouchEpisode: Episode? = {
            var episode: Episode?
            for ep in subject.epTable { // Wow~ epTable in order
                if progress[ep.id] == .watched { episode = ep }
            }
            
            return episode
        }()
        
        let nextMarkEpisode: Episode? = {
            guard let lastEpisodeSort = lastTouchEpisode?.sort else {
                return subject.epTable.first
            }
            
            for ep in subject.epTable {
                if ep.sort > lastEpisodeSort { return ep }
            }
            
            return nil
        }()
        
        return .success(SubjectHistory(lastEpisode: lastTouchEpisode, nextEpisode: nextMarkEpisode))
    }
    
    struct SubjectHistory {
        let lastEpisode: Episode?
        let nextEpisode: Episode?
    }
    
    enum ProgressesStatus: ErrorProtocol {
        case none
        case fetching
        case fetched        // Not error, sorry
        case timeout
        case unknownError
    }
    
}

extension AnimeListTableViewModel {

    enum ModelError: ErrorProtocol {
        case mark
    }

}
