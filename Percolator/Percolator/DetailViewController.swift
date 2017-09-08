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
final class DetailViewController: UIViewController {
    
    typealias Model = DetailTableViewModel
    typealias Cell = DetailTableViewCell
    
    private let kHeaderViewMaxHeight: CGFloat = 500.0
    private let kTableViewTopMargin: CGFloat  = 64.0
    
    var subject: Subject!
    private var headerViewHeight: CGFloat = 0 {
        didSet {
            headerViewHeight = min(headerViewHeight, kHeaderViewMaxHeight)
//            headerView.frame.size.height = headerViewHeight
            headerViewBottomAnchor.constant = headerViewHeight
            headerView.layoutIfNeeded()
        }
    }
    lazy var headerViewTopAnchor = headerView.topAnchor.constraint(equalTo: self.detailTableView.topAnchor, constant: self.kTableViewTopMargin)
    lazy var headerViewBottomAnchor = headerView.bottomAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 0.0)

    fileprivate var model: Model!
    fileprivate var dataSource: TableViewDataSource<Model, Cell>!
    
    @IBOutlet var detailTableView: DetailTableView!
    var headerView: UIView!
    var headerImageView: UIImageView!

    @IBAction func actionBarButtonItemPressed(_ sender: UIBarButtonItem) {
        var objectToShare: [Any] = ["\(subject.name) - \(subject.nameCN)"]
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
        activityViewController.completionWithItemsHandler = { (type: UIActivityType?, completed: Bool, _, _) in
            if type == .saveToCameraRoll && completed {
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString("save success", comment: ""))
            }
        }

        let poc = activityViewController.popoverPresentationController
        poc?.barButtonItem = sender
        
        // Async for not block main queue…
        DispatchQueue.main.async { [weak self] in
            self?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // FIXME: misspell function name
    @IBAction func swipeRestureTrigger(_ sender: UISwipeGestureRecognizer) {
        // Reverse EP section only
        guard let section = detailTableView.indexPathForRow(at: sender.location(in: detailTableView))?.section,
        section == 4 else {
            return
        }
        
        model.isReverse = !model.isReverse
        detailTableView.reloadData()
    }
    
    // FIXME: misspell function name
    @IBAction func longPressGrestureTrigger(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            guard let cellIndexPath = detailTableView.indexPathForRow(at: sender.location(in: detailTableView)),
            let tableViewCell = detailTableView.cellForRow(at: cellIndexPath) as? DetailTableViewCell_CollectionView,
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
    
    fileprivate func resetHeaderViewHeight(with width: CGFloat? = nil) {
        guard let image = headerImageView.image else {
            headerViewHeight = 0
            return
        }

        // Set image height to Header with keeping aspect ratio
        // And make sure height not larger than kHeaderViewMaxHeight
        let height = (((width ?? detailTableView.bounds.width) / image.size.width) * image.size.height)
        headerViewHeight = (height > image.size.height) ? image.size.height : height
    }

    private func updateHeaderViewHeight(for width: CGFloat? = nil) {
        // Change header height via set bottom anchor when tableView scroll
        let headerHeightWhenScroll = -detailTableView.contentOffset.y - kTableViewTopMargin
        headerViewBottomAnchor.constant = max(headerHeightWhenScroll, headerViewHeight)

        // Set header origin via set top anchor when header needs scroll with tableView
        let headerOffsetWhenScroll = min(kTableViewTopMargin, headerHeightWhenScroll - headerViewHeight + kTableViewTopMargin)
        headerViewTopAnchor.constant = headerOffsetWhenScroll
    }

}

extension DetailViewController {
    
    fileprivate func setupTableView() {
        
        title = subject.name
        
        // Configure tableView appearance
        detailTableView.tableFooterView = UIView()

        // Setup scroll indicator insets
//        detailTableView.scrollIndicatorInsets.top = headerViewMarginTop

        detailTableView.delegate = self

        // Setup dataSource and link model
        setupTableViewDataSource()
        setupHeaderViewImage()
        setupTableViewInsetAndOffset()
    }
    
    private func setupHeaderViewImage() {

        // Configure headerView
        headerView = UIView(frame: .zero)
        headerView.isUserInteractionEnabled = false

        headerImageView = UIImageView(frame: .zero)
        headerImageView.contentMode = .scaleAspectFit

        headerView.addSubview(headerImageView)
        view.addSubview(headerView)

        view.bringSubview(toFront: detailTableView)

        headerImageView.translatesAutoresizingMaskIntoConstraints                          = false
        headerImageView.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive     = true
        headerImageView.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive   = true
        headerImageView.topAnchor.constraint(equalTo: headerView.topAnchor).isActive       = true
        headerImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true

        headerView.translatesAutoresizingMaskIntoConstraints                             = false
        headerView.leftAnchor.constraint(equalTo: detailTableView.leftAnchor).isActive   = true
        headerView.rightAnchor.constraint(equalTo: detailTableView.rightAnchor).isActive = true
        headerViewTopAnchor.isActive                                                     = true
        headerViewBottomAnchor.isActive                                                  = true

        // Remove placeholder iamge
        headerImageView.image = nil

        if let urlVal = self.subject.images.largeUrl,
            let url = URL(string: urlVal) {
            // Oops… Reset headerView height when aysn callback finish
            self.headerImageView.af_setImage(withURL: url, imageTransition: .custom(duration: 0.5, animationOptions: [.allowUserInteraction], animations: { imageView, image in
                UIView.performWithoutAnimation {
                    imageView.image = image
                    self.resetHeaderViewHeight()
                }
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
        detailTableView.contentOffset = CGPoint(x: 0.0, y: -headerViewHeight - kTableViewTopMargin)
        detailTableView.contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
        detailTableView.setHeaderView(UIEdgeInsets(top: -headerViewHeight + kTableViewTopMargin, left: 0, bottom: 0, right: 0))
    }

}

// MARK: - View Life Cycle
extension DetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        resetHeaderViewHeight()
        setupTableViewInsetAndOffset()

        // Configure cell row height
        detailTableView.estimatedRowHeight = 100
        detailTableView.rowHeight = UITableViewAutomaticDimension
        
        // Configure cell margin
        detailTableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Register section header view
        let nib = UINib(nibName: StoryboardKey.DetailTableViewEPSHeaderFooterView, bundle: nil)
        detailTableView.register(nib, forHeaderFooterViewReuseIdentifier: StoryboardKey.DetailTableViewEPSHeaderFooterView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        model.refetch(with: subject)

        if let indexPath = detailTableView.indexPathForSelectedRow {
            detailTableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

// MARK: - UIContentContainer
extension DetailViewController {

    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            consolePrint(view.safeAreaInsets)
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.resetHeaderViewHeight(with: size.width)
//            self.updateHeaderViewHeight(for: size.width)
        }, completion: nil)
    }
    
}

extension DetailViewController {
    
    typealias RequestError = BangumiRequest.RequestError
    typealias ProgressError = BangumiRequest.ProgressError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias UnknownError = BangumiRequest.Unknown
    
    // If detail controller popped before mark epsisode callback called.
    // Weak self will prevent thread safe issue
    fileprivate func markEpisode(at indexPath: IndexPath) {
        
        guard let item = try? model.item(at: indexPath).resolve(),
        let episode = item~>^=^ else { return }
        
        let alertController = UIAlertController(title: "\(episode.typeString)\(episode.sortString)\n\(episode.name)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            // ...
        }
        
        let watched = UIAlertAction(title: "看过", style: .default) { _ in
            self.model.markEpisode(at: indexPath, to: .watched) { self.handler($0) }
        }
        
        let queue = UIAlertAction(title: "想看", style: .default) { _ in
            self.model.markEpisode(at: indexPath, to: .queue) { self.handler($0) }
        }
        
        let drop = UIAlertAction(title: "抛弃", style: .default) { _ in
            self.model.markEpisode(at: indexPath, to: .drop) { self.handler($0) }
        }
        
        let remove = UIAlertAction(title: "撤销", style: .destructive) { _ in
            self.model.markEpisode(at: indexPath, to: .none) { self.handler($0) }
        }
        
        alertController.addAction(cancelAction)
        
        let status = item~>^*^
        // swiftlint:disable opening_brace
        if status != .watched                   { alertController.addAction(watched) }
        if status != .queue                     { alertController.addAction(queue)   }
        if status != .drop                      { alertController.addAction(drop)    }
        if status != .none && status != nil     { alertController.addAction(remove)  }
        // swiftlint:enable opening_brace

        // Configure the alert controller's popover presentation controller if it has one
        if let popoverPresentationController = alertController.popoverPresentationController,
        let cell = detailTableView.cellForRow(at: indexPath) {
            popoverPresentationController.sourceRect = cell.frame
            popoverPresentationController.sourceView = detailTableView
            popoverPresentationController.permittedArrowDirections = .any
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true)
        }
    }
    
    private func handler(_ error: Error?) {
        do {
            try error?.throwMyself()
            
        } catch RequestError.userNotLogin {
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
            consolePrint("Time out")
            
        } catch NetworkError.notConnectedToInternet {
            self.present(PercolatorAlertController.notConnectedToInternet(), animated: true, completion: nil)
            
        } catch UnknownError.alamofire(let error) {
            self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
            consolePrint("Unknow NSError: \(error)")
            
        } catch UnknownError.network(let error) {
            self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
            consolePrint("Unknow NSURLError: \(error)")
            
        } catch {
            self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
            consolePrint("Unresolve case: \(error)")
        }   // end do-catch block    
    }
    
}

// MARK: - UITableViewDelegate
extension DetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section >= 4 && section <= 7 else {
            return 0
        }

        guard model.numberOfItems(in: section) > 0 else {
            return 0
        }
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return 159.0
        case 2:
            fallthrough
        case 3:
            return 46.0
        case let section where section >= 4 && section <= 7:
            return 66.0
        // Self-size banner cell only
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section >= 4 && section <= 7 else {
            return UIView()
        }
        
        guard tableView.numberOfRows(inSection: section) > 0 else {
            return UIView()
        }
        
        // Dequeue with the reuse identifier
        let sectionHeaderView = detailTableView.dequeueReusableHeaderFooterView(withIdentifier: StoryboardKey.DetailTableViewEPSHeaderFooterView) as! DetailTableViewEPSHeaderFooterView
    
        switch section {
        case 4:     sectionHeaderView.typeLabel.text = "EP"
        case 5:     sectionHeaderView.typeLabel.text = "SP"
        case 6:     sectionHeaderView.typeLabel.text = "OP"
        default:    sectionHeaderView.typeLabel.text = "ED"
        }
        
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let epsCell = cell as? DetailTableViewEPSCell {
            epsCell.delegate = self
        }
        if let bannerCell = cell as? DetailTableViewBannerCell {
            bannerCell.delegate = self
        }
    }

}

// MARK: - DetailTableViewEPSCellDelegate
extension DetailViewController: DetailTableViewEPSCellDelegate {

    func commentButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        guard tag != 0, let url = URL(string: "http://bangumi.tv/m/topic/ep/\(tag)") else {
            return
        }

        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
    
}

// MARK: - DetailTableViewBannerCellDelegate
extension DetailViewController: DetailTableViewBannerCellDelegate {
    
    func collectButtonPressed(_ sender: UIButton) {
        let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.CollectNavigationController) as! UINavigationController
        let collectTableViewController = navigationController.childViewControllers.first as! CollectTableViewController
        
        collectTableViewController.subject = self.subject
        
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViweDelegate
extension DetailViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UITableView {
            self.updateHeaderViewHeight()
        }
    }

    // Align item to eage
    // Ref: Design Teardowns
//    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        
//        if let collectionView = scrollView as? CMKCollectionView,
//        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let width = layout.itemSize.width + layout.minimumLineSpacing
//            
//            var offset = targetContentOffset.pointee
//            
//            let index = (offset.x + scrollView.contentInset.left) / width
//            let roundedIndex = round(index)
//            
//            offset = CGPoint(x: roundedIndex * width - scrollView.contentInset.left, y: -scrollView.contentInset.top)
//            targetContentOffset.pointee = offset
//        }
//    }
    
}

// MARK: - UICollectionViewDelegate
extension DetailViewController: UICollectionViewDelegate {

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
