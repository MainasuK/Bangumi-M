//
//  AnimeListTableViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//


import UIKit
import CoreData
import QuartzCore
import AlamofireImage
import MJRefresh
import SVProgressHUD

final class AnimeListTableViewController: UITableViewController {
    
    typealias Model = AnimeListTableViewModel
    typealias Cell = AnimeListTableViewCell
    
    private lazy var model: Model = {
        return Model(tableView: self.tableView)
    }()
    private var dataSource: TableViewDataSource<Model, Cell>!
    private var isFirstRefresh = true
    
    @IBAction func unwindToAnimeListTableViewController(_ segue: UIStoryboardSegue) {
        
    }
    
    @objc private func avatarButtonPressed() {
        
        guard let user = BangumiRequest.shared.user else {
            popLoginController()
            return
        }
        
        let alertController = UIAlertController(title: "\(user.nickname)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action) in
            // ...
        }
        
        let logoutAction = UIAlertAction(title: "注销", style: .destructive) { (action) in
            User.removeInfo()
            BangumiRequest.shared.user = nil
            self.model.removeAll()
            self.setupBarButtonItem()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        alertController.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(alertController, animated: true, completion: nil)
    }
    
}

extension AnimeListTableViewController {
    
    private func popLoginController() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.LoginViewController) as! LoginViewController
        
        loginViewController.delegate = self
        
        loginViewController.modalPresentationStyle = .overCurrentContext
        loginViewController.modalTransitionStyle = .crossDissolve
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            loginViewController.view.backgroundColor = UIColor.clear()
        }
        
        present(loginViewController, animated: true)
    }
    
}

// MARK: - UITableView Setup method
extension AnimeListTableViewController {
    
    private func setupBarButtonItem() {
        let button: UIButton = {
            let btn = UIButton(type: .custom)
            
            btn.setImage(UIImage.fromColor(.placeholder(), size: CGSize(width: 30, height: 30)), for: .normal)
            if let avatarLargeUrl = BangumiRequest.shared.user?.avatar.largeUrl,
            let url = URL(string: avatarLargeUrl) {
                btn.af_setImageForState(.normal, url: url)
            }
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.imageView?.frame.size = CGSize(width: 30, height: 30)
            btn.addTarget(self, action: #selector(AnimeListTableViewController.avatarButtonPressed), for: .touchUpInside)
            btn.imageView?.layer.cornerRadius = 30 * 0.5
            btn.imageView?.layer.borderColor = UIColor.percolatorLightGray().cgColor
            btn.imageView?.layer.borderWidth = 0.5   // 1px
            
            return btn
        }()
        
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    private func setupTableView() {
        // Setup dataSource and link model
        setupTableViewDataSource()
        
        // Configure tableView row height
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set cell conform readable layout margin
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Configure tableView appearance
        tableView.separatorColor = UIColor.clear()
        tableView.backgroundColor = UIColor.myAnimeListBackground()
        
        // Fix the separator display when 0 rows
        tableView.tableFooterView = UIView()
        
        // Set refresh header
        setupTableViewHeader()
        
    }
    
    private func setupTableViewHeader() {
        tableView.mj_header = {
            //  Use unowned because the caller is self. No async
            let header = MJRefreshNormalHeader { [unowned self] in
                self.refreshAnimeList()
            }
            
            return header
        }()
    }
    
    private func setupTableViewDataSource() {
        dataSource = TableViewDataSource<Model, Cell>(model: model)
        tableView.dataSource = dataSource
    }
}

// MARK: - View Life Cycle
extension AnimeListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    
        //  Debug
        //  consolePrint(UIFont.downloadableFontNames())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.tableView.header.endRefreshing()
//        self.clearAllNotice()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard User.isLogin() else {
            popLoginController()
            
            return
        }
        
        if isFirstRefresh {
            tableView.mj_header.beginRefreshing()
        }
        isFirstRefresh = false
        
        setupBarButtonItem()
        
//        UIApplication.shared().setStatusBarStyle(UIStatusBarStyle.lightContent, animated: animated)
//        self.tableView.reloadData()
//        
//        // Login Logic
//        NSLog("AnimeListViewController did appear")
//        
//        let hasLoginKey = UserDefaults.standard().bool(forKey: UserDefaultsKey.hasLoginKey)
//        
//        if hasLoginKey == false {   // FIXME:
//            performSegue(withIdentifier: StoryboardKey.showLoginVC, sender: self)
//        } else if request.userData == nil {
//            let email = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userEmail) as! String
//            let pass = myKeyChainWrapper.myObjectForKey(kSecValueData) as! String
//            
//            let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
//            spinner.color = UIColor.myPurePinkColor()
//            spinner.hidesWhenStopped = true
//            spinner.startAnimating()
//
//            self.view.addSubview(spinner)
//            let centerX = NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
//            let centerY = NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -64)  // move up 64 point
//            spinner.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activateConstraints([centerX, centerY])
//            
//            self.view.userInteractionEnabled = false
//            
//            NSLog("Remove JSON cache")
//            Shared.JSONCache.removeAll()    // remove cache when we lost userdata
//            
//            request.userLogin(email, password: pass, handler: { (userData) -> Void in
//                
//                spinner.stopAnimating()
//                self.view.userInteractionEnabled = true
//                if let user = userData {
//                    debugPrint("@ AnimeListTableVC: User data get")
//                    debugPrint("@ AnimeListTableVC: User ID is \(user.id)")
//                    debugPrint("@ AnimeListTableVC: User nickname is \(user.nickName)")
//                    
//                    self.request.userData = user
//                    self.tableView.header.beginRefreshing()
//                    self.isFirstLoad = false
//                } else {
//                    // FIXME: User auth failed
//                    debugPrint("@ AnimeListTableVC: User auth failed")
//                    //                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    //
//                    //                        self.performSegueWithIdentifier(StoryboardKey.showLoginVC, sender: self)
//                    //                    })
//                }
//                
//            })
//            
//        } else {
//            if isFirstLoad {
//                NSLog("@ AnimeListTableVC: First load")
//                self.tableView.header.beginRefreshing()
//                isFirstLoad = false
//            }
//        }   // if hasLoginKey == fasle … else if … else
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(true)
//        progressView.hidden = true
    }
    
}

extension AnimeListTableViewController {
    
    typealias CollectionError = BangumiRequest.CollectionError
    typealias RequestError = BangumiRequest.RequestError
    typealias UnknownError = BangumiRequest.Unknown
    typealias NetworkError = BangumiRequest.NetworkError
    typealias ModelError = AnimeListTableViewModel.ModelError
    
    func refreshAnimeList() {
        
        model.refresh { (error: ErrorProtocol?) in
            
            defer {
                self.tableView.mj_header.endRefreshing()
            }
            
            
            do {
                try error?.throwMyself()
                BangumiRequest.shared.timeoutErrorTimes = 0
                
            } catch CollectionError.noCollection {
                let title = NSLocalizedString("no collection", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "")
                self.present(alertController, animated: true, completion: nil)
                consolePrint("No collection exists")
                
            } catch CollectionError.unauthorized {
                let title = NSLocalizedString("authorize failed", comment: "")
                let desc = NSLocalizedString("try login again", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: desc)
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unauthorized")
                
            } catch RequestError.userNotLogin  {
                let title = NSLocalizedString("please login", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "")
                self.present(alertController, animated: true, completion: nil)
                consolePrint("User not login")
                
            } catch UnknownError.API(let error, let code) {
                let title = NSLocalizedString("server error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                self.present(alertController, animated: true, completion: nil)
                consolePrint("API error: \(error), code: \(code)")
                
            } catch NetworkError.timeout {
                if BangumiRequest.shared.timeoutErrorTimes == 3 {
                    // FIXME: English localize?
                    let alertController = UIAlertController(title: "请检查网络链接状况", message: "可能是由于 DNS 污染造成若您无法链接至 bgm.tv，请更换 DNS 或联系当地网络提供商解决", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("不再提醒", comment: ""), style: .cancel) { (action) in
                        // ...
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let status = NSLocalizedString("time out", comment: "")
                    SVProgressHUD.showInfo(withStatus: status)
                }

                consolePrint("Timeout")
                
            } catch NetworkError.notConnectedToInternet {
                let title = NSLocalizedString("not connected to internet", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "Not connected to internet")
                self.present(alertController, animated: true, completion: nil)
                
            } catch NetworkError.dnsLookupFailed {
                let title = NSLocalizedString("dns lookup failed", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "")
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
                // Really? I think never got here.
                // All error wrapped appropriately above …
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unresolve case: \(error)")
            }
        }
        //
    }
    
}

// MARK: - UITableViewDataSource
extension AnimeListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // Return the number of sections.
//        if !animeModel.animeList.isEmpty || isFetchingData {
//            //            self.tableView.backgroundView = nil
//            messageLabel.hidden = true
//            return 1
//        } else {
//            
//            // is Refetch successful
//            if isFetchingData {
//                messageLabel.hidden = true
//            } else {
//                //                messageLabel = UILabel(frame: CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
//                //                messageLabel.text = "没有在看的番组？\n搜索添加一个吧"
//                //                messageLabel.textColor = UIColor.darkGrayColor()
//                //                messageLabel.numberOfLines = 2
//                //                messageLabel.textAlignment = NSTextAlignment.Center
//                //                messageLabel.font = UIFont(name: "system", size: 20)
//                //                messageLabel.sizeToFit()
//                //                messageLabel.center = self.tableView.center
//                //                self.tableView.addSubview(messageLabel)
//            }
//            //
//            //            self.tableView.backgroundView = messageLabel
//            //            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//            
//            
//            return 0
//        }
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Return the number of rows in the section.
//        if animeModel.animeDetailList.count == animeModel.animeList.count {
//            return animeModel.animeList.count
//        }
//        
//        return 0
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardKey.AnimeListTableViewCellKey, for: indexPath) as! AnimeListTableViewCell
        
//        let animeListCount = animeModel.animeList.count
//        let animeDetailListCount = animeModel.animeDetailList.count

        // Configure the cell...
//        if animeDetailListCount == animeListCount {
//            let animeItem = animeModel.animeList[indexPath.row]
//
//            cell.delegate = self
//            cell.animeItem = animeItem
//            cell.postMark = self.isFetchingData
//            cell.animeImageView.hnk_setImageFromURL(NSURL(string: animeItem.subject.images.largeUrl)!, placeholder: UIImage(named: "404"))
//            cell.initCell()
//
//        }

        
        
        return cell
    }

}

// MARK: - UITableViewDelegate
extension AnimeListTableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Configure cell shadow
        guard let cell = cell as? AnimeListTableViewCell else {
            return
        }
        
        cell.delegate = self

        // Make sure the shadow path set to right size
        cell.cardView.setNeedsLayout()
        cell.cardView.layoutIfNeeded()
    
        // Set border of cardView
        cell.cardView.layer.cornerRadius    = 5
        cell.cardView.layer.shadowColor     = UIColor.black().cgColor
        cell.cardView.layer.shadowOffset    = CGSize(width: 0, height: 0)
        cell.cardView.layer.shadowPath      = UIBezierPath(rect: cell.cardView.bounds).cgPath
        cell.cardView.layer.shadowRadius    = 3
        cell.cardView.layer.shadowOpacity   = 0.2
        
        // Mask controlView for get two bottom corners
        cell.controlView.layer.mask = {
            let maskLayer = CAShapeLayer()
            let maskPath = UIBezierPath(roundedRect: cell.controlView.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: 5, height: 5))
            
            maskLayer.frame = cell.controlView.bounds
            maskLayer.path  = maskPath.cgPath
            
            return maskLayer
        }()

    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if isFetchingData || !canRefresh {
//            return
//        }
//
        let detailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.DetialTableViewControllerKey) as! DetailTableViewController
        let (subject, _) = model.item(at: indexPath)
        detailTableViewController.subject = subject
        navigationController?.pushViewController(detailTableViewController, animated: true)
//
//        let animeItem = animeModel.animeList[indexPath.row]
//        let id = animeItem.subject.id
//        let subjectLarge = animeModel.animeDetailList[id]!
//        detailVC.detailSource = BangumiDetailSource(subject: subjectLarge)
//        detailVC.animeItem = animeItem
//        detailVC.animeSubject = animeItem.subject
//        detailVC.detailSource.animeDetailLarge = subjectLarge
//        detailVC.detailSource.gridStatusTable = animeModel.animeGridStatusList[id]
//        detailVC.detailSource.subjectStatusDict = animeModel.subjectAllStatusList[id]
//
//        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.myNavigatinBarLooksLikeColor().colorWithAlphaComponent(1))
//        self.navigationController?.pushViewController(detailVC, animated: true)
//               self.navigationController?.pushViewController(detailVC, animated: true)
        }
    
}

// MARK: - UIContentContainer
extension AnimeListTableViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            // For re-calculate cell shadow path
            self.tableView.reloadData()
        }, completion: nil)
    }
    
}

// MARK: - AnimeCollectionViewControllerDelegate
//extension AnimeListTableViewController: AnimeCollectionViewControllerDelegate {
//    
//    func pushAnimeCollectionVC(animeItem: Anime) {
//        let collectVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeCollectVC) as! AnimeCollectTableViewController
//        collectVC.animeItem = animeItem
//        collectVC.needComment = true
//        self.navigationController?.pushViewController(collectVC, animated: true)
//    }
//    
//}
//
// MARK: - TransitionDelegate
extension AnimeListTableViewController: TransitionDelegate {
    
    // Delegate to LoginViewController
    // FIXME: context parameter needed here
    func dissmissViewController(with flag: Bool) {
        if flag {
            tableView.mj_header.beginRefreshing()
        }
        setupBarButtonItem()
    }
    
}

extension AnimeListTableViewController: AnimeListTableViewCellDelegate {
    
    func watchedButtonPressed(_ sender: UIButton, with mark: AnimeMark) {
        switch mark {
        case .episode(let ep, let subject):
            model.mark(ep, of: subject, handler: { (error: ErrorProtocol?) in
                do {
                    try error?.throwMyself()
                } catch ModelError.mark {
                    let title = NSLocalizedString("mark error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "未能标注 EP.\(ep.sortString) \(ep.nameCN)")
                    self.present(alertController, animated: true, completion: nil)
                    
                } catch NetworkError.notConnectedToInternet {
                    let title = NSLocalizedString("not connected to internet", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "Not connected to internet")
                    self.present(alertController, animated: true, completion: nil)
                    
                } catch NetworkError.timeout {
                    let title = NSLocalizedString("time out", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "未能标注 EP.\(ep.sortString) \(ep.nameCN)")
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
            })
            
        case .subject(let subject):
            let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.CollectNavigationController) as! UINavigationController
            let collectTableViewController = navigationController.childViewControllers.first as! CollectTableViewController
            collectTableViewController.subject = subject
            collectTableViewController.isNeedComment = true
            
            // Wow… really awesome style
            navigationController.modalPresentationStyle = .formSheet
            
            present(navigationController, animated: true, completion: nil)

        default:
            return
        }
    }
}
