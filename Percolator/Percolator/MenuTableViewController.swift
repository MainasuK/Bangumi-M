//
//  MenuTableViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-11.
//
//

import UIKit
import SafariServices

final class MenuTableViewController: UITableViewController {
    
    @IBAction func superTopicButtonPressed(sender: AnyObject) {
        
        let url = "http://bangumi.tv/m"
        
        // Update UI in main thread to eliminate lag
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.revealViewController().revealToggle(nil)
            
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(URL: NSURL(string: url)!)
                svc.delegate = self
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
                self.presentViewController(svc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            }
        })
    }
    @IBAction func aboutmeButtonPressed(sender: AnyObject) {
    }
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        
        User.deleteUserInfo()
        BangumiAnimeModel.shared.dropModel()
        BangumiFavoriteModel.shared.dropModel()
        BangumiRequest.shared.userData = nil
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.loginVC) as! LoginViewController
        loginVC.delegate = self
        
        NSNotificationCenter.defaultCenter().postNotificationName("userLogout", object: nil)
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
    deinit {
        NSLog("MenuTableViewController deinit")
    }
}

// MARK: - View Life Cycle
extension MenuTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

// MARK: - MenuTransitionDelegate
extension MenuTableViewController: MenuTransitionDelegate {
    
    func dismissLoginVC() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.revealViewController().revealToggle(nil)
        })
    }
    
}

// MARK: - SFSafariViewControllerDelegate
extension MenuTableViewController: SFSafariViewControllerDelegate {
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
}