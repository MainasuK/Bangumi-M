//
//  MenuTableViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-11.
//
//

import UIKit
import SafariServices

class MenuTableViewController: UITableViewController, MenuTransitionDelegate, SFSafariViewControllerDelegate {
    
    @IBAction func superTopicButtonPressed(sender: AnyObject) {
        
        let url = "http://bangumi.tv/m"
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
        debugPrint("User logout")
        User.deleteUserInfo()
        BangumiAnimeModel.shared.dropModel()
        BangumiFavoriteModel.shared.dropModel()
        BangumiRequest.shared.userData = nil
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.loginVC) as! LoginViewController
        loginVC.delegate = self
        NSNotificationCenter.defaultCenter().postNotificationName("userLogout", object: nil)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(loginVC, animated: true, completion: nil)
        })
    }
    
    // MARK: - MenuTransitionDelegate
    func dismissLoginVC() {
        let tabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.animeTableViewVC) as! UINavigationController
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.revealViewController().revealToggle(nil)
        })
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("MenuTableViewController did load")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSLog("MenueTableViewController will disappear")
    }
    
    deinit {
        NSLog("MenuTableViewController is being deallocated")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SFSafariViewControllerDelegate
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

    }
}
