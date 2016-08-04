//
//  SubjecttCollectionViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import SVProgressHUD

final class SubjectCollectionViewController: UICollectionViewController {
    
    typealias Model = SubjectCollectionViewModel
    typealias Cell = SubjectCollectionViewCell
    typealias Header = SubjectCollectionReusableHeaderView
    
    @IBOutlet var subjectCollectionView: UICollectionView!
    private var model: Model!
    private var dataSource: CollectionViewDataSource<Model, Cell, Header>!
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
    typealias UnknownError = BangumiRequest.Unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableViewDataSource()
        
        title = "相关条目"
        collectionView?.backgroundColor = UIColor.myAnimeListBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if isFirstAppear {
            SVProgressHUD.show()
            model.fetchRelatedSubjects { (error: Error?) in
                delay(3.0) {
                    SVProgressHUD.dismiss()
                }
                
                do {
                    try error?.throwMyself()
                    SVProgressHUD.dismiss()
                    
                } catch ModelError.parse {
                    let alertController = UIAlertController.simpleErrorAlert(with: "数据解析失败", description: "")
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Parse error")
                    
                } catch ModelError.noItem {
                    SVProgressHUD.showInfo(withStatus: "无相关条目")
                    
                } catch UnknownError.API(let error, let code) {
                    let title = NSLocalizedString("server error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("API error: \(error), code: \(code)")
                    
                } catch NetworkError.timeout {
                    let status = NSLocalizedString("time out", comment: "")
                    SVProgressHUD.showInfo(withStatus: status)
                    consolePrint("Timeout")
                    
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
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "NSURLError", code: error.code.rawValue)
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Unknow NSURLError: \(error)")
                    
                } catch {
                    let title = NSLocalizedString("unknown error", comment: "")
                    let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
                    self.present(alertController, animated: true, completion: nil)
                    consolePrint("Unresolve case: \(error)")
                }   // end do-catch block
            }
            
            isFirstAppear = false
        }
    }

}

extension SubjectCollectionViewController {
    
    private func setupTableViewDataSource() {
        model = SubjectCollectionViewModel(collectionView: subjectCollectionView, with: subject)
        dataSource = CollectionViewDataSource<Model, Cell, SubjectCollectionReusableHeaderView>(model: model)
        subjectCollectionView.dataSource = dataSource
    }
    
}

// MARK: - UICollectionViewDelegate
extension SubjectCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let subjectIDStr = model.item(at: indexPath).urlPath.components(separatedBy: "/").last,
        let subjectID = Int(subjectIDStr) else {
            // FIXME:
            return
        }
        
        // FIXME: Need put in model? or KISS?
        
        SVProgressHUD.show()
        BangumiRequest.shared.subject(of: subjectID, with: .large) { (result: Result<Subject>) in
            delay(3.0) {
                SVProgressHUD.dismiss()
            }
            
            do {
                let subject = try result.resolve()
                
                let detailTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardKey.DetialTableViewControllerKey) as! DetailTableViewController
                detailTableViewController.subject = subject
                SVProgressHUD.dismiss()
                
                self.navigationController?.pushViewController(detailTableViewController, animated: true)
                
            } catch UnknownError.API(let error, let code) {
                let title = NSLocalizedString("server error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                self.present(alertController, animated: true, completion: nil)
                consolePrint("API error: \(error), code: \(code)")
                
            } catch NetworkError.timeout {
                let status = NSLocalizedString("time out", comment: "")
                SVProgressHUD.showInfo(withStatus: status)
                consolePrint("Timeout")
                
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
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "NSURLError", code: error.code.rawValue)
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unknow NSURLError: \(error)")
                
            } catch {
                let title = NSLocalizedString("unknown error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "", code: -1)
                self.present(alertController, animated: true, completion: nil)
                consolePrint("Unresolve case: \(error)")
            }   // end do-catch block
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension SubjectCollectionViewController {
    
    // Custom item size to layout view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        switch indexPath.section {
        // Book section
        case 0:
            let margin: CGFloat = 0
            let minSpacing: CGFloat = 1
            let width: CGFloat =  {
                if traitCollection.horizontalSizeClass == .compact {
                    return collectionView.bounds.width - 2.0 * margin
                } else {
                    return (collectionView.bounds.width - minSpacing - 2.0 * margin) * 0.5
                }
            }()
            let height: CGFloat = 66        // imageHeight + topMargin + bottomMargin
            
            return CGSize(width: width, height: height)
            
        // Not book section
        default:
            let width: CGFloat = 96
            let height: CGFloat = 180
            
            return CGSize(width: width, height: height)
        }
    }
    
    // Custom section margin
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        switch section {
        // Book section
        case 0:
            return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        // Not book section
        default:
            return UIEdgeInsets(top: 0, left: 10, bottom: 8, right: 10)
        }
    }
    
    // Custom item line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        switch section {
        // Book section
        case 0:
            return 1
            
        // Not book section
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if model.numberOfItems(in: section) == 0 {
            return CGSize(width: collectionView.bounds.width, height: 0)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
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
