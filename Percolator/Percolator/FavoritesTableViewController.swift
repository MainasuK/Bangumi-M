//
//  FavoritesTableViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-12.
//
//

import UIKit
import CloudKit
import MJRefresh

class FavoritesTableViewController: UITableViewController, SWRevealViewControllerDelegate, FavoritesTableViewCellDelegate {
    
    var isFirstLoad = true
    
    let favoriteModel = BangumiFavoriteModel.shared
    
//    @IBAction func menuButtonPressed(sender: AnyObject) {
//        self.revealViewController().revealToggle(nil)
//    }
    
    
    // MARK: - Fetch method
    
    func refresh(sender: AnyObject?) {
        favoriteModel.getFavoriteModel { (success) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.header.endRefreshing()
                if success {
                    self.tableView.reloadData()
                }
            }
        }   // favoriteModel.getFavoriteModel…
    }
    
    // TODO: Send setCloudStatus error notice
    func setCloudStatus(notification: NSNotification) {
        
        // FIXME:
        if let errorCode = notification.object as? CKErrorCode {
            switch errorCode {
            case CKErrorCode.NotAuthenticated: fallthrough
//                break
            case CKErrorCode.NetworkUnavailable: fallthrough
//                break
            case CKErrorCode.NetworkFailure: fallthrough
//                break
                
            default:
                favoriteModel.isCloudAvailiable = false
            }
            
            return
        }
        
        favoriteModel.isCloudAvailiable = true
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("FavoritesTabelViewController did load")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setCloudStatus:", name: "setCloudStatus", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLogout:", name: "userLogout", object: nil)
        
        // Configure tableView
        self.tableView.rowHeight = 151      // A magic number make people sad. = =
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        
        // Set Refresh hander
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refresh:")
        header.lastUpdatedTimeLabel.hidden = true
        header.setTitle("获取我保存的搜索中…", forState: MJRefreshStateRefreshing)
        self.tableView.header = header
        
//        // 设置文字
//        [header setTitle:@"Pull down to refresh" forState:MJRefreshStateIdle];
//        [header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
//        [header setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
//        
//        // 设置字体
//        header.stateLabel.font = [UIFont systemFontOfSize:15];
//        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
//        
//        // 设置颜色
//        header.stateLabel.textColor = [UIColor redColor];
//        header.lastUpdatedTimeLabel.textColor = [UIColor blueColor];

        
        // Get records via CloudKit
        self.tableView.header.beginRefreshing()
        isFirstLoad = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSLog("FavoritesTableViewController will appear")
        
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        NSLog("FavoritesTableViewController did disappear")
        
        self.clearAllNotice()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        NSLog("FavoritesTableViewController did appear")
        
        if isFirstLoad {
            self.tableView.header.beginRefreshing()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        self.clearAllNotice()
    }
    
    deinit {
        NSLog("FavoritesTabelViewController is being deallocated");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return BangumiFavoriteModel.shared.favoriteList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavoritesTableViewCell

        let animeItem = favoriteModel.favoriteList[indexPath.row]
        
        // Configure the cell...
        cell.animeItem = animeItem
        cell.delegate = self
        cell.initCell()
        
        // Configure the appearance of the cell
        cell.animeImageView.layer.cornerRadius = 5
        
        cell.cardView.frame = CGRectMake(2, 4, cell.frame.width-5, cell.frame.height-4)
        cell.cardView.alpha = 1
        cell.cardView.layer.masksToBounds   = false
        cell.cardView.layer.cornerRadius    = 3
        cell.cardView.layer.shadowOffset    = CGSizeMake(-0.2, 0.2)
        cell.cardView.layer.shadowRadius    = 3
        cell.cardView.layer.shadowOpacity   = 0.2
        
        cell.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)

        return cell
    }

    
    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let naviVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.animeDetailVC) as! UINavigationController
        let animeDetailVC = naviVC.childViewControllers.first as! AnimeDetailViewController
        
        let item = favoriteModel.favoriteList[indexPath.row]
        animeDetailVC.navigationItem.title = item.name
        animeDetailVC.animeItem = Anime(subject: item)
        animeDetailVC.subjectAllStatus = nil
        animeDetailVC.animeDetailLarge = nil
        
        self.navigationController?.pushViewController(animeDetailVC, animated: true)
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        let searchTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.searchTabelVC) as! SearchBoxTableViewController
        
        searchTableVC.navigationController?.navigationItem.title = "条目搜索"
        searchTableVC.searchModel.dropModel()

        self.navigationController?.pushViewController(searchTableVC, animated: false)
    }
    
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - BangumiTabelViewCellDelegate
    
    func cellCollectionButtonpressed(subjecID: Int) {

        if BangumiRequest.shared.userData == nil {
            self.noticeInfo("请重新登录", autoClear: true, autoClearTime: 6)
            return
        }
        
        let collectVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeCollectVC) as! AnimeCollectTableViewController
        let subject = favoriteModel.findSubjectWith(subjecID)
        
        // FIXME: Need to rebuild model
        if subject == nil {
            self.noticeError("信息缺失", autoClear: true, autoClearTime: 5)
            return
        }
        
        collectVC.animeItem = Anime(subject: subject!)
        self.navigationController?.pushViewController(collectVC, animated: true)

    }
    
    
    // MARK: FavoritesTableViewCellDelegate
    
    func deleteFavoriteButtonPressed(sender: UIView) {
        
        if let indexPath = self.tableView.indexPathForRowAtPoint(sender.convertPoint(CGPointZero, toView: self.tableView)) {
            
            popDeleteMeue(indexPath)
            
        }
    }
    
    private func popDeleteMeue(indexPath: NSIndexPath) {
        let name = favoriteModel.favoriteList[indexPath.row].name
        let message = name ?? "移除"
        
        let deleteMenu = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "移除", style: .Destructive) { (action) -> Void in
            
            self.navigationItem.title = "移除中…"
            self.tableView.userInteractionEnabled = false
            self.pleaseWait()
            
            self.favoriteModel.deleteSubjectInCloud(indexPath.row) { (success) -> Void in
                
                self.clearAllNotice()
                if success {
                    // success
                    self.noticeSuccess("移除成功", autoClear: true, autoClearTime: 3)
                } else {
                    self.noticeError("移除失败", autoClear: true, autoClearTime: 5)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({

                    self.navigationItem.title = "条目搜索"
                    self.tableView.reloadData()
                    self.tableView.userInteractionEnabled = true
                })
                
            }   // self.favoriteModel.deleteSubjectInCloud()…
        }
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        deleteMenu.addAction(deleteAction)
        deleteMenu.addAction(cancelAction)
        
        self.presentViewController(deleteMenu, animated: true, completion: nil)
    }
    
    // MARK: - Broadcast receive method
    
    func userLogout(notification: NSNotification) {
        NSLog("User logout, FavoritesTableViewController reload")
        
        self.tableView.reloadData()
        isFirstLoad = true
    }
}
