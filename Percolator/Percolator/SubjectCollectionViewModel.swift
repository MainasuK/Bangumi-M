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
import IGListKit
import SVProgressHUD

final class SubjectCollectionViewModel: NSObject {
    
    typealias ItemType = (SubjectItem, Result<CollectInfoSmall>)
    typealias CollectDict = BangumiRequest.CollectDict
    typealias headerItemType = String
    
    fileprivate let request = BangumiRequest.shared
    
    fileprivate var bookSubjectItems = [SubjectItem]()
    fileprivate var otherSubjectSectionName = [String]()
    fileprivate var otherSubjectItems = [[SubjectItem]]()

    private var bookSectionItem: ListDiffable {
        let title = bookSubjectItems.count != 0 ? "单行本" : ""
        return SectionItem(of: bookSubjectItems, type: .book, headerTitle: title)
    }
    private var notBookSectionItems: [ListDiffable] {
        var items = [ListDiffable]()
        for (i, item) in otherSubjectItems.enumerated() {
            let title = otherSubjectSectionName[i]
            items.append(SectionItem(of: item, type: .notBook, headerTitle: title))
        }

        return items
    }
    
    fileprivate var collectDict: CollectDict = [:]
    
    private weak var collectionView: UICollectionView?
    private let adapter: ListAdapter
    private let subject: Subject
    
    init(collectionView: UICollectionView, of adapter: ListAdapter, with subject: Subject) {
        self.collectionView = collectionView
        self.adapter = adapter
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

                self.adapter.performUpdates(animated: true, completion: nil)

                self.fetchCollectInfo(for: self.bookSubjectItems.flatMap { $0.urlPath.components(separatedBy: "/").last }.flatMap { Int($0) })
                
                if self.bookSubjectItems.isEmpty && self.otherSubjectItems.isEmpty {
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

    final class SectionItem: NSObject, ListDiffable {
        enum SubjectType {
            case book
            case notBook
        }

        let items: [SubjectItem]
        let type: SubjectType
        let headerTitle: String

        init(of items: [SubjectItem], type: SubjectType, headerTitle: String) {
            self.items = items
            self.type  = type
            self.headerTitle = headerTitle
        }

        func diffIdentifier() -> NSObjectProtocol {
            return self
        }

        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            assert(object is SectionItem)
            guard let wrapper = object as? SectionItem else { return false }
            return self === wrapper ? true : self.isEqual(object)
        }
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
                let style = lastSpanNode["style"] {
                    
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
            
            bookSubjectItems = items
        }   // end if let section …
    }
    
    fileprivate func parseOther(with bodyNode: XMLElement) {
        if let section = bodyNode.at_xpath("//div[@class='content_inner']") {

            var sub = ""
            var itemsName: [String] = []
            var itemsArray: [[SubjectItem]] = []
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
            otherSubjectItems = itemsArray
        }   // if let section …
    }

}

extension SubjectCollectionViewModel: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var diffables = [ListDiffable]()

        diffables.append(bookSectionItem)
        diffables.append(contentsOf: notBookSectionItems)

        return diffables
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let item = object as? SectionItem else {
            fatalError()
        }

        switch item.type {
        case .book:     return SubjectCollectionViewBookSectionController()
        case .notBook:  return SubjectCollectionViewNotBookSectionController()
        }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

// MARK: - SubjectCollectionViewBookSectionController
final class SubjectCollectionViewBookSectionController: ListSectionController {

    typealias ModelError   = SubjectCollectionViewModel.ModelError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias HTMLError    = BangumiRequest.HTMLError
    typealias UnknownError = BangumiRequest.Unknown

    private var item: SubjectCollectionViewModel.SectionItem?

    override init() {
        super.init()
        minimumInteritemSpacing = 1
        minimumLineSpacing      = 1
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        supplementaryViewSource = self
    }

    override func numberOfItems() -> Int {
        return item?.items.count ?? 0
    }

    override func sizeForItem(at index: Int) -> CGSize {
        if let traitCollection = viewController?.traitCollection, traitCollection.horizontalSizeClass == .compact {
            return CGSize(width: collectionContext!.containerSize.width - inset.left - inset.right, height: 66.0)
        } else {
            return CGSize(width: (collectionContext!.containerSize.width - inset.left - inset.right - minimumInteritemSpacing) * 0.5, height: 66.0)
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(withNibName: "SubjectCollectionViewBookCell", bundle: nil, for: self, at: index) as! SubjectCollectionViewBookCell

        let subject = item?.items[index]
        cell.configure(with: (subject!, Result.failure(ModelError.noItem)))

        return cell
    }

    override func didUpdate(to object: Any) {
        assert(object is SubjectCollectionViewModel.SectionItem)
        guard let item = object as? SubjectCollectionViewModel.SectionItem else { return }
        self.item = item
    }

    override func didSelectItem(at index: Int) {
        guard let count = item?.items.count, index < count,
            let subjectItem = item?.items[index] else {
                return
        }

        guard let subjectIDStr = subjectItem.urlPath.components(separatedBy: "/").last,
            let subjectID = Int(subjectIDStr) else {
                // FIXME: Watch out API change
                return
        }

        SVProgressHUD.show()
        BangumiRequest.shared.subject(of: subjectID, with: .large) { [weak self] (result: Result<Subject>) in

            do {
                let subject = try result.resolve()

                let detailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.DetialViewControllerKey) as! DetailViewController
                detailTableViewController.subject = subject
                SVProgressHUD.dismiss()

                self?.viewController?.navigationController?.pushViewController(detailTableViewController, animated: true)

            } catch UnknownError.API(let error, let code) {
                let title = NSLocalizedString("server error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("API error: \(error), code: \(code)")

            } catch NetworkError.timeout {
                let status = NSLocalizedString("time out", comment: "")
                SVProgressHUD.showInfo(withStatus: status)
                consolePrint("Timeout")

            } catch NetworkError.notConnectedToInternet {
                let title = NSLocalizedString("not connected to internet", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)

            } catch UnknownError.alamofire(let error) {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error.localizedDescription)")
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("Unknow NSError: \(error)")

            } catch UnknownError.network(let error) {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "NSURLError", code: error.code.rawValue)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("Unknow NSURLError: \(error)")

            } catch {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("Unresolve case: \(error)")
            }   // end do-catch block
        }   // end BangumiRequest…
    }

}

// MARK: - ListSupplementaryViewSource
extension SubjectCollectionViewBookSectionController: ListSupplementaryViewSource {

    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        let header = collectionContext?.dequeueReusableSupplementaryView(fromStoryboardOfKind: UICollectionElementKindSectionHeader, withIdentifier: StoryboardKey.SubjectCollectionViewHeaderView, for: self, at: index) as! SubjectCollectionReusableHeaderView

        let title = item?.headerTitle ?? ""
        header.configure(with: title)

        return header
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        guard item?.headerTitle != "" else {
            return CGSize.zero
        }

        return CGSize(width: collectionContext!.containerSize.width, height: 44.0)
    }

}

// MARK: - SubjectCollectionViewNotBookSectionController
final class SubjectCollectionViewNotBookSectionController: ListSectionController {

    typealias ModelError   = SubjectCollectionViewModel.ModelError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias HTMLError    = BangumiRequest.HTMLError
    typealias UnknownError = BangumiRequest.Unknown

    private var item: SubjectCollectionViewModel.SectionItem?

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 10, bottom: 8, right: 10)
        supplementaryViewSource = self
    }

    override func numberOfItems() -> Int {
        return item?.items.count ?? 0
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 96.0, height: 180.0)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(withNibName: "SubjectCollectionViewNotBookCell", bundle: nil, for: self, at: index) as! SubjectCollectionViewNotBookCell

        let subject = item?.items[index]
        cell.configure(with: (subject!, Result.failure(ModelError.noItem)))

        return cell
    }

    override func didUpdate(to object: Any) {
        assert(object is SubjectCollectionViewModel.SectionItem)
        guard let item = object as? SubjectCollectionViewModel.SectionItem else { return }
        self.item = item
    }

    override func didSelectItem(at index: Int) {
        guard let count = item?.items.count, index < count,
        let subjectItem = item?.items[index] else {
            return
        }

        guard let subjectIDStr = subjectItem.urlPath.components(separatedBy: "/").last,
        let subjectID = Int(subjectIDStr) else {
            // FIXME: Watch out API change
            return
        }

        SVProgressHUD.show()
        BangumiRequest.shared.subject(of: subjectID, with: .large) { [weak self] (result: Result<Subject>) in

            do {
                let subject = try result.resolve()

                let detailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.DetialViewControllerKey) as! DetailViewController
                detailTableViewController.subject = subject
                SVProgressHUD.dismiss()

                self?.viewController?.navigationController?.pushViewController(detailTableViewController, animated: true)

            } catch UnknownError.API(let error, let code) {
                let title = NSLocalizedString("server error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("API error: \(error), code: \(code)")

            } catch NetworkError.timeout {
                let status = NSLocalizedString("time out", comment: "")
                SVProgressHUD.showInfo(withStatus: status)
                consolePrint("Timeout")

            } catch NetworkError.notConnectedToInternet {
                let title = NSLocalizedString("not connected to internet", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)

            } catch UnknownError.alamofire(let error) {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error.localizedDescription)")
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("Unknow NSError: \(error)")

            } catch UnknownError.network(let error) {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "NSURLError", code: error.code.rawValue)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("Unknow NSURLError: \(error)")

            } catch {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
                SVProgressHUD.dismiss()
                self?.viewController?.present(alertController, animated: true, completion: nil)
                consolePrint("Unresolve case: \(error)")
            }   // end do-catch block
        }   // end BangumiRequest…
    }

}

// MARK: - ListSupplementaryViewSource
extension SubjectCollectionViewNotBookSectionController: ListSupplementaryViewSource {

    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        let header = collectionContext?.dequeueReusableSupplementaryView(fromStoryboardOfKind: UICollectionElementKindSectionHeader, withIdentifier: StoryboardKey.SubjectCollectionViewHeaderView, for: self, at: index) as! SubjectCollectionReusableHeaderView

        let title = item?.headerTitle ?? ""
        header.configure(with: title)

        return header
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        guard item?.headerTitle != "" else {
            return CGSize.zero
        }

        return CGSize(width: collectionContext!.containerSize.width, height: 44.0)
    }

}
