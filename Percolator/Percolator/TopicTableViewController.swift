//
//  TopicTableViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import SafariServices
import SVProgressHUD

class TopicTableViewController: UITableViewController {
    
    typealias Model = TopicTableViewModel
    typealias Cell = TopicTableViewCell

    private var model: Model!
    private var dataSource: TableViewDataSource<Model, Cell>!
    private var isFirstAppear = true
    var subject: Subject!
    
    deinit {
        consolePrint("TopicTableViewController deinit")
    }
}

// MARK: - View Life Cycle
extension TopicTableViewController {
    
    typealias ModelError = TopicTableViewModel.ModelError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias UnknownError = BangumiRequest.Unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupTableViewDataSource()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstAppear {
            SVProgressHUD.show()
            model.fetchTopics { (error: Error?) in
                
                do {
                    try error?.throwMyself()
                    SVProgressHUD.dismiss()
                    
                } catch ModelError.parse {
                    SVProgressHUD.dismiss()
                    let alertController = UIAlertController.simpleErrorAlert(with: "数据解析失败", description: "")
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Parse error")
                    
                } catch ModelError.noItem {
                    SVProgressHUD.showInfo(withStatus: "无相关话题")
                    
                } catch UnknownError.API(let error, let code) {
                    SVProgressHUD.dismiss()
                    let title = NSLocalizedString("server error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("API error: \(error), code: \(code)")
                    
                } catch NetworkError.timeout {
                    SVProgressHUD.dismiss()
                    let status = NSLocalizedString("time out", comment: "")
                    SVProgressHUD.showInfo(withStatus: status)
                    consolePrint("Timeout")
                    
                } catch NetworkError.notConnectedToInternet {
                    SVProgressHUD.dismiss()
                    let title = NSLocalizedString("not connected to internet", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "Not connected to internet")
                    self.present(alertController, animated: true, completion: nil)
                    
                } catch UnknownError.alamofire(let error) {
                    SVProgressHUD.dismiss()
                    let title = NSLocalizedString("unknown error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error.description)", code: error.code)
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Unknow NSError: \(error)")
                    
                } catch UnknownError.network(let error) {
                    SVProgressHUD.dismiss()
                    let title = NSLocalizedString("unknown error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "NSURLError", code: error.code.rawValue)
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Unknow NSURLError: \(error)")
                    
                } catch {
                    SVProgressHUD.dismiss()
                    let title = NSLocalizedString("unknown error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Unresolve case: \(error)")
                }   // end do-catch block    

            }
            
            isFirstAppear = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
}

extension TopicTableViewController {
    
    private func setupTableViewDataSource() {
        model = TopicTableViewModel(tableView: tableView, with: subject)
        dataSource = TableViewDataSource<Model, Cell>(model: model)
        tableView.dataSource = dataSource
    }
    
    private func setupTableView() {
        
        title = "相关话题"
        
        // Configure tableView appearance
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.myAnimeListBackground
        
        // Configure cell row height
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Register section header view
//        let nib = UINib(nibName: StoryboardKey.TopicTableViewHeaderFooterView, bundle: nil)
//        tableView.register(nib, forHeaderFooterViewReuseIdentifier: StoryboardKey.TopicTableViewHeaderFooterView)
    }
    
}

extension TopicTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let urlPath = model.item(at: indexPath).urlPath
        guard let lastSplit = urlPath.components(separatedBy: "/").last,
        let url = URL(string: "http://bangumi.tv/m/topic/subject/\(lastSplit)") else {
            return
        }
        
        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
}



