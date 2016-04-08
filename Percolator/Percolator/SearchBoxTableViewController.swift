//
//  SearchBoxTableViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-19.
//
//

import UIKit
import CoreData
import Haneke
import MJRefresh

final class SearchBoxTableViewController: UITableViewController {

    let searchModel = BangumiSearchModel.shared
    let request = BangumiRequest.shared
    
    var isSearching = false {
        willSet {
            if newValue == true {
                self.tableView.footer.resetNoMoreData()
            } else {
                self.tableView.footer.noticeNoMoreData()
            }
        }
    }
//    var fetchResultController = NSFetchedResultsController!
    var searchController: UISearchController!
    var isSearchTabelControllerFirstDisplay = true
    
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBAction func searchButtonClicked(button: UIBarButtonItem?) {
        
        // Set searchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "条目搜索"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        
        let title = self.navigationItem.title ?? "搜索盒子"
        searchController.searchBar.text = (title == "搜索盒子") ? "" : title
        // Present the view controller.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(self.searchController, animated: true, completion: nil)
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        })
    }
    
    
    func loadMoreData(searchBar: UISearchBar) {
        
        let searchText = searchBar.text ?? ""
        searchController.searchBar.resignFirstResponder()
        searchButton.enabled = false
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.center = self.view.center
        spinner.center.y -= 64  // FIXME: Magic number me sad
        spinner.color = UIColor.myPurePinkColor()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        searchModel.sendSearchRequest(request, searchText: searchText) { (error) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                spinner.stopAnimating()
                self.tableView.footer.endRefreshing()
                self.searchButton.enabled = true
                
                if error != nil {
                    if error?.code == 1 {
                        // No more data
                        self.tableView.footer.noticeNoMoreData()
                        debugPrint("@ SearchTableViewController: No more data")
                    } else {
                        // No result
                        debugPrint("@ SearchTableViewController: No result")
                        self.noticeInfo("无结果", autoClear: true, autoClearTime: 5)
                    }
                    
                } else {
                    // success
                    debugPrint("@ SearchTableViewController: Fetch data success")
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    private func fetchLocalData() {
        
        let fetchRequest = NSFetchRequest(entityName: "Subject")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            
            Subject.fetchSubject({ (animeSubjectArr) -> Void in
                
                if animeSubjectArr != nil {
                    self.searchModel.subjectLocalList = animeSubjectArr!
                }
            })
        }
    }

}

// MARK: - View Life Cycle
extension SearchBoxTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch result from Core Data
        self.navigationItem.title = "搜索盒子"
        fetchLocalData()
        
        // Fix the separator display when Zero rows
        tableView.tableFooterView = UIView()
        
        /// Set Refresh footer
        self.tableView.footer = MJRefreshBackNormalFooter {
            if self.isSearching {
                self.loadMoreData(self.searchController.searchBar)
            } else {
                self.tableView.footer.noticeNoMoreData()
            }
        }
        
        // Self Sizing Cells
        //        self.tableView.estimatedRowHeight = 110;
        //        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        // Configure tableView appearance
        
        //        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        //        self.tableView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.2)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.lt_reset()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isSearchTabelControllerFirstDisplay && searchModel.subjectLocalList.isEmpty {
            searchButtonClicked(nil)
        }
        isSearchTabelControllerFirstDisplay = false
    }
    
}

// MARK: - UITableViewDatasource
extension SearchBoxTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var rows = 0
        if isSearching {
            rows = searchModel.subjectsList.count
        } else {
            NSLog("@ SearchBoxTableViewController: Get local list (\(searchModel.subjectLocalList.count))")
            rows = searchModel.subjectLocalList.count
        }
        
        return rows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SearchBoxTabelCell
        
        let (subject, isSaved) = searchModel.getSubjectAndSavedInfoToSearchBox(indexPath.row, isSearching)
        
        cell.delegate = self
        cell.subject = subject
        cell.isSaved = (isSearching) ? isSaved : false
        cell.initCell()
        
        return cell
    }

}

// MARK: - UITableViewDelegate
extension SearchBoxTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.DetialVC) as! DetailViewController
        
        let request = BangumiRequest.shared
        let (subject, isSaved) = searchModel.getSubjectAndSavedInfoToSearchBox(indexPath.row, isSearching)
        
        detailVC.animeItem = Anime(subject: subject)
        detailVC.animeSubject = subject
        detailVC.detailSource = BangumiDetailSource()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.myNavigatinBarLooksLikeColor().colorWithAlphaComponent(1))
            self.navigationController?.pushViewController(detailVC, animated: true)
            detailVC.initFromSearchBox(request, subject)
        })
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 110
    }
    
}

// MARK: - UISearchBarDelegate
extension SearchBoxTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if searchBar.text == "" || searchBar.text == "搜索盒子" {
            isSearching = false
            fetchLocalData()
            self.navigationItem.title = "搜索盒子"
        } else {
            isSearching = true
            searchModel.dropModel()
            loadMoreData(searchBar)
            self.navigationItem.title = searchBar.text
        }
        
        searchController.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        if searchBar.text == "搜索盒子" || searchBar.text == "" {
            isSearching = false
            fetchLocalData()
        }
        self.navigationItem.title = (searchBar.text != "") ? searchBar.text : "搜索盒子"
        self.tableView.reloadData()
    }

}

// MARK: - UISearchResultsUpdating
extension SearchBoxTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if searchController.searchBar.text == "搜索盒子" {
            isSearching = false
            fetchLocalData()
        }
        
        self.tableView.reloadData()
        self.tableView.footer.resetNoMoreData()
    }
    
}

// MARK: - UISearchControllerDelegate
extension SearchBoxTableViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(searchController: UISearchController) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
}

// MARK: - MGSwipeTableCellDelegate
extension SearchBoxTableViewController: MGSwipeTableCellDelegate {
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        //        if let _cell = cell as? SearchBoxTabelCell {
        //            if searchModel.isLocalSaved(_cell.subject.id) {
        //                return false
        //            }
        //        }
        //
        if isSearching {
            return (direction == .LeftToRight) ? true : false
        } else {
            return true
        }
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        swipeSettings.transition = MGSwipeTransition.Border
        expansionSettings.buttonIndex = 0
        
        let me = self
        
        if direction == .LeftToRight {
            expansionSettings.fillOnTrigger = true
            expansionSettings.threshold = 1.5
            
            let padding = 15
            
            let collectButton = MGSwipeButton(title: "收藏", backgroundColor: UIColor(red: 253.0/255.0, green: 204.0/255.0, blue: 49.0/255.0, alpha: 1.0), padding: padding, callback: { (cell) -> Bool in
                
                let indexPath = me.tableView.indexPathForCell(cell)!
                let (subject, saved) = self.searchModel.getSubjectAndSavedInfoToSearchBox(indexPath.row, self.isSearching)
                
                let collectVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeCollectVC) as! AnimeCollectTableViewController
                collectVC.animeItem = Anime(subject: subject)
                //                self.navigationController?.pushViewController(collectVC, animated: true)
                //                self.searchController.dismissViewControllerAnimated(true, completion: nil)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(collectVC, animated: true)
                })
                
                return false
            })
            
            let saveButton = MGSwipeButton(title: "保存", backgroundColor: UIColor(red: 0, green: 0x99/255.0, blue:0xcc/255.0, alpha: 1.0), padding: padding, callback: { (cell) -> Bool in
                
                let indexPath = me.tableView.indexPathForCell(cell)!
                let image = (me.tableView.cellForRowAtIndexPath(indexPath) as? SearchBoxTabelCell)?.animeImageView.image
                let (subject, _) = self.searchModel.getSubjectAndSavedInfoToSearchBox(indexPath.row, self.isSearching)
                
                Subject.saveAnimeSubject(subject) { (success) -> Void in
                    if success {
                        NSLog("^ SearchBoxTableViewController: Save success")
                        self.noticeTop("保存成功", autoClear: true, autoClearTime: 3)
                    } else {
                        NSLog("^ SearchBoxTableViewController: Save failed")
                    }
                    
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                }
                
                return false
            })
            
            if isSearching {
                if let _cell = cell as? SearchBoxTabelCell {
                    if _cell.isSaved {
                        return [collectButton]
                    } else {
                        return [saveButton, collectButton]
                    }
                    
                } else {
                    return nil
                }
                
            } else {
                return [collectButton]
            }   // if isSeaching … else …
        } else {    // if .LeftToRight … else { so, Here is .RightToLeft } …
            expansionSettings.fillOnTrigger = true
            expansionSettings.threshold = 2.0
            
            let padding = 25
            
            let deleteButton = MGSwipeButton(title: "删除", backgroundColor: UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 50.0/255.0, alpha: 1.0), padding: padding, callback: { (cell) -> Bool in
                
                let indexPath = me.tableView.indexPathForCell(cell)!
                let subjectToDelete = self.searchModel.subjectLocalList[indexPath.row]
                Subject.deleteSubject(subjectToDelete, { (success) -> Void in
                    NSLog("^ SearchBoxTableViewController: Delete is \(success)")
                    if success {
                        self.searchModel.subjectLocalList.removeAtIndex(indexPath.row)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                        })
                    }
                })
                
                return false
            })
            
            
            if isSearching {
                return nil
            } else {
                return [deleteButton]
            }
        }   // if .LeftToRight … else …
        
        //        return nil
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        
        var str = ""
        var active = ""
        switch state {
        case .None: str = "None"
        case .SwipingLeftToRight: str = "SwipeingLeftToRight"
        case .SwipingRightToLeft: str = "SwipingRightToLeft"
        case .ExpandingLeftToRight: str = "ExpandingLeftToRight"
        case .ExpandingRightToLeft: str = "ExpandingRightToLeft"
        }
        
        active = (gestureIsActive) ? "Active" : "Ended"
        NSLog("Swipe state: \(str) ::: Gestrue: \(active)")
    }

}