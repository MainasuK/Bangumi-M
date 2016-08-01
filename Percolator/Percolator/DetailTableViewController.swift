//
//  DetailTableViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import AlamofireImage
import SafariServices
import SVProgressHUD


// I change tableView contentInset to make some space for tableViewHeaderView,
// but it stick the section headerView in the middle of screen.
// So, use a subclass of *tableView* to solve that issue.
final class DetailTableViewController: UITableViewController {
    
    typealias Model = DetailTableViewModel
    typealias Cell = DetailTableViewCell
    
    private let kHeaderViewMaxHeight: CGFloat = 500
    
    var subject: Subject!
    private var headerViewHeight: CGFloat = 0 {
        didSet {
            headerViewHeight = min(headerViewHeight, kHeaderViewMaxHeight)
            headerView.frame.size.height = headerViewHeight
        }
    }
    private var headerViewMarginTop: CGFloat = 64
    private var model: Model!
    private var dataSource: TableViewDataSource<Model, Cell>!
    
    @IBOutlet var detailTableView: DetailTableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBAction func actionBarButtonItemPressed(_ sender: UIBarButtonItem) {
        var objectToShare: [AnyObject] = ["\(subject.name) - \(subject.nameCN)"]
        if let url = URL(string: subject.url) {
            objectToShare.append(url)
        }
        if let image = headerImageView.image {
            objectToShare.append(image)
        }
        objectToShare.append(SubjectWrapper(with: subject))

        let saveActivity = SaveActivity()
        let deleteActivity = DeleteActivity()
        let activityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: [saveActivity, deleteActivity])
        let poc = activityViewController.popoverPresentationController
        poc?.barButtonItem = sender
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func swipeRestureTrigger(_ sender: UISwipeGestureRecognizer) {
        model.isReverse = !model.isReverse
        tableView.reloadData()
    }
    
    @IBAction func longPressGrestureTrigger(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            guard let cellIndexPath = tableView.indexPathForRow(at: sender.location(in: tableView)),
            let tableViewCell = tableView.cellForRow(at: cellIndexPath) as? DetailTableViewCell_CollectionView,
            let collectionIndexPath = tableViewCell.collectionView.indexPathForItem(at: sender.location(in: tableViewCell.collectionView)),
            case let Model.CollectionItem.crt(crt) = (model.collectionItems[tableViewCell.collectionView.tag].1)[collectionIndexPath.row],
            let actorID = crt.actors.first?.id,
            let url = URL(string: "http://bangumi.tv/m/topic/prsn/\(actorID)") else {
                return
            }
            
            present(SFSafariViewController(url: url), animated: true, completion: nil)

        default:
            return
        }
        
    }
    
    
    
    private func resetHeaderViewHeight() {
        guard let image = headerImageView.image else {
            headerViewHeight = 0
            return
        }
        
        // Set image height to Header with keeping aspect ratio 
        // And make sure height not larger than kHeaderViewMaxHeight
        let height = ((tableView.bounds.width / image.size.width) * image.size.height)
        headerViewHeight = (height > image.size.height) ? image.size.height : height
    }
    
    private func updateHeaderView() {
        var headerRect = CGRect(x: 0.0, y: -headerViewHeight, width: tableView.bounds.width, height: headerViewHeight)
        let y = tableView.contentOffset.y + headerViewMarginTop
        
        if y <= -headerViewHeight {
            headerRect.origin.y = y
            headerRect.size.height = -y     // Stretch view height without change headerViewHeight
        }
        
        headerView.frame = headerRect
    }
    
    
    
    // Model build method
    // FIXME: If view controller push from a detail view controller,
    // the animeDetail is not need to fetch (again).
    // I think the cache will handle it. Maybe fix it is better…
//    func initFromSearchBox(request: BangumiRequest, _ subject: AnimeSubject) {
//        var flag = 0
//        var animeDetail = AnimeDetailLarge()
//        var subjectStatus = SubjectItemStatus()
//        
//        // TODO: add spinner? It's speed is enough, I think.
//        
//        // FIXME: how to make async concurrent possible? GDC or NSOperation?
//        
//        // Task 1
//        print("@ DetailTableViewController: initnVC, step 1…")
//        request.getSubjectDetailLarge(subject.id) { (animeDetailLarge) -> Void in
//
//            if let _animeDetail = animeDetailLarge {
//                debugPrint("@ DetailTableViewController: step 1 success")
//                animeDetail = _animeDetail
//                flag += 1
//                
//                if flag == 2 {
//                    self.detailSource.appendSubject(animeDetail)
//                    self.detailSource.gridStatusTable = GridStatus(epsDict: animeDetail.eps.eps)
//                    self.detailSource.animeDetailLarge = animeDetail
//                    self.detailSource.subjectStatusDict = subjectStatus
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.reloadDataSourceSection()
//                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                    })
//                }
//            }
//        }
//        
//        // Task 2
//        debugPrint("@ DetailTableViewController: initnVC, step 2…")
//        request.getSubjectStatus(subject.id) { (subjectItemStatus) -> Void in
//            debugPrint("@ DetailTableViewController: step 2 success")
//            subjectStatus = subjectItemStatus
//            flag += 1
//            
//            if flag == 2 {
//                self.detailSource.appendSubject(animeDetail)
//                self.detailSource.gridStatusTable = GridStatus(epsDict: animeDetail.eps.eps)
//                self.detailSource.animeDetailLarge = animeDetail
//                self.detailSource.subjectStatusDict = subjectStatus
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.reloadDataSourceSection()
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                })
//            }
//            
//        }
//        
//    }
}

// MARK: - Related subject fetch & display
extension DetailTableViewController {

    
//
    private func pushToNewDetailTableViewController(_ id: String) {
//        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.DetialVC) as! DetailTableViewController
//        let request = BangumiRequest.shared
//        
//        self.tableView.userInteractionEnabled = false
//        self.pleaseWait()
//        
//        request.getSubjectDetailLarge(Int(id) ?? 0) { (detail: AnimeDetailLarge?) -> Void in
//            
//            self.clearAllNotice()
//            self.tableView.userInteractionEnabled = true
//            
//            guard let detail = detail else {
//                self.noticeInfo("Error 53", autoClear: true, autoClearTime: 3)
//                return
//            }
//            
//            let subject = AnimeSubject(animeDetailLarge: detail)
//            detailVC.animeItem = Anime(subject: subject)
//            detailVC.animeSubject = subject
//            detailVC.detailSource = BangumiDetailSource()
//            
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                self.navigationController?.pushViewController(detailVC, animated: true)
//                // The cache will handle the duple request, hopefully
//                detailVC.initFromSearchBox(request, subject)
//            })
//        }
    }
    
}

extension DetailTableViewController {
    
    private func setupTableView() {
        
        title = subject.name
        
        // Configure tableView appearance
        tableView.tableFooterView = UIView()
        
        // Configure headerView
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        headerViewMarginTop = (navigationController?.navigationBar.bounds.height ?? 44) + UIApplication.shared().statusBarFrame.size.height
        tableView.scrollIndicatorInsets.top = headerViewMarginTop
        
        // Remove placeholder iamge
        headerImageView.image = nil
        
        // Setup dataSource and link model
        setupTableViewDataSource()
        setupHeaderViewImage()
        setupTableViewInsetAndOffset()
    }
    
    private func setupHeaderViewImage() {
        if let urlVal = self.subject.images.largeUrl,
            let url = URL(string: urlVal) {
            // Oops… Reset headerView height when aysn callback finish
            self.headerImageView.af_setImageWithURL(url, imageTransition: .custom(duration: 0.5, animationOptions: [.allowUserInteraction], animations: {
                $0.image = $1
                self.resetHeaderViewHeight()
                self.setupTableViewInsetAndOffset()
                }, completion: nil), runImageTransitionIfCached: false)
        } else {
            self.headerImageView.image = nil
        }
    }
    
    
    private func setupTableViewDataSource() {
        model = DetailTableViewModel(tableView: detailTableView, collectionViewDelegate: self, with: subject)
        dataSource = TableViewDataSource<Model, Cell>(model: model)
        detailTableView.dataSource = dataSource
    }
    
    private func setupTableViewInsetAndOffset() {
        tableView.contentOffset = CGPoint(x: 0.0, y: -headerViewHeight - headerViewMarginTop)
        tableView.contentInset = UIEdgeInsets(top: headerViewHeight + headerViewMarginTop, left: 0, bottom: 0, right: 0)
        
        // Cast to DetailTableView and set inset
        if let tableView = tableView as? DetailTableView {
            tableView.setHeaderView(UIEdgeInsets(top: -headerViewHeight, left: 0, bottom: 0, right: 0))
        }
    }
}

// MARK: - View Life Cycle
extension DetailTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        resetHeaderViewHeight()
        setupTableViewInsetAndOffset()
        
        // Configure cell row height
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Configure cell margin
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Register section header view
        let nib = UINib(nibName: StoryboardKey.DetailTableViewEPSHeaderFooterView, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: StoryboardKey.DetailTableViewEPSHeaderFooterView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        model.refetch(with: subject)
    }

}

// MARK: - UIContentContainer
extension DetailTableViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.resetHeaderViewHeight()
            self.updateHeaderView()
        },completion: nil)
    }
    
}


extension DetailTableViewController {
    
    typealias RequestError = BangumiRequest.RequestError
    typealias ProgressError = BangumiRequest.ProgressError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias UnknownError = BangumiRequest.Unknown
    
    // If detail controller popped before mark epsisode callback called.
    // The self will hold the ref to prevent thread safe issue
    private func markEpisode(at indexPath: IndexPath) {
        
        guard let item = try? model.item(at: indexPath).resolve(),
        let episode = item~>^=^ else { return }
        
        let alertController = UIAlertController(title: "\(episode.typeString)\(episode.sortString) \(episode.name)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action) in
            // ...
        }
        
        let watched = UIAlertAction(title: "看过", style: .default) { (action) in
            self.model.markEpisode(at: indexPath, to: .watched) { self.handler($0) }
        }
        
        let queue = UIAlertAction(title: "想看", style: .default) { (action) in
            self.model.markEpisode(at: indexPath, to: .queue) { self.handler($0) }
        }
        
        let drop = UIAlertAction(title: "抛弃", style: .default) { (action) in
            self.model.markEpisode(at: indexPath, to: .drop) { self.handler($0) }
        }
        
        let remove = UIAlertAction(title: "撤销", style: .destructive) { (action) in
            self.model.markEpisode(at: indexPath, to: .none) { self.handler($0) }
        }
        
        
        alertController.addAction(cancelAction)
        
        let status = item~>^*^
        if status != .watched                   { alertController.addAction(watched) }
        if status != .queue                     { alertController.addAction(queue)   }
        if status != .drop                      { alertController.addAction(drop)    }
        if status != .none && status != nil     { alertController.addAction(remove)  }
        
        // Configure the alert controller's popover presentation controller if it has one
        if let popoverPresentationController = alertController.popoverPresentationController,
        let cell = tableView.cellForRow(at: indexPath) {
            popoverPresentationController.sourceRect = cell.frame
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = .any
        }
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    private func handler(_ error: ErrorProtocol?) {
        do {
            try error?.throwMyself()
            
        } catch RequestError.userNotLogin  {
            let title = NSLocalizedString("please login", comment: "")
            let alertController = UIAlertController.simpleErrorAlert(with: title, description: "")
            self.present(alertController, animated: true, completion: nil)
            consolePrint("User not login")
            
        } catch ProgressError.unauthorized {
            let title = NSLocalizedString("authorize failed", comment: "")
            let desc = NSLocalizedString("try login again", comment: "")
            let alertController = UIAlertController.simpleErrorAlert(with: title, description: desc)
            self.present(alertController, animated: true, completion: nil)
            consolePrint("Unauthorized")
            
        } catch UnknownError.API(let error, let code) {
            let title = NSLocalizedString("server error", comment: "")
            let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
            self.present(alertController, animated: true, completion: nil)
            consolePrint("API error: \(error), code: \(code)")
            
        } catch NetworkError.timeout {
            let status = NSLocalizedString("time out", comment: "")
            SVProgressHUD.showInfo(withStatus: status)
            self.tableView.mj_footer.resetNoMoreData()
            consolePrint("Time out")
            
        } catch NetworkError.notConnectedToInternet {
            let title = NSLocalizedString("not connected to internet", comment: "")
            let alertController = UIAlertController.simpleErrorAlert(with: title, description: "Not connected to internet")
            self.present(alertController, animated: true, completion: nil)
            
        } catch UnknownError.alamofire(let error) {
            let title = NSLocalizedString("unknown error", comment: "")
            let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error.description)", code: error.code)
            self.present(alertController, animated: true, completion: nil)
            consolePrint("Unknow NSError: \(error)")
            
        } catch UnknownError.network(let error) {
            let title = NSLocalizedString("unknown error", comment: "")
            let alertController = UIAlertController.simpleErrorAlert(with: title, description: "NSURLError", code: error.rawValue)
            self.present(alertController, animated: true, completion: nil)
            consolePrint("Unknow NSURLError: \(error)")
            
        } catch {
            let title = NSLocalizedString("unknown error", comment: "")
            let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
            self.present(alertController, animated: true, completion: nil)
            consolePrint("Unresolve case: \(error)")
        }   // end do-catch block    
    }
    
}

// MARK: - UITableViewDelegate
extension DetailTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section >= 4 && section <= 7 else {
            return 0
        }
        
        guard model.numberOfItems(in: section) > 0 else {
            return 0
        }
        
        return 30
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 300
        case let section where section >= 4 && section <= 7:
            return 100
        default:
            return 200
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section >= 3 && section <= 6 else {
            return UIView()
        }
        
        guard tableView.numberOfRows(inSection: section) > 0 else {
            return UIView()
        }
        
        // Dequeue with the reuse identifier
        let sectionHeaderView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: StoryboardKey.DetailTableViewEPSHeaderFooterView) as! DetailTableViewEPSHeaderFooterView
    
        switch section {
        case 4:     sectionHeaderView.typeLabel.text = "EP"
        case 5:     sectionHeaderView.typeLabel.text = "SP"
        case 6:     sectionHeaderView.typeLabel.text = "OP"
        default:    sectionHeaderView.typeLabel.text = "ED"
        }
        
        return sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
        // More topic cell
        case 2:
            let topicTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.TopicTableViewControllerKey) as! TopicTableViewController
            navigationController?.pushViewController(topicTableViewController, animated: true)
            
            topicTableViewController.subject = self.subject
            
        // More subject cell
        case 3:
            let subjectCollectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.SubjectCollectionViewController) as! SubjectCollectionViewController
            navigationController?.pushViewController(subjectCollectionViewController, animated: true)
            
            subjectCollectionViewController.subject = self.subject
        
        // EPS cell
        case 4:     fallthrough
        case 5:     fallthrough
        case 6:     fallthrough
        case 7:     markEpisode(at: indexPath)
            
        default:    break
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let epsCell = cell as? DetailTableViewEPSCell {
            epsCell.delegate = self
        }
        if let bannerCell = cell as? DetailTableViewBannerCell {
            bannerCell.delegate = self
        }
    }
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)

//        if !detailSource.sourceList.isEmpty && indexPath.section == 1 {
//            var url = ""
//            let desktopUrl = detailSource.sourceList[indexPath.row].url
//            let urlSplice = desktopUrl.componentsSeparatedByString("/")
//            if let id = urlSplice.last {
//                url = "http://bangumi.tv/m/topic/subject/\(id)"
//                
//                if #available(iOS 9.0, *) {
//                    let svc = SFSafariViewController(URL: NSURL(string: url)!)
//                    svc.delegate = self
//                    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
//                    self.presentViewController(svc, animated: true, completion: nil)
//                } else {
//                    // Fallback on earlier versions
//                    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
//                }
//                
//            }
//        }
//
//    }

}

// MARK: - DetailTableViewEPSCellDelegate
extension DetailTableViewController: DetailTableViewEPSCellDelegate {

    func commentButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        guard tag != 0, let url = URL(string: "http://bangumi.tv/m/topic/ep/\(tag)") else {
            return
        }

        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
    
}

// MARK: - DetailTableViewBannerCellDelegate
extension DetailTableViewController: DetailTableViewBannerCellDelegate {
    
    func collectButtonPressed(_ sender: UIButton) {
        let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.CollectNavigationController) as! UINavigationController
        let collectTableViewController = navigationController.childViewControllers.first as! CollectTableViewController
        
        collectTableViewController.subject = self.subject
        
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate

// MARK: - UIScrollViweDelegate
extension DetailTableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UITableView {
            self.updateHeaderView()
        }
    }
    
    // Align item to eage
    // Ref: Design Teardowns
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if let collectionView = scrollView as? CMKCollectionView,
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = layout.itemSize.width + layout.minimumLineSpacing
            
            var offset = targetContentOffset.pointee
            
            let index = (offset.x + scrollView.contentInset.left) / width
            let roundedIndex = round(index)
            
            offset = CGPoint(x: roundedIndex * width - scrollView.contentInset.left, y: -scrollView.contentInset.top)
            targetContentOffset.pointee = offset
        }
    }
    
}


// MARK: - UICollectionViewDelegate
extension DetailTableViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = (model.collectionItems[collectionView.tag].1)[indexPath.row]
        var urlPath = ""
        
        switch item {
        case .crt(let crt):
            urlPath = "http://bangumi.tv/m/topic/crt/\(crt.id)"
        case .staff(let staff):
            urlPath = "http://bangumi.tv/m/topic/prsn/\(staff.id)"
        }
        
        guard let url = URL(string: urlPath) else {
            return
        }
        
        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

}

// MARK: - MGSwipeTableCellDelegate
//extension DetailTableViewController: MGSwipeTableCellDelegate {

//    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
//        
//        swipeSettings.transition = MGSwipeTransition.Border
//        expansionSettings.buttonIndex = 0
//        
//        var me = self
//        
//        if direction == .LeftToRight {
//            expansionSettings.fillOnTrigger = false
//            expansionSettings.threshold = 1.5
//            
//            let padding = 15
//            
//            // The button display color is subtle different with origin setting color. Use looks like color substitute for it.
//            let watchedButton = MGSwipeButton(title: "看过", backgroundColor: UIColor.myNavigatinBarLooksLikeColor(), padding: padding, callback: { (cell) -> Bool in
//                //
//                if let _cell = cell as? CMKEPTableViewCell {
//                    self.pleaseWait()
//                    BangumiAnimeModel.shared.markEpWatched(BangumiRequest.shared, subjectID: _cell.subjectID, markEpID: _cell.id, method: UpdateSatusMethod.watched, { (success) -> Void in
//                        if success {
//                            // FIXME:
//                            self.clearAllNotice()
//                            self.detailSource.subjectStatusDict?.subjectStatus[_cell.id] = EpStatusType.watched
//                            self.noticeTop("\(_cell.epTitleLabel.text!) 看过", autoClear: true, autoClearTime: 3)
//                            _cell.indicatorView.hidden = false
//                            _cell.indicatorView.backgroundColor = UIColor.myWatchedColor()
////                            let indexPath = self.tableView.indexPathForCell(cell)!
////                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
//                        } else {
//                            self.noticeInfo("标记失败 请重试", autoClear: true, autoClearTime: 5)
////                            let indexPath = self.tableView.indexPathForCell(cell)!
////                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
//                        }
//                    })
//                }
//                
//                return true
//            })
//            
//            let removeButton = MGSwipeButton(title: "撤销", backgroundColor: UIColor(red: 253.0/255.0, green: 204.0/255.0, blue: 49.0/255.0, alpha: 1.0), padding: padding, callback: { (cell) -> Bool in
//                //
//                if let _cell = cell as? CMKEPTableViewCell {
//                    self.pleaseWait()
//                    BangumiAnimeModel.shared.markEpWatched(BangumiRequest.shared, subjectID: _cell.subjectID, markEpID: _cell.id, method: UpdateSatusMethod.remove, { (success) -> Void in
//                        if success {
//                            // FIXME:
//                            self.clearAllNotice()
//                            self.detailSource.subjectStatusDict?.subjectStatus[_cell.id] = nil
//                            self.noticeTop("撤销成功", autoClear: true, autoClearTime: 3)
//                            _cell.indicatorView.hidden = true
//                            _cell.indicatorView.backgroundColor = UIColor.myWatchedColor()
////                            let indexPath = self.tableView.indexPathForCell(cell)!
////                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
//                        } else {
//                            self.noticeInfo("撤销失败", autoClear: true, autoClearTime: 5)
////                            let indexPath = self.tableView.indexPathForCell(cell)!
////                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
//                        }
//                    })
//                }
//                
//                return true
//            })
//            
//            if let _cell = cell as? CMKEPTableViewCell,
//                let status = self.detailSource.subjectStatusDict?.subjectStatus[_cell.id] {
//                switch status {
//                case .watched: return [removeButton]
//                    
//                default:
//                    return [watchedButton]
//                }
//            }
//            
//            return [watchedButton]
//            
//        } else {
//            //            expansionSettings.fillOnTrigger = true
//            //            expansionSettings.threshold = 2.0
//            //
//            //            let padding = 25
//            //
//            //            let deleteButton = MGSwipeButton(title: "删除", backgroundColor: UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 50.0/255.0, alpha: 1.0), padding: padding, callback: { (cell) -> Bool in
//            //
//            //                let indexPath = me.tableView.indexPathForCell(cell)!
//            //                let subjectToDelete = self.searchModel.subjectLocalList[indexPath.row]
//            //                Subject.deleteSubject(subjectToDelete, { (success) -> Void in
//            //                    NSLog("^ SearchBoxTableViewController: Delete is \(success)")
//            //                    if success {
//            //                        self.searchModel.subjectLocalList.removeAtIndex(indexPath.row)
//            //                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            //                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
//            //                        })
//            //                    }
//            //                })
//            //
//            //                return false
//            //            })
//            
//            return nil
//        }
//        
//        //        return nil
//    }
//    
//    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
//        
//        var str = ""
//        var active = ""
//        switch state {
//        case .None: str = "None"
//        case .SwipingLeftToRight: str = "SwipeingLeftToRight"
//        case .SwipingRightToLeft: str = "SwipingRightToLeft"
//        case .ExpandingLeftToRight: str = "ExpandingLeftToRight"
//        case .ExpandingRightToLeft: str = "ExpandingRightToLeft"
//        }
//        
//        active = (gestureIsActive) ? "Active" : "Ended"
//        NSLog("Swipe state: \(str) ::: Gestrue: \(active)")
//    }
//    
//    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
//        guard (cell != nil) else {
//            return false
//        }
//        
//        return (direction == MGSwipeDirection.LeftToRight) ? true : false
//        
//    }

//}
