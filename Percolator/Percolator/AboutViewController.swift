//
//  AboutViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-24.
//
//

import UIKit
import MessageUI

final class AboutViewController: UIViewController {
    
    lazy var mailComposeViewController: MFMailComposeViewController = {
        return self.configuredMailComposeViewController()
    }()

    @IBOutlet weak var sendFeedbackButton: UIBarButtonItem!
    
    @IBAction func sendFeedbackButttonPressed(sender: UIBarButtonItem) {

        if MFMailComposeViewController.canSendMail() {
            
            self.presentViewController(mailComposeViewController, animated: true, completion: {
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
            })
            
        } else {
            self.showSendMailErrorAlert()
        }
    }
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.revealViewController().revealToggle(nil)
    }

    //  MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if !MFMailComposeViewController.canSendMail() {
            sendFeedbackButton.enabled = false
            sendFeedbackButton.tintColor = UIColor.clearColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - SWRevealViewControllerDelegate
extension AboutViewController: SWRevealViewControllerDelegate {
    
}

// MARK: - MFMailComposeViewControllerDelegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        // Re-init controller for use again.
        self.mailComposeViewController = configuredMailComposeViewController()
        if result == MFMailComposeResultSent {
            SwiftNotice.clear()
            SwiftNotice.showNoticeWithText(NoticeType.success, text: "感谢反馈", autoClear: true, autoClearTime: 3)
        }
    }

    private func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailCompseVC = MFMailComposeViewController()
        mailCompseVC.navigationBar.tintColor = UIColor.whiteColor();
        mailCompseVC.mailComposeDelegate = self
        
        let subject = "Bangumi M " + UIApplication.appVersion()
        let body = "\n------\n" +
                   "App: \(NSBundle.mainBundle().bundleIdentifier ?? "Bangumi M") \(UIApplication.appVersion()) (\(UIApplication.appBuild()))\n" +
                   "Device: \(UIDevice.currentDevice().deviceType) (\(UIDevice.currentDevice().systemVersion))\n" +
                   "Locale: \(NSLocale.preferredLanguages().first ?? "NA")_\((NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String) ?? "NA")"
        
        mailCompseVC.setToRecipients(["cirno.percolator@gmail.com"])
        mailCompseVC.setSubject(subject)
        mailCompseVC.setMessageBody(body, isHTML: false)
        
        return mailCompseVC
    }
    
    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could not send E-mail", message: "Your device could not send E-mail. Please check E-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
}
