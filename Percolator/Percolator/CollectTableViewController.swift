//
//  AnimeCollectTableViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-7-25.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Cosmos
import SVProgressHUD

// It's convenient to embed model in static table view controller
final class CollectTableViewController: UITableViewController {
    
    private let request = BangumiRequest.shared
    
    var subject: Subject!
    var isNeedComment = false   // Set this flag to carry user to the comment text view
    
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var collectSegmentedControl: UISegmentedControl!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var tagView: TagWriteView!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var collectBoxTableViewCell: UITableViewCell!
    @IBOutlet weak var privacyTableViewCell: UITableViewCell!
    
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    

    @IBAction func CancelButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButtonItemPressed(_ sender: UIBarButtonItem) {

        sender.isEnabled = false
        
        var method = CollectInfo.StatusType.doing
        switch collectSegmentedControl.selectedSegmentIndex {
        case 2: method = .doing
        case 3: method = .hold
        case 4: method = .dropped
        case 0: method = .wish
        case 1: method = .collect
        default:
            sender.isEnabled = true
            SVProgressHUD.showInfo(withStatus: "请先标注条目")
            return
        }   // switch …

        let rating: Int? = (Int)(cosmosView.rating)
        let comment = commentTextView.text
        let tags = tagView.tags

        SVProgressHUD.show()
        request.updateCollection(of: subject.id, with: method, rating, comment, tags, isPrivacy: privacySwitch.isOn) { (result: Result<CollectInfo>) in
            
            defer {
                delay(3.0, handler: {
                    sender.isEnabled = true
                })
            }
            
            do {
                let _ = try result.resolve()
                SVProgressHUD.showSuccess(withStatus: "保存成功")
                SVProgressHUD.dismiss(withDelay: 3.0)
                self.dismiss(animated: true, completion: nil)
                
            } catch ReqeustError.userNotLogin {
                let title = NSLocalizedString("please login", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "")
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                consolePrint("User not login")
                
            } catch CollectionError.unauthorized {
                let title = NSLocalizedString("authorize failed", comment: "")
                let desc = NSLocalizedString("try login again", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: desc)
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unauthorized")
                
            } catch UnknownError.API(let error, let code) {
                let title = NSLocalizedString("server error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                consolePrint("API error: \(error), code: \(code)")
                
            } catch NetworkError.timeout {
                let status = NSLocalizedString("time out", comment: "")
                SVProgressHUD.showInfo(withStatus: status)
                consolePrint("Timeout")
                
            } catch NetworkError.notConnectedToInternet {
                let title = NSLocalizedString("not connected to internet", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "Not connected to internet")
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                
            } catch UnknownError.alamofire(let error) {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error.description)", code: error.code)
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unknow NSError: \(error)")
                
            } catch UnknownError.network(let error) {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "NSURLError", code: error.code.rawValue)
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unknow NSURLError: \(error)")
                
            } catch {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unresolve case: \(error)")
            }   // end do-catch block
        }
    }
    
    deinit {
        consolePrint("CollectTableViewController deinit")
    }

}


// MARK: - Tableview setup method
extension CollectTableViewController {
    
    private func setupTableView() {
        
        // Configure tableView row height
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        collectBoxTableViewCell.preservesSuperviewLayoutMargins = true
        collectBoxTableViewCell.contentView.preservesSuperviewLayoutMargins = true
        privacyTableViewCell.preservesSuperviewLayoutMargins = true
        privacyTableViewCell.contentView.preservesSuperviewLayoutMargins = true
    }
    
    private func setupControlItem() {
        tagView.setDeleteButtonBackgroundImage(UIImage(named: "btn_tag_delete"), state: .normal)
        tagView.backgroundColor = UIColor.clear
        tagView.verticalInsetForTag = UIEdgeInsetsMake(9, 8, 6, 0);
        tagView.allowToUseSingleSpace = false
        
        commentTextView.delegate = self
        
        collectSegmentedControl.isEnabled = false
        switch subject.type {
        case 0: break
        case 1:         // Book
            collectSegmentedControl.setTitle("想读", forSegmentAt: 0)
            collectSegmentedControl.setTitle("读过", forSegmentAt: 1)
            collectSegmentedControl.setTitle("在读", forSegmentAt: 2)
        case 2:         // Anime
            break
        case 3:         // Music
            collectSegmentedControl.setTitle("想听", forSegmentAt: 0)
            collectSegmentedControl.setTitle("听过", forSegmentAt: 1)
            collectSegmentedControl.setTitle("在听", forSegmentAt: 2)
        case 4:         // Game
            collectSegmentedControl.setTitle("想玩", forSegmentAt: 0)
            collectSegmentedControl.setTitle("玩过", forSegmentAt: 1)
            collectSegmentedControl.setTitle("在玩", forSegmentAt: 2)
        case 5:
            break
        case 6:         // Oh…
            break
        default:
            break
        }
        
        cosmosView.isUserInteractionEnabled = false
        cosmosView.settings.fillMode = .full
        cosmosView.settings.updateOnTouch = true
        cosmosView.settings.minTouchRating = 0.0
        cosmosView.didTouchCosmos = { [weak self] (rating: Double) in
            var text = ""
            
            if Int(rating) != 0 {
                text = "\(Int(rating)) 星"
            } else {
                text = "不评价"
            }
            self?.tableView.footerView(forSection: 1)?.textLabel?.text = text
        }
    }
    
}

// MARK: - View Life Cycle
extension CollectTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupControlItem()
        fetchCollectionInfo()
    }
    
}

extension CollectTableViewController {
    
    typealias ReqeustError = BangumiRequest.RequestError
    typealias CollectionError = BangumiRequest.CollectionError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias UnknownError = BangumiRequest.Unknown
    
    private func fetchCollectionInfo() {
        title = "少女祈祷中…"
        NetworkSpinner.on()
        SVProgressHUD.show()
        saveButtonItem.isEnabled = false
        
        request.collection(of: subject.id) { (result: Result<CollectInfo>) in
            NetworkSpinner.off()
            
            do {
                let info = try result.resolve()
                self.freshControlItem(with: info)
                SVProgressHUD.dismiss()
                
            } catch ReqeustError.userNotLogin {
                SVProgressHUD.dismiss()
                let title = NSLocalizedString("please login", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "")
                self.present(alertController, animated: true, completion: nil)
                consolePrint("User not login")
            
            } catch CollectionError.noCollection {
                SVProgressHUD.showInfo(withStatus: "未标记条目")
                self.saveButtonItem.isEnabled = true
                self.collectSegmentedControl.isEnabled = true
                self.cosmosView.isUserInteractionEnabled = true
                self.title = self.subject.name
                
            } catch CollectionError.unauthorized {
                SVProgressHUD.dismiss()
                let title = NSLocalizedString("authorize failed", comment: "")
                let desc = NSLocalizedString("try login again", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: desc)
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unauthorized")
                
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
        
    }
    
    private func freshControlItem(with info: CollectInfo) {
        title = subject.name
        
        saveButtonItem.isEnabled = true
        cosmosView.isUserInteractionEnabled = true
        collectSegmentedControl.isEnabled = true
        
        switch info.type {
        case .doing:        self.collectSegmentedControl.selectedSegmentIndex = 2
        case .hold:         self.collectSegmentedControl.selectedSegmentIndex = 3
        case .dropped:      self.collectSegmentedControl.selectedSegmentIndex = 4
        case .wish:         self.collectSegmentedControl.selectedSegmentIndex = 0
        case .collect:      self.collectSegmentedControl.selectedSegmentIndex = 1
        }   // end switch
        
        cosmosView.rating = (Double)(info.rating)
        self.tableView.footerView(forSection: 1)?.textLabel?.text = (info.rating != 0) ? "\(info.rating) 星" : "未评价"
        
        if info.tags != [""] { tagView.addTags(info.tags) }
        commentTextView.text = info.comment
        
        if isNeedComment { commentTextView.becomeFirstResponder() }
    }
}

// MARK: - UITextViewDelegate
extension CollectTableViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if range.length >= 200 { return false }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }

}
