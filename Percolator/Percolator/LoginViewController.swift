//
//  LoginViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import UITextField_Shake
import SVProgressHUD
import Canvas

final class LoginViewController: UIViewController {
    
    typealias LoginError = BangumiRequest.LoginError
    typealias NetworkError = BangumiRequest.NetworkError
    typealias UnknownError = BangumiRequest.Unknown
    
    let request = BangumiRequest.shared
    
    let kStackViewToTopConstant: CGFloat = 64.0
    let kStackViewMoveToConstant: CGFloat = 8.0
    
    lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self.view)
    }()
    var attachmentBehavior: UIAttachmentBehavior?
    var snapBehavior: UISnapBehavior?
    weak var delegate: TransitionDelegate?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loginView: CSAnimationView!
    @IBOutlet weak var stackViewToTopLayoutGuideLine: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text, email != "" else {
            emailTextField.shake()
            emailTextField.placeholder = "请输入邮箱"
            return
        }
        emailTextField.placeholder = ""
        
        guard let pass = passwordTextField.text, pass != "" else {
            passwordTextField.shake()
            passwordTextField.placeholder = "请输入密码"
            return
        }
        passwordTextField.placeholder = ""


        sender.isEnabled = false
        SVProgressHUD.show()
        
        request.userLogin(email, password: pass) { (user: Result<User>) in
            
            sender.isEnabled = true
            
            do {
                self.request.user = try user.resolve()
                self.request.user?.saveInfo(with: email, password: pass)
                
                sender.isUserInteractionEnabled = false
                SVProgressHUD.showSuccess(withStatus: "登录成功")
                delay(2.0, handler: {
                    SVProgressHUD.dismiss()
                    self.resignTextFieldFirstResponder()
                    self.delegate?.dissmissViewController(with: true)
                    self.dismiss(animated: true, completion: nil)
                })
                
            } catch LoginError.userNameNotEmail {
                SVProgressHUD.showInfo(withStatus: "邮箱格式不正确")
                
            } catch LoginError.unauthorized {
                SVProgressHUD.showInfo(withStatus: "邮箱或密码错误")
                
            } catch UnknownError.API(let error, let code) {
                let title = NSLocalizedString("server error", comment: "")
                let alertController = UIAlertController.simpleErrorAlert(with: title, description: "\(error)", code: code)
                
                SVProgressHUD.dismiss()
                self.present(alertController, animated: true, completion: nil)
                consolePrint("API error: \(error), code: \(code)")
                
            } catch NetworkError.timeout {
                if self.request.timeoutErrorTimes == 3 {
                    let alertController = UIAlertController(title: NSLocalizedString("please check your network connection status", comment: ""), message: NSLocalizedString("make sure that the network can be connected to bgm.tv", comment: ""), preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("dismiss", comment: ""), style: .cancel) { (action) in
                        // ...
                    }
                    
                    alertController.addAction(cancelAction)
                    SVProgressHUD.dismiss()
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let status = NSLocalizedString("time out", comment: "")
                    
                    SVProgressHUD.showInfo(withStatus: status)
                    consolePrint("Time out")
                }
                consolePrint("Time out")
                
            } catch NetworkError.notConnectedToInternet {
                SVProgressHUD.dismiss()
                self.present(PercolatorAlertController.notConnectedToInternet(), animated: true, completion: nil)
                
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
            }

        }   // end BangumiUser.login(…) { … }
    }   // end loginButtonPressed(sender: …)
    
    deinit {
        consolePrint("LoginViewController deinit")
    }
    
}


// MARK: - UIViewController
extension LoginViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}

// MARK: - View Life Cycle
extension LoginViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoginView()
        setupBlurView()
        registeKeyboardNotification()
        
        loginButton.setTitle(NSLocalizedString("login…", comment: ""), for: .disabled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSVProgressHUD(style: .custom)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addGestureRecognizer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeKeyboardNotification()
        setSVProgressHUD(style: .dark)
    }

}

// MARK: - UIContentContainer
extension LoginViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.view.frame.size = size
    }
    
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        
        if textField == passwordTextField {
            self.loginButtonPressed(loginButton)
        }
        
        return true
    }
    
    func resignTextFieldFirstResponder() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
}

// MARK: Gestrue handler
// Ref: https://www.sitepoint.com/using-uikit-dynamics-swift-animate-apps/
extension LoginViewController {
    
    func pan(from sender: UIPanGestureRecognizer) {
        
        let panLocationInView = sender.location(in: view)
        let panLocationInPopView = sender.location(in: loginView)
        
        switch sender.state {
        case .began:
            animator.removeAllBehaviors()
            
            attachmentBehavior = {
                let horizontal = panLocationInPopView.x - loginView.bounds.midX
                let vertical = panLocationInPopView.y - loginView.bounds.midY
                let offset = UIOffset(horizontal: horizontal, vertical: vertical)
                
                return UIAttachmentBehavior(item: loginView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
            }()
            
            animator.addBehavior(attachmentBehavior!)
            
        case .changed:
            attachmentBehavior?.anchorPoint = panLocationInView
    
        case .ended:
            animator.removeAllBehaviors()
            let center = CGPoint(x: stackView.frame.midX, y: stackView.frame.minY + loginView.bounds.height * 0.5)
            snapBehavior = UISnapBehavior(item: loginView, snapTo: center)
            animator.addBehavior(snapBehavior!)
            
            if sender.translation(in: view).length() > 150.0  {
                dissmissController()
            }
            
        default:
            break
        }
    }
    
    func dissmissController() {
        animator.removeAllBehaviors()
        
        let gravityBehaviour = UIGravityBehavior(items: [loginView])
        gravityBehaviour.gravityDirection = CGVector(dx: 0.0, dy: 9.8)
        animator.addBehavior(gravityBehaviour)
        
        let itemBehaviour = UIDynamicItemBehavior(items: [loginView])
        itemBehaviour.addAngularVelocity(CGFloat(-M_PI_2), for: loginView)
        animator.addBehavior(itemBehaviour)
        
        consolePrint("dissmissController")
        
        resignTextFieldFirstResponder()
        
        delay(0.75) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: - Setup method
extension LoginViewController {
    
    func addGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(LoginViewController.pan(from:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    func setupLoginView() {
        loginView.layer.shadowColor = UIColor.black.cgColor
        loginView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        loginView.layer.shadowOpacity = 0.2
        loginView.layer.shadowRadius = 5.0
    }
    
    func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = true
        
        
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        // Autolayout blurEffectView
        let leading = NSLayoutConstraint(item: blurEffectView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: blurEffectView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: blurEffectView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: blurEffectView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    
}

extension LoginViewController {
    
    func registeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardDidDismiss(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    
    func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let bottom = loginView.frame.height + kStackViewToTopConstant
        
        if bottom > keyboardFrame.origin.y {
            UIView.animate(withDuration: 0.5) {
                self.stackViewToTopLayoutGuideLine.constant = self.kStackViewMoveToConstant
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardDidDismiss(notification: Notification) {
        
        UIView.animate(withDuration: 0.5) {
            self.stackViewToTopLayoutGuideLine.constant = self.kStackViewToTopConstant
            self.view.layoutIfNeeded()
        }
    }
    
}
