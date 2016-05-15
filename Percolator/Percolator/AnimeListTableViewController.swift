//
//  AnimeListTableViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//


import UIKit
import Haneke
import MJRefresh

final class AnimeListTableViewController: UITableViewController, SWRevealViewControllerDelegate {

    let myKeyChainWrapper = KeychainWrapper()
    let request = BangumiRequest.shared
    let animeModel = BangumiAnimeModel.shared
    let searchModel = BangumiSearchModel.shared
    
    var isFirstFailed = true
    var isFirstLoad = true
    var searchController: UISearchController!
    var isFetchingData: Bool = false {
        willSet {
            NSNotificationCenter.defaultCenter().postNotificationName("setPostMark", object: newValue)
        }
    }
    var canRefresh: Bool = true
    var messageLabel = UILabel()
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.revealViewController().revealToggle(nil)
    }
    @IBAction func searchButtonPressed(sender: UIBarButtonItem?) {
        if request.userData != nil {
            pushSearchTableViewController()
        } else {
            self.clearAllNotice()
            self.noticeInfo("请先登录", autoClear: true, autoClearTime: 5)
        }
    }
    @IBAction func refresh(sender: UIRefreshControl?) {
        
        if !canRefresh || isFetchingData {
            self.tableView.header.endRefreshing()
            return
        }
        
        if let user = request.userData {
            isFetchingData = true
            isFirstFailed = true
            animeModel.fetchAnimeListTabelVCModel(request) { (isFetchSuccess) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.isFetchingData = false
                
                if isFetchSuccess {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.header.endRefreshing()
                        self.tableView.reloadData()
                    }   // dispatch_async(…)
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.clearAllNotice()
                        if self.isFirstFailed {
                            self.noticeError("请求超时", autoClear: true, autoClearTime: 3)
                            self.isFirstFailed = false
                        }
                        self.tableView.header.endRefreshing()
                        self.progressView.setProgress(0.0, animated: false)
                    }
                    
                }   // if isFetchSuccess … else …
            }   // animeModel.fetchAnimeListTabelVCModel(…)
            
        } else {
            
            self.noticeError("请重新登录", autoClear: true, autoClearTime: 5)
            self.tableView.header.endRefreshing()
        }   // end if let user = request.userData…
    }   // end func refresh(sender: …) { … }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    
    func pushSearchTableViewController() {
        let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.searchTabelNaviVC) as! UINavigationController
        self.presentViewController(searchVC, animated: true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == StoryboardKey.showLoginVC {
            let loginVC = segue.destinationViewController as! LoginViewController
            loginVC.delegate = self
        }
    }
    

    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
    
    private struct Storyboard {
        static let animeCellIdentifier = "animeCell"
        static let showAnimeDetail = "showAnimeDetail"
    }
    
    // MARK: - Broadcast receive method
    
    func setRefreshMark(notification: NSNotification) {
        canRefresh = notification.object as! Bool
    }
    
    func setProgress(notification: NSNotification) {

        if let progress = notification.object as? Float where isFirstFailed == true {
            progressView.hidden = (progress == 1.0) ? true : false
            progressView.setProgress(progress, animated: true)
        } else {
            progressView.hidden = true
            progressView.setProgress(0.0, animated: false)
        }
    }

    func userLogout(notification: NSNotification) {
        tableView.reloadData()
        isFirstLoad = true
    }
    
}

// MARK: - View Life Cycle
extension AnimeListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnimeListTableViewController.setRefreshMark(_:)), name: "setRefreshMark", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnimeListTableViewController.setProgress(_:)), name: "setProgress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnimeListTableViewController.refresh(_:)), name: "reloadModel", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnimeListTableViewController.userLogout(_:)), name: "userLogout", object: nil)
        
        // Set Refresh hander
        self.tableView.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(AnimeListTableViewController.refresh(_:)))
        
        // Set progress view
        let naviBar = self.navigationController?.navigationBar
        let naviBarHeight = naviBar!.frame.height
        let progressFrame = progressView.frame
        let pSetX = progressFrame.origin.x
        let pSetY = CGFloat(naviBarHeight)
        let pSetWidth = self.view.frame.width
        let pSetHeight = progressFrame.height
        progressView.tintColor = UIColor.myProgressBarColor()
        progressView.frame = CGRectMake(pSetX, pSetY, pSetWidth, pSetHeight)
        self.navigationController!.navigationBar.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.hidden = true
        progressView.setProgress(0.0, animated: false)
        
        // Configure tableView
        self.tableView.rowHeight = 151      // A magic number make people sad. = =
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("AnimeListTableViewController did disappear")
        
        self.tableView.header.endRefreshing()
        self.clearAllNotice()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.lt_reset()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: animated)
        self.tableView.reloadData()
        
        // Login Logic
        NSLog("AnimeListViewController did appear")
        
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.hasLoginKey)
        
        if hasLoginKey == false {   // FIXME:
            performSegueWithIdentifier(StoryboardKey.showLoginVC, sender: self)
        } else if request.userData == nil {
            let email = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userEmail) as! String
            let pass = myKeyChainWrapper.myObjectForKey(kSecValueData) as! String
            
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            spinner.color = UIColor.myPurePinkColor()
            spinner.hidesWhenStopped = true
            spinner.startAnimating()

            self.view.addSubview(spinner)
            let centerX = NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -64)  // move up 64 point
            spinner.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints([centerX, centerY])
            
            self.view.userInteractionEnabled = false
            
            NSLog("Remove JSON cache")
            Shared.JSONCache.removeAll()    // remove cache when we lost userdata
            
            request.userLogin(email, password: pass, handler: { (userData) -> Void in
                
                spinner.stopAnimating()
                self.view.userInteractionEnabled = true
                if let user = userData {
                    debugPrint("@ AnimeListTableVC: User data get")
                    debugPrint("@ AnimeListTableVC: User ID is \(user.id)")
                    debugPrint("@ AnimeListTableVC: User nickname is \(user.nickName)")
                    
                    self.request.userData = user
                    self.tableView.header.beginRefreshing()
                    self.isFirstLoad = false
                } else {
                    // FIXME: User auth failed
                    debugPrint("@ AnimeListTableVC: User auth failed")
                    //                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //
                    //                        self.performSegueWithIdentifier(StoryboardKey.showLoginVC, sender: self)
                    //                    })
                }
                
            })
            
        } else {
            if isFirstLoad {
                NSLog("@ AnimeListTableVC: First load")
                self.tableView.header.beginRefreshing()
                isFirstLoad = false
            }
        }   // if hasLoginKey == fasle … else if … else
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        progressView.hidden = true
    }
    
}

// MARK: - UITableViewDataSource
extension AnimeListTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if !animeModel.animeList.isEmpty || isFetchingData {
            //            self.tableView.backgroundView = nil
            messageLabel.hidden = true
            return 1
        } else {
            
            // is Refetch successful
            if isFetchingData {
                messageLabel.hidden = true
            } else {
                //                messageLabel = UILabel(frame: CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
                //                messageLabel.text = "没有在看的番组？\n搜索添加一个吧"
                //                messageLabel.textColor = UIColor.darkGrayColor()
                //                messageLabel.numberOfLines = 2
                //                messageLabel.textAlignment = NSTextAlignment.Center
                //                messageLabel.font = UIFont(name: "system", size: 20)
                //                messageLabel.sizeToFit()
                //                messageLabel.center = self.tableView.center
                //                self.tableView.addSubview(messageLabel)
            }
            //
            //            self.tableView.backgroundView = messageLabel
            //            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if animeModel.animeDetailList.count == animeModel.animeList.count {
            return animeModel.animeList.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.animeCellIdentifier, forIndexPath: indexPath) as! AnimeListTableViewCell
        
        let animeListCount = animeModel.animeList.count
        let animeDetailListCount = animeModel.animeDetailList.count
        
        // Configure the cell...
        if animeDetailListCount == animeListCount {
            let animeItem = animeModel.animeList[indexPath.row]

            cell.delegate = self
            cell.animeItem = animeItem
            cell.postMark = self.isFetchingData
            cell.animeImageView.hnk_setImageFromURL(NSURL(string: animeItem.subject.images.largeUrl)!, placeholder: UIImage(named: "404"))
            cell.initCell()

            // Configure the appearance of the cell
            cell.animeImageView.layer.cornerRadius = 5
            cell.animeImageView.layer.borderColor = UIColor.myGrayColor().CGColor
            cell.animeImageView.layer.borderWidth = 1.0
        }
        
        cell.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension AnimeListTableViewController {
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Configure cell shadow
        if let cell = cell as? AnimeListTableViewCell {
            
            // Make sure the shadow path set to right size
            cell.cardView.setNeedsLayout()
            cell.cardView.layoutIfNeeded()
            
            cell.cardView.layer.cornerRadius    = 3
            cell.cardView.layer.shadowColor     = UIColor.blackColor().CGColor
            cell.cardView.layer.shadowOffset    = CGSizeMake(0, 0)
            cell.cardView.layer.shadowPath      = UIBezierPath(rect: cell.cardView.bounds).CGPath
            cell.cardView.layer.shadowRadius    = 3
            cell.cardView.layer.shadowOpacity   = 0.2
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isFetchingData || !canRefresh {
            return
        }
        
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.DetialVC) as! DetailViewController
        
        let animeItem = animeModel.animeList[indexPath.row]
        let id = animeItem.subject.id
        let subjectLarge = animeModel.animeDetailList[id]!
        detailVC.detailSource = BangumiDetailSource(subject: subjectLarge)
        detailVC.animeItem = animeItem
        detailVC.animeSubject = animeItem.subject
        detailVC.detailSource.animeDetailLarge = subjectLarge
        detailVC.detailSource.gridStatusTable = animeModel.animeGridStatusList[id]
        detailVC.detailSource.subjectStatusDict = animeModel.subjectAllStatusList[id]
        
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.myNavigatinBarLooksLikeColor().colorWithAlphaComponent(1))
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

// MARK: - UIContentContainer
extension AnimeListTableViewController {
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            // For re-calculate cell shadow path
            self.tableView.reloadData()
        },completion: nil)
    }
    
}

// MARK: - AnimeCollectionViewControllerDelegate
extension AnimeListTableViewController: AnimeCollectionViewControllerDelegate {
    
    func pushAnimeCollectionVC(animeItem: Anime) {
        let collectVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeCollectVC) as! AnimeCollectTableViewController
        collectVC.animeItem = animeItem
        collectVC.needComment = true
        self.navigationController?.pushViewController(collectVC, animated: true)
    }
    
}

// MARK: - MenuTransitionDelegate
extension AnimeListTableViewController: MenuTransitionDelegate {
    
    func dismissLoginVC() {
        self.tableView.header.beginRefreshing()
    }
    
}