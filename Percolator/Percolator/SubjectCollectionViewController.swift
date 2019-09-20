//
//  SubjecttCollectionViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import SVProgressHUD
import IGListKit

final class SubjectCollectionViewController: UICollectionViewController {
    
    typealias Model = SubjectCollectionViewModel
    typealias Cell = SubjectCollectionViewCell
    typealias Header = SubjectCollectionReusableHeaderView
    
    @IBOutlet var subjectCollectionView: UICollectionView!

    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    private var model: Model!
    private var isFirstAppear = true
    
    var subject: Subject!
    
    deinit {
        consolePrint("SubjectCollectionViewController deinit")
    }
}

// MARK: - View Life Cycle
extension SubjectCollectionViewController {
    
    typealias ModelError = SubjectCollectionViewModel.ModelError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias HTMLError = BangumiRequest.HTMLError
    typealias UnknownError = BangumiRequest.Unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableViewDataSource()

        title = "相关条目"
        
        if let barFont = UIFont(name: "PingFangSC-Medium", size: 17.0) {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font : barFont]
        }
        
        collectionView?.backgroundColor = .systemGroupedBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstAppear {
            SVProgressHUD.show()
            model.fetchRelatedSubjects { (error: Error?) in
                
                do {
                    try error?.throwMyself()
                    SVProgressHUD.dismiss()
                    
                } catch ModelError.parse {
                    let alertController = UIAlertController.simpleErrorAlert(with: "数据解析失败", description: "")
                    SVProgressHUD.dismiss()
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Parse error")
                    
                } catch ModelError.noItem {
                    SVProgressHUD.showInfo(withStatus: "无相关条目")
                    
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
                    SVProgressHUD.dismiss()
                    self.present(PercolatorAlertController.notConnectedToInternet(), animated: true, completion: nil)
                
                } catch HTMLError.notHTML {
                    SVProgressHUD.dismiss()
                    let title = NSLocalizedString("can't recognize this web page format", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "")
                    SVProgressHUD.dismiss()
                    self.present(alertController, animated: true, completion: nil)
                    
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

}

extension SubjectCollectionViewController {
    
    fileprivate func setupTableViewDataSource() {
        adapter.collectionView = subjectCollectionView
        model = SubjectCollectionViewModel(collectionView: subjectCollectionView, of: adapter, with: subject)
        adapter.dataSource = model
    }
    
}

// MARK: - UIContentContainer
extension SubjectCollectionViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Make layout respond to size class change
        collectionView?.reloadData()
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
}
