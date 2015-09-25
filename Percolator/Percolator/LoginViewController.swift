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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        guard let email = emailTextField.text where email != "" else {
            self.clearAllNotice()
            self.noticeInfo("请输入邮件", autoClear: true, autoClearTime: 2)
            return
        }
        
        guard let pass = passwordTextField.text where pass != "" else {
            self.clearAllNotice()
            self.noticeInfo("请输入密码", autoClear: true, autoClearTime: 2)
            return
        }
        
        let button = sender as? UIButton
        button?.enabled = false
        self.pleaseWait()
        
        request.userLogin(email, password: pass) { (userData) -> Void in
            
            self.clearAllNotice()
            
            defer {
                button?.enabled = true
            }
            
            guard let user = userData else {
                self.noticeInfo("密码错误", autoClear: true, autoClearTime: 3)
                print("@ LoginVC: Fail to get userData")
                return
            }
            
            print("@ LoginVC: User data get")
            print("@ LoginVC: User ID is \(user.id)")
            print("@ LoginVC: User nickname is \(user.nickName)")
            self.request.userData = user
            self.request.userData?.saveUserInfo(email, password: pass, userData: self.request.userData!)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                NSUserDefaults.standardUserDefaults().setValue(self.request.userData?.id, forKey: UserDefaultsKey.userID)
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.dismissLoginVC()
            }
        }
    }   // loginButtonPressed(sender: …)
    
    // MARK: - View lifecycle
    
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
        if textField == emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        
        if textField == passwordTextField {
            self.loginButtonPressed(loginButton)
        }
        
        return true
    }
}

