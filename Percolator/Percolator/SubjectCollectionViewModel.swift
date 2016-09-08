//
//  SubjectCollectionViewModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-24.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

final class SubjectCollectionViewModel: DataProvider, HeaderDataProvider {
    
    typealias ItemType = (SubjectItem, Result<CollectInfoSmall>)
    typealias CollectDict = BangumiRequest.CollectDict
    typealias headerItemType = String
    
    fileprivate let request = BangumiRequest.shared
    
    fileprivate var bookSubjectItem = [SubjectItem]()
    fileprivate var otherSubjectSectionName = [String]()
    fileprivate var otherSubjectItem = [[SubjectItem]]()
    
    fileprivate var collectDict: CollectDict = [:]
    
    fileprivate weak var collectionView: UICollectionView?
    fileprivate let subject: Subject
    
    init(collectionView: UICollectionView, with subject: Subject) {
        self.collectionView = collectionView
        self.subject = subject
    }
    
    deinit {
        consolePrint("SubjectCollectionViewModel deinit")
    }
    
}

extension SubjectCollectionViewModel {
    
    func fetchRelatedSubjects(handler: @escaping (Error?) -> Void) {
        let url = "https://bgm.tv/subject/\(subject.id)"
    
        request.html(from: url) { (result: Result<String>) in
            assert(Thread.isMainThread, "Request callback should be main thread")
            
            do {
                let html = try result.resolve()
                guard let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8),
                let bodyNode = doc.body else {
                    handler(ModelError.parse)
                    return
                }
                
                self.parseBook(with: bodyNode)
                self.parseOther(with: bodyNode)
                
                self.collectionView?.reloadData()
                
                self.fetchCollectInfo(for: self.bookSubjectItem.flatMap { $0.urlPath.components(separatedBy: "/").last }.flatMap { Int($0) })
                
                if self.bookSubjectItem.isEmpty && self.otherSubjectItem.isEmpty {
                    handler(ModelError.noItem)
                } else {
                    handler(nil)
                }
                
            } catch {
                handler(error)
            }
        }
    }
    
}

extension SubjectCollectionViewModel {
    
    typealias CollectionError = BangumiRequest.CollectionError
    
    fileprivate func fetchCollectInfo(for subjectIDs: [SubjectID]) {
        request.collection(of: subjectIDs) { (result: Result<CollectDict>) in
            assert(Thread.isMainThread, "Request callback should be main thread")
            
            do {
                let dict = try result.resolve()
                dict.forEach { (key: SubjectID, value: CollectInfoSmall) in
                    self.collectDict[key] = value
                }
                
                self.collectionView?.reloadData()
                
            } catch CollectionError.noCollection {
                consolePrint("No collect info")
            } catch {
                // Jush print it
                consolePrint(error)
            }
        }
    }
    
}

// MARK: - DataProvider
extension SubjectCollectionViewModel {
    
    func numberOfSections() -> Int {
        // Book + other subject section. And otherSubjectItem has an *empty* item at [0]
        return otherSubjectItem.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        switch section {
        case 0:         return bookSubjectItem.count
        default:        return otherSubjectItem[section].count
        }
    }
    
    func item(at indexPath: IndexPath) -> SubjectCollectionViewModel.ItemType {
        switch indexPath.section {
        case 0:
            let subjectItem = bookSubjectItem[indexPath.row]
            if let idStr = subjectItem.urlPath.components(separatedBy: "/").last,
            let id = Int(idStr),
            let collect = collectDict[id] {
                return (subjectItem, .success(collect))
            } else {
                return (subjectItem, .failure(ModelCollectError.unknown))
            }
        default:
            return (otherSubjectItem[indexPath.section][indexPath.row], .failure(ModelCollectError.unknown))
        }
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        switch indexPath.section {
        case 0:         return StoryboardKey.SubjectCollectionViewBookCellKey
        default:        return StoryboardKey.SubjectCollectionViewNotBookCellKey
        }
    }
    
}

extension SubjectCollectionViewModel {
    
    func headerItem(at indexPath: IndexPath) -> headerItemType {
        switch indexPath.section {
        case 0:
            return (bookSubjectItem.isEmpty) ? "" : "单行本"
        default:
            return otherSubjectSectionName[indexPath.section]
        }
    }
    
    func headerIdentifier(at indexPath: IndexPath) -> String {
        return StoryboardKey.SubjectCollectionViewHeaderView
    }
}

extension SubjectCollectionViewModel {
    
    enum ModelError: Error {
        case parse
        case noItem
    }

}
extension SubjectCollectionViewModel {
    
    // Parse web page to get its
    struct SubjectItem {
        let title: String
        let subtitle: String
        let urlPath: String
        let coverUrlPath: String
    }
    
    enum ModelCollectError: Error {
        case unknown
    }
}

extension SubjectCollectionViewModel {
    
    fileprivate func parseBook(with bodyNode: XMLElement) {
        if let section = bodyNode.at_xpath("//ul[@class='browserCoverSmall clearit']") {

            var items: [SubjectItem] = []

            for node in section.css("li") {
                
                if case let XPathObject.NodeSet(nodeset) = node.css("a[href]"),
                case let XPathObject.NodeSet(aNodeset) = node.css("span[class]"),
                let hrefNode = nodeset.first,
                let lastSpanNode = aNodeset.last,
                let href = hrefNode["href"],
                let title = hrefNode["title"],
                let style = lastSpanNode["style"]
                {
                    
                    let urlPath = "http://bgm.tv" + href
                    var imgUrlPath = "http:"
                    
                    for substring in style.components(separatedBy: "('") {
                        if substring.hasSuffix("')") {
                            imgUrlPath += substring.components(separatedBy: "')").first!
                        }
                    }
                    
                    let item = SubjectItem(title: title, subtitle: "", urlPath: urlPath, coverUrlPath: imgUrlPath)
                    items.append(item)

                } else {
                    continue
                }
                
                // consolePrint(section.toHTML)
            }
            
            bookSubjectItem = items
        }   // end if let section …
    }
    
    fileprivate func parseOther(with bodyNode: XMLElement) {
        if let section = bodyNode.at_xpath("//div[@class='content_inner']") {

            var sub = ""
            var itemsName: [String] = [""]
            var itemsArray: [[SubjectItem]] = [[]]
            var items: [SubjectItem] = []

            for node in section.css("li") {

                // The second loop will trigger the append sub
                if case let XPathObject.NodeSet(aNodeset) = node.css("span[class]") {
                    let currentSub = aNodeset.first?.text ?? ""
                    if currentSub != "" {
                        if !items.isEmpty {
                            itemsName.append(sub)
                            itemsArray.append(items)
                            items.removeAll()
                        }
                        sub = currentSub
                    }
                }

                if case let XPathObject.NodeSet(nodeset) = node.css("a[href]"),
                case let XPathObject.NodeSet(aNodeset) = node.css("span[class]"),
                let firstHrefNode = nodeset.first,
                let secondHrefNode = nodeset.last,
                let lastSpanNode = aNodeset.last,
                let secondHref = secondHrefNode["href"],
                let secondTitle = secondHrefNode.text,
                let style = lastSpanNode["style"] {
                    
                    let firstTitle = firstHrefNode["title"] ?? ""
                    let urlPath = "http://bgm.tv" + secondHref
                    var imgUrlPath = "http:"
    
                    for substring in style.components(separatedBy: "('") {
                        if substring.hasSuffix("')") {
                            imgUrlPath += substring.components(separatedBy: "')").first!
                            break
                        }
                    }
                    
                    let item = SubjectItem(title: secondTitle, subtitle: firstTitle, urlPath: urlPath, coverUrlPath: imgUrlPath)
                    items.append(item)

                } else {
                    continue
                }
                
                // print(node.toHTML)
            }   // for node in section.css(…)

            if !items.isEmpty {
                itemsName.append(sub)
                itemsArray.append(items)
            }
            
            otherSubjectSectionName = itemsName
            otherSubjectItem = itemsArray
        }   // if let section …
    }

}
