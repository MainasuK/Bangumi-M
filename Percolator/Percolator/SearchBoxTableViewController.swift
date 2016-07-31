//
//  SearchBoxTableViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-19.
//
//

import UIKit
import MJRefresh
import SVProgressHUD
import MGSwipeTableCell

final class SearchBoxTableViewController: UITableViewController {
    
    typealias Model = SearchBoxTableViewModel
    typealias Cell = SearchBoxTableViewCell
    
    private lazy var model: Model = {
        return Model(tableView: self.tableView)
    }()
    private var dataSource: TableViewDataSource<Model, Cell>!
    
    private lazy var searchController: UISearchController = { [weak self] in
        let controller = UISearchController(searchResultsController: nil)
        
        controller.delegate = self
        controller.searchBar.delegate = self
        controller.searchResultsUpdater = self
        
        controller.searchBar.scopeButtonTitles = PercolatorKey.searchTypeArr
        
        controller.dimsBackgroundDuringPresentation = true
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.enablesReturnKeyAutomatically = false
        
        // Note: Override UISearchController preferredStatusBarStyle() method return .lightContent
        controller.searchBar.barTintColor = UIColor.navigationBarBlue()
        controller.searchBar.tintColor = UIColor.white()
        controller.searchBar.placeholder = "条目搜索"
        
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.backgroundColor = UIColor.white().withAlphaComponent(0.7)
        textFieldAppearance.tintColor = UIColor.lightText()
        
        return controller
    }()
    private var searchScopeIndex = 0
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBAction func searchButtonClicked(_ button: UIBarButtonItem?) {
        
        // Make sure Search text based on last search content
        let title = self.navigationItem.title
        searchController.searchBar.text = (title == "搜索盒子") ? "" : title
        
        // Present the view controller
        present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func longPressTrigger(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
        let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)) else {
            // FIXME:
            return
        }
        let (subject, _) = model.item(at: indexPath)
        
        let alertController = UIAlertController(title: "\(subject.name)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action) in
            // ...
        }
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { (action) in
            // FIXME: error info need here?
            if subject.saveToCoreData() {
                SVProgressHUD.showSuccess(withStatus: "保存成功")
            } else {
                SVProgressHUD.showInfo(withStatus: "保存失败")
            }
            self.tableView.reloadRows(at: [indexPath], with: .none)
            
        }
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { (action) in
            let isSuccess = self.model.removeItem(at: indexPath)
            if isSuccess {
                SVProgressHUD.showSuccess(withStatus: "删除成功")
            } else {
                SVProgressHUD.showInfo(withStatus: "删除失败")
            }
        }
        
        let collectAction = UIAlertAction(title: "收藏", style: .default) { (action) in
            let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.CollectNavigationController) as! UINavigationController
            let collectTableViewController = navigationController.childViewControllers.first as! CollectTableViewController
            collectTableViewController.subject = subject
            
            navigationController.modalPresentationStyle = .formSheet
            
            DispatchQueue.main.async {
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(collectAction)
    
        if subject.isSaved() {
            alertController.addAction(deleteAction)
        } else {
            alertController.addAction(saveAction)
        }
    
        // Configure the alert controller's popover presentation controller if it has one
        if let popoverPresentationController = alertController.popoverPresentationController,
            let cell = tableView.cellForRow(at: indexPath) {
            popoverPresentationController.sourceRect = cell.frame
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        consolePrint("SearchBoxTableViewController deinit")
    }
    
}

// MARK: - UITableView Setup method
extension SearchBoxTableViewController {
    
    private func setupTableView() {
        // Set navigation bar title
        title = "搜索盒子"
        
        // Setup dataSource and link model
        setupTableViewDataSource()
        
        // Set self size cell height
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Fix the separator display when 0 rows
        tableView.tableFooterView = UIView()
        
        // Set cell conform readable layout margin
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Configure tableView appearance
        tableView.backgroundColor = UIColor.myAnimeListBackground()
        
        // Set Refresh footer
        setupTableViewFooter()
    }
    
    private func setupTableViewFooter() {
        tableView.mj_footer = {
            //  Use unowned because the caller is self. No async
            let footer = MJRefreshAutoNormalFooter { [unowned self] in
                if let text = self.searchController.searchBar.text {
                self.search(for: text, type: self.searchScopeIndex)
                }
            }
            footer?.isHidden = true // Appeare after search
            
            return footer
        }()
    }
    
    private func setupTableViewDataSource() {
        dataSource = TableViewDataSource<Model, Cell>(model: model)
        tableView.dataSource = dataSource
    }
}

// MARK: - View Life Cycle
extension SearchBoxTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if model.isEmpty { searchButtonClicked(nil) }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
}

// MARK: - UITableViewDelegate
extension SearchBoxTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let detailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.DetialTableViewControllerKey) as! DetailTableViewController
        detailTableViewController.subject = model.item(at: indexPath).0
        navigationController?.pushViewController(detailTableViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let swipeCell = cell as? MGSwipeTableCell {
            swipeCell.delegate = self
        }
    }

}

// MARK: - UISearchBarDelegate
extension SearchBoxTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        defer {
            searchController.dismiss(animated: true, completion: nil)
        }
        
        // Check if user type nothing
        guard let searchText = searchBar.text, searchBar.text != "" else {
            return
        }
        
        // Set navigation bar title and show HUD
        title = searchText
        SVProgressHUD.show()
        
        searchScopeIndex = searchBar.selectedScopeButtonIndex ?? 0
        search(for: searchText, type: searchScopeIndex)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Resume selected button
        searchBar.selectedScopeButtonIndex = searchScopeIndex
    }

}

// MARK: - UISearchResultsUpdating
extension SearchBoxTableViewController: UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        // TODO:
    }
    
}

// MARK: - UISearchControllerDelegate
extension SearchBoxTableViewController: UISearchControllerDelegate {
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setNeedsStatusBarAppearanceUpdate()
    }

}

// MARK: - Search method
extension SearchBoxTableViewController {
    
    typealias ModelError = Model.ModelError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias UnknownError = BangumiRequest.Unknown
    
    private func search(for text: String, type scopeIndex: Int) {
        searchButton.isEnabled = false
        
        let searchScopeType =  PercolatorKey.searchTypeDict[scopeIndex] ?? 0
        
        // Handle error from model
        // Model deal with data source and reload tableView
        model.search(for: text, type: searchScopeType) { (error: ErrorProtocol?) in
            
            defer {
                SVProgressHUD.dismiss(withDelay: 3.0)
                self.searchButton.isEnabled = true
            }
            
            do {

                // Too many errors to catch…
                // Be careful hurt youself
                do {
                    try error?.throwMyself()
                    
                    // No error
                    consolePrint("Search success")
                    self.tableView.mj_footer?.isHidden = false
                    self.tableView.mj_footer.isAutomaticallyHidden = true
                    self.tableView.mj_footer.resetNoMoreData()
                    SVProgressHUD.dismiss()
                    
                } catch ModelError.noMoreData {
                    consolePrint("Search no more data")
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    
                } catch ModelError.needRetry {
                    consolePrint("Retry search")
                    SVProgressHUD.show()
                    delay(1.0) {
                        self.tableView.mj_footer.resetNoMoreData()
                        self.search(for: text, type: searchScopeType)
                    }
                    
                } catch ModelError.noResult {
                    consolePrint("Search not found")
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    let status = NSLocalizedString("no result", comment: "")
                    delay(1.0) {
                        SVProgressHUD.showInfo(withStatus: status)
                    }
                    
                } catch UnknownError.API(let error, let code) {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    
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
                
            }   // end do
        }
        
    }
    
    //    private func fetchLocalData() {
    
    //        let fetchRequest = NSFetchRequest(entityName: "Subject")
    //        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
    //        fetchRequest.sortDescriptors = [sortDescriptor]
    //
    //        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
    //
    //            Subject.fetchSubject({ (animeSubjectArr) -> Void in
    //
    //                if animeSubjectArr != nil {
    //                    self.searchModel.subjectLocalList = animeSubjectArr!
    //                }
    //            })
    //        }
    //    }
    
}


// MARK: - MGSwipeTableCellDelegate
extension SearchBoxTableViewController: MGSwipeTableCellDelegate {
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        guard let cell = cell,
        let indexPath = self.tableView.indexPath(for: cell) else {
            return []
        }
        
        let subject = self.model.item(at: indexPath).0
        
        swipeSettings.transition = MGSwipeTransition.drag
        swipeSettings.threshold = 0.1
        expansionSettings.buttonIndex = 0
        expansionSettings.fillOnTrigger = true
        expansionSettings.threshold = 2.0
        
        let saveBlue = UIColor(red: 0, green: 0x99/255.0, blue:0xcc/255.0, alpha: 1.0)
        let collectionYellow = UIColor(red: 253.0/255.0, green: 204.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        let deleteRed = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        
        let saveButton = MGSwipeButton(title: "保存", backgroundColor: saveBlue, padding: 25) { [weak self] (cell: MGSwipeTableCell?) -> Bool in
            let _ = subject.saveToCoreData()
            self?.tableView.reloadRows(at: [indexPath], with: .right)
            
            return false
        }
        
        let collectionButton = MGSwipeButton(title: "收藏", backgroundColor: collectionYellow, padding: 25) { [weak self] (cell: MGSwipeTableCell?) -> Bool in
            
            
            let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.CollectNavigationController) as! UINavigationController
            let collectTableViewController = navigationController.childViewControllers.first as! CollectTableViewController
            collectTableViewController.subject = subject
            
            navigationController.modalPresentationStyle = .formSheet
            self?.present(navigationController, animated: true, completion: nil)
            self?.tableView.reloadRows(at: [indexPath], with: .right)
            
            return false
        }
        
        let deleteButton = MGSwipeButton(title: "删除", backgroundColor: deleteRed, padding: 25) { [weak self] (cell: MGSwipeTableCell?) -> Bool in
            
            let _ = self?.model.removeItem(at: indexPath)
            return false
        }
        
        switch direction {
        case .leftToRight:
            return (subject.isSaved()) ? [collectionButton!] : [saveButton!, collectionButton!]
            
        case .rightToLeft:
            return (subject.isSaved()) ? [deleteButton!] : []
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, didChange state: MGSwipeState, gestureIsActive: Bool) {
        var str = ""
        var active = ""
        switch state {
        case .none: str = "None"
        case .swipingLeftToRight: str = "SwipeingLeftToRight"
        case .swipingRightToLeft: str = "SwipingRightToLeft"
        case .expandingLeftToRight: str = "ExpandingLeftToRight"
        case .expandingRightToLeft: str = "ExpandingRightToLeft"
        }
        
        active = (gestureIsActive) ? "Active" : "Ended"
        consolePrint("Swipe state: \(str) ::: Gestrue: \(active)")
    }

}
