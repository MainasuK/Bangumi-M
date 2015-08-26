//
//  BangumiUser.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation

public class User {
    
    public var id = 0
    public var url = ""
    public var userName = ""
    public var nickName = ""
    
    public var avatar = Avatar()
    
    public var sign = ""
    
    public let auth: String
    public let authEncode: String
    
    // MARK: - Private Implementation
    
    init(json: NSDictionary) {
        
        id = json[BangumiKey.id] as! Int
        url = json[BangumiKey.url] as! String
        userName = json[BangumiKey.userName] as! String
        nickName = json[BangumiKey.nickName] as! String
        
        let avatarDict = json[BangumiKey.avatar] as! NSDictionary
        avatar = Avatar(avatarDict: avatarDict)
        
        sign = json[BangumiKey.sign] as! String
        auth = json[BangumiKey.auth] as! String
        authEncode = json[BangumiKey.authEncode] as! String
    }
    
    
    init() {
        // FIXME:
        auth = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userAuth) as? String ?? ""
        authEncode = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userAuthEncode) as? String ?? ""
        id = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userID) as? Int ?? 0
    }
    
    func saveUserInfo(email: String, pass: String, userData: User) {
        println("$ Bangumi_User: Save user data to NSUserDeaults and KeychainWrapper")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            let myKeyChainWrapper = KeychainWrapper()
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaultsKey.hasLoginKey)
            NSUserDefaults.standardUserDefaults().setValue(userData.id, forKey: UserDefaultsKey.userID)
            NSUserDefaults.standardUserDefaults().setValue(email, forKey: UserDefaultsKey.userEmail)
            NSUserDefaults.standardUserDefaults().setValue(userData.auth, forKey: UserDefaultsKey.userAuth)
            NSUserDefaults.standardUserDefaults().setValue(userData.authEncode, forKey: UserDefaultsKey.userAuthEncode)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            myKeyChainWrapper.mySetObject(pass, forKey: kSecValueData)
            myKeyChainWrapper.writeToKeychain()
        })
    }
    
    class func isUserLogin() -> Bool {
        println("$ Bangumi_User: is user login?")
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        
        if hasLoginKey {
            println("Yes")
            return true
        }
        println("No")
        deleteUserInfo()
        return false
    }
    
    class func deleteUserInfo() {
        println("$ Bangumi_User: user is log out status. Clean usre data")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            let myKeyChainWrapper = KeychainWrapper()
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaultsKey.hasLoginKey)
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userID)
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userEmail)
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userAuth)
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userAuthEncode)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            myKeyChainWrapper.mySetObject(nil, forKey: kSecValueData)
            myKeyChainWrapper.writeToKeychain()
        })
    }
    
    // FIXME: Something is wrong
    class func refetchUserAuth() {
        println("$ Bangumi_User: Refetch user auth")
        let myKeyChainWrapper = KeychainWrapper()
        let request = BangumiRequest.shared


        if User.isUserLogin() {
            let email = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userEmail) as? String
            let pass = myKeyChainWrapper.myObjectForKey(kSecValueData) as? String
            println("$ Bangumi_User: Try to prase user json")
            
            if email != nil && pass != nil {
                request.userLogin(email!, password: pass!) { (userData) -> Void in

                    if let user = userData {
                        debugPrintln("$ Bangumi_User: User auth up to date: \(user.auth), save it in NSUserDefaults")
                        debugPrintln("$ Bangumi_User: request userData up to date")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            NSUserDefaults.standardUserDefaults().setValue(user.auth, forKey: UserDefaultsKey.userAuth)
                            NSUserDefaults.standardUserDefaults().synchronize()
                        })
                    }
                }
            }
        }
    }
    
    
}