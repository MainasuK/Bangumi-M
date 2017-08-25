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

    let transition = LoginViewPresentTransition()
    
    fileprivate lazy var model: Model = {
        return Model(tableView: self.tableView)
    }()
    fileprivate var dataSource: TableViewDataSource<Model, Cell>!
    fileprivate var isFirstRefresh = true
    fileprivate var hasTriedLogin = false
    
    @IBAction func unwindToAnimeListTableViewController(_ segue: UIStoryboardSegue) {
        
    }
    
    @objc fileprivate func avatarButtonPressed() {
        
        guard let user = BangumiRequest.shared.user else {
            popLoginController()
            return
        }
        
        let alertController = UIAlertController(title: "\(user.nickname)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            // ...
        }
        
        let logoutAction = UIAlertAction(title: NSLocalizedString("sign out", comment: ""), style: .destructive) { _ in
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
    
    fileprivate func popLoginController() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.LoginViewController) as! LoginViewController
        
        loginViewController.delegate = self
        loginViewController.transitioningDelegate = self
        loginViewController.modalPresentationStyle = .overCurrentContext
//        loginViewController.modalTransitionStyle = .crossDissolve

        if !UIAccessibilityIsReduceTransparencyEnabled() {
            loginViewController.view.backgroundColor = UIColor.clear
        }
        
        present(loginViewController, animated: true)
    }
    
}

// MARK: - UITableView Setup method
extension AnimeListTableViewController {
    
    fileprivate func setupBarButtonItem() {
        let button: UIButton = {
            let btn = UIButton(type: .custom)
            
            btn.setImage(UIImage.fromColor(.placeholder, size: CGSize(width: 30, height: 30)), for: .normal)
            if let avatarLargeUrl = BangumiRequest.shared.user?.avatar.largeUrl,
            let url = URL(string: avatarLargeUrl) {
                btn.af_setImage(for: .normal, url: url)
            }
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.imageView?.frame.size = CGSize(width: 30, height: 30)
            btn.addTarget(self, action: #selector(AnimeListTableViewController.avatarButtonPressed), for: .touchUpInside)
            btn.imageView?.layer.cornerRadius = 30 * 0.5
            btn.imageView?.layer.borderColor = UIColor.percolatorLightGray.cgColor
            btn.imageView?.layer.borderWidth = 0.5   // 1px
            
            return btn
        }()
        
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    fileprivate func setupTableView() {
        // Setup dataSource and link model
        setupTableViewDataSource()
        
        // Configure tableView row height
//        tableView.estimatedRowHeight = 150
//        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = 150
        
        // Set cell conform readable layout margin
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Configure tableView appearance
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = UIColor.myAnimeListBackground
        
        // Fix the separator display when 0 rows
        tableView.tableFooterView = UIView()
        
        // Set refresh header
        setupTableViewHeader()
        
    }
    
    fileprivate func setupTableViewHeader() {
        tableView.mj_header = {
            //  Use unowned because the caller is self. No async
            let header = MJRefreshNormalHeader { [unowned self] in
                self.refreshAnimeList()
            }
            
            return header
        }()
    }
    
    fileprivate func setupTableViewDataSource() {
        dataSource = TableViewDataSource<Model, Cell>(model: model)
        tableView.dataSource = dataSource
    }
    
}

// MARK: - View Life Cycle
extension AnimeListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupBarButtonItem()
        
        guard User.isLogin() else {
            if !hasTriedLogin {
                hasTriedLogin = true
                popLoginController()
            }
            
            return
        }
        
        if isFirstRefresh {
            tableView.mj_header.beginRefreshing()
        }
        isFirstRefresh = false
    }
    
}

extension AnimeListTableViewController {
    
    typealias CollectionError = BangumiRequest.CollectionError
    typealias RequestError = BangumiRequest.RequestError
    typealias UnknownError = BangumiRequest.Unknown
    typealias NetworkError = BangumiRequest.NetworkError
    typealias ModelError = AnimeListTableViewModel.ModelError

    // swiftlint:disable function_body_length
    func refreshAnimeList() {
        
        model.refresh { (error: Error?) in
            
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
                
            } catch RequestError.userNotLogin {
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
                    let alertController = UIAlertController(
                        title: NSLocalizedString("please check your network connection status", comment: ""),
                        message: NSLocalizedString("make sure that the network can be connected to bgm.tv", comment: ""),
                        preferredStyle: .alert
                    )
                    let cancelAction = UIAlertAction(title: NSLocalizedString("dismiss", comment: ""), style: .cancel) { _ in
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
                self.present(PercolatorAlertController.notConnectedToInternet(), animated: true, completion: nil)
                
            } catch NetworkError.dnsLookupFailed {
                self.present(PercolatorAlertController.dnsLookupFailed(), animated: true, completion: nil)
                consolePrint("NetworkError DNS Lookup Failed: \(error?.localizedDescription ?? "unknown")")
                
            } catch UnknownError.alamofire(let error) {
                self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
                consolePrint("Unknow NSError: \(error)")
                
            } catch UnknownError.network(let error) {
                self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
                consolePrint("Unknow NSURLError: \(error)")
                
            } catch {
                // Really? I think never got here.
                // All error wrapped appropriately above …
                self.present(PercolatorAlertController.unknown(error), animated: true, completion: nil)
                consolePrint("Unresolve case: \(error)")
            }
        }
        //
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
        cell.cardView.layer.shadowColor     = UIColor.black.cgColor
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
        
        // Mask infolView for get two top corners
        cell.infoView.layer.mask = {
            let maskLayer = CAShapeLayer()
            let maskPath = UIBezierPath(roundedRect: cell.infoView.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 5, height: 5))
            
            maskLayer.frame = cell.infoView.bounds
            maskLayer.path  = maskPath.cgPath
            
            return maskLayer
        }()
        
        cell.layoutIfNeeded()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.DetialTableViewControllerKey) as! DetailTableViewController
        let subject = model.item(at: indexPath).0
        detailTableViewController.subject = subject
        
        navigationController?.pushViewController(detailTableViewController, animated: true)
    }
    
}

// MARK: - UIContentContainer
extension AnimeListTableViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // For re-calculate cell shadow path
            self.tableView.reloadData()
        }, completion: nil)
    }
    
}

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

// MARK: - AnimeListTableViewCellDelegate
extension AnimeListTableViewController: AnimeListTableViewCellDelegate {
    
    func watchedButtonPressed(_ sender: UIButton, with mark: AnimeMark) {
        switch mark {
        case .episode(let ep, let subject):
            model.mark(ep, of: subject, handler: { (error: Error?) in
                do {
                    try error?.throwMyself()
                    
                    SVProgressHUD.showSuccess(withStatus: "EP.\(ep.sortString) \(ep.name) 标记成功")
                    
                } catch ModelError.mark {
                    let title = NSLocalizedString("mark error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "未能标注 EP.\(ep.sortString) \(ep.nameCN)")
                    self.present(alertController, animated: true, completion: nil)
                    
                } catch NetworkError.notConnectedToInternet {
                    self.present(PercolatorAlertController.notConnectedToInternet(), animated: true, completion: nil)
                    
                } catch NetworkError.timeout {
                    self.present(PercolatorAlertController.timeout(withDescription: "未能标注 EP.\(ep.sortString) \(ep.nameCN)"), animated: true, completion: nil)
                    
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

// MARK: - UIViewControllerTransitioningDelegate
extension AnimeListTableViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }

}
