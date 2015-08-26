//
//  LoginViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    var delegate: MenuTransitionDelegate?
    var request = BangumiRequest.shared
    let myKeyChainWrapper = KeychainWrapper()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var EmailLabel: UITextField!
    @IBOutlet weak var PasswordLabel: UITextField!
    
    @IBAction func LoginButtonPressed(sender: AnyObject) {
        debugPrintln("@ LoginVC: Login Button Pressed")
        
        let button = sender as? UIButton
        
        if EmailLabel.text != "" && PasswordLabel.text != "" {
            debugPrintln("@ LoginVC: UserLogin request sended")
            self.pleaseWait()
            button?.enabled = false
            
            request.userLogin(EmailLabel.text, password: PasswordLabel.text) { (userData) -> Void in
                
                self.clearAllNotice()
                button?.enabled = true
                
                if let user = userData {
                    debugPrintln("@ LoginVC: User data get")
                    debugPrintln("@ LoginVC: User ID is \(user.id)")
                    debugPrintln("@ LoginVC: User nickname is \(user.nickName)")
                    self.request.userData = user
                    self.request.userData?.saveUserInfo(self.EmailLabel.text, pass: self.PasswordLabel.text, userData: self.request.userData!)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        NSUserDefaults.standardUserDefaults().setValue(self.request.userData?.id, forKey: UserDefaultsKey.userID)
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.delegate?.dismissLoginVC()
                    }
        
                } else {
                    self.noticeInfo("密码错误", autoClear: true, autoClearTime: 3)
                    println("@ LoginVC: Fail to get userData")
                }   // if let user = userData … else …
            }   // request.userLogin(…) { … }
        } else {
            self.noticeInfo("格式不正确", autoClear: true, autoClearTime: 2)
        }   // if EmailLabel.text … else …
    }
    
    // MARK: -
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == EmailLabel {
            self.PasswordLabel.becomeFirstResponder()
        }
        
        if textField == PasswordLabel {
            self.LoginButtonPressed(loginButton)
        }
        
        return true
    }

}

