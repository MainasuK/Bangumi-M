//
//  TopicTableViewModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-25.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//


import UIKit
import Alamofire
import Kanna

final class TopicTableViewModel: DataProvider {
    
    typealias ItemType = TopicItem
    typealias headerItemType = String
    
    private let request = BangumiRequest.shared
    private let subject: Subject
    
    private var topics: [TopicItem] = []
    private weak var tableView: UITableView?
    
    
    init(tableView: UITableView, with subject: Subject) {
        self.tableView = tableView
        self.subject = subject
    }
    
    deinit {
        consolePrint("TopicTableViewModel deinit")
    }
    
}

extension TopicTableViewModel {
    
    func fetchTopics(handler: (Error?) -> Void) {
        let url = "http://bgm.tv/subject/\(subject.id)/board"
        
        request.html(from: url) { (result: Result<String>) in
            
            do {
                let html = try result.resolve()
                guard let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8),
                    let bodyNode = doc.body else {
                        handler(ModelError.parse)
                        return
                }
                
                self.parseTopic(with: bodyNode)
                
                self.tableView?.reloadData()
                if self.topics.isEmpty {
                    handler(ModelError.noItem)
                } else {
                    handler(nil)
                }
                
            } catch {
                handler(error)
            }
            
        }   // end request
    }
    
}

// MARK: - DataProvider
extension TopicTableViewModel {
    
    func numberOfSections() -> Int {
        // TODO: Need add **blog** ???
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return topics.count
    }
    
    func item(at indexPath: IndexPath) -> TopicTableViewModel.ItemType {
        return topics[indexPath.row]
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        return StoryboardKey.TopicTableViewCellKey
    }
    
}

extension TopicTableViewModel {
    
    enum ModelError: Error {
        case parse
        case noItem
    }
    
}
extension TopicTableViewModel {
    
    // Parse web page to get its
    struct TopicItem {
        let title: String
        let userName: String
        let urlPath: String
        let uid: String
        let replies: Int
        let dateStr: String
    }
    
}

extension TopicTableViewModel {
    
    private func parseTopic(with bodyNode: XMLElement) {
        var items = [TopicItem]()
        if let table = bodyNode.at_xpath("//table[@class='topic_list']") {
            
            for row in table.css("tr") {   // row
                var urlPath = "https://bgm.tv/"
                var title = ""
                var uid = ""
                var userName = ""
                var replies = 0
                var date = ""
                
                for (i, node) in row.css("td").enumerated() {   // col
                    switch i {
                    case 0:
                        if case let XPathObject.NodeSet(nodeset) = node.css("a[href]"),
                            let hrefNode = nodeset.first,
                            let href = hrefNode["href"],
                            let text = node.text {
                            urlPath += href
                            title = text
                        }
                        
                    case 1:
                        if case let XPathObject.NodeSet(nodeset) = node.css("a[href]"),
                            let hrefNode = nodeset.first,
                            let href = hrefNode["href"],
                            let lastSplitOfHref = href.components(separatedBy: "/").last,
                            let text = hrefNode.text {
                            uid = lastSplitOfHref
                            userName = text
                        }
                        
                    case 2:
                        if let text = node.text,
                            let repliesStr = text.components(separatedBy: " ").first,
                            let repliesInt = Int(repliesStr) {
                            replies = repliesInt
                        }
                        
                    case 3:
                        if let text = node.text {
                            date = text
                        }
                        
                    default:
                        break
                    }
                }   // end col
                
                let item = TopicItem(title: title, userName: userName, urlPath: urlPath, uid: uid, replies: replies, dateStr: date)
                items.append(item)
            }   // end row
        }   // end if let table …
        
        topics = items
    }
    
}
