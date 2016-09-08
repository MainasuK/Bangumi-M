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

final class TopicTableViewController: UITableViewController {
    
    typealias Model = TopicTableViewModel
    typealias Cell = TopicTableViewCell

    fileprivate var model: Model!
    fileprivate var dataSource: TableViewDataSource<Model, Cell>!
    fileprivate var isFirstAppear = true
    var subject: Subject!
    
    deinit {
        consolePrint("TopicTableViewController deinit")
    }
}

// MARK: - View Life Cycle
extension TopicTableViewController {
    
    typealias ModelError = TopicTableViewModel.ModelError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias HTMLError = BangumiRequest.HTMLError
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
                    consolePrint("Time out")
                    
                } catch NetworkError.notConnectedToInternet {
                    SVProgressHUD.dismiss()
                    self.present(PercolatorAlertController.notConnectedToInternet(), animated: true, completion: nil)
                    consolePrint("Not Connected to Internet")
                    
                } catch HTMLError.notHTML {
                    SVProgressHUD.dismiss()
                    let title = NSLocalizedString("can't recognize this web page format", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title)
                    SVProgressHUD.dismiss()
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Not HTML format")
                
                } catch UnknownError.alamofire(let error) {
                    SVProgressHUD.dismiss()
                    self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
                    consolePrint("Unknow NSError: \(error)")
                    
                } catch UnknownError.network(let error) {
                    SVProgressHUD.dismiss()
                    self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
                    consolePrint("Unknow NSURLError: \(error)")
                    
                } catch {
                    SVProgressHUD.dismiss()
                    self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
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
    
    fileprivate func setupTableViewDataSource() {
        model = TopicTableViewModel(tableView: tableView, with: subject)
        dataSource = TableViewDataSource<Model, Cell>(model: model)
        tableView.dataSource = dataSource
    }
    
    fileprivate func setupTableView() {
        
        title = "相关话题"
        
        if let barFont = UIFont(name: "PingFangSC-Medium", size: 17.0) {
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : barFont]
        }
        
        // Configure tableView appearance
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.myAnimeListBackground
        
        // Configure cell row height
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
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



