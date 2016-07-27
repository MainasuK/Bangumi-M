//
//  BangumiUser.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import SwiftyJSON
import KeychainAccess

struct User {
    
    let id: Int
    let auth: String
    let authEncode: String
    
    private let url: String
    private let username: String
    let nickname: String
    
    let avatar: Avatar

    private let sign: String
    
    // Fail fast - make sure error handle correctly
    init(json: JSON) {
        
        auth = json[BangumiKey.auth].stringValue
        authEncode = json[BangumiKey.authEncode].stringValue
        
        let avatarDict = json[BangumiKey.avatar].dictionaryValue
        avatar = Avatar(avatarDict: avatarDict)
        
        id = json[BangumiKey.id].int!
        nickname = json[BangumiKey.nickname].stringValue
        sign = json[BangumiKey.sign].stringValue
        url = json[BangumiKey.url].stringValue
        username = json[BangumiKey.username].stringValue
    }
    
    init?() {
        consolePrint("Restroe user from UserDefaults…")
        guard User.isLogin() else {
            consolePrint("… failed")
            return nil
        }
        
        let standard = UserDefaults.standard
        
        id = standard.integer(forKey: UserDefaultsKey.userID)
        auth = standard.string(forKey: UserDefaultsKey.userAuth)!
        authEncode = standard.string(forKey: UserDefaultsKey.userAuthEncode)!

        url = standard.string(forKey: UserDefaultsKey.userURL)!
        username = standard.string(forKey: UserDefaultsKey.username)!
        nickname = standard.string(forKey: UserDefaultsKey.userNickname)!
        
        let large = standard.string(forKey: UserDefaultsKey.userLargeAvatar)!
        let medium = standard.string(forKey: UserDefaultsKey.userMediumAvatar)!
        let small = standard.string(forKey: UserDefaultsKey.userSmallAvatar)!
        avatar = Avatar(largeURL: large, mediumURL: medium, smallURL: small)
        
        sign = standard.string(forKey: UserDefaultsKey.userSign)!
        
        consolePrint("… successed")
    }

}


extension User {

    func saveInfo(with email: String, password: String) {
        consolePrint("Save user info to UserDeaults and KeychainWrapper")
        let keychain = Keychain(service: "https://api.bgm.tv")
        let standard = UserDefaults.standard
        
        standard.set(true, forKey: UserDefaultsKey.hasLoginKey)
        
        standard.set(id, forKey: UserDefaultsKey.userID)
        standard.set(auth, forKey: UserDefaultsKey.userAuth)
        standard.set(authEncode, forKey: UserDefaultsKey.userAuthEncode)
        
        standard.set(url, forKey: UserDefaultsKey.userURL)
        standard.set(username, forKey: UserDefaultsKey.username)
        standard.set(nickname, forKey: UserDefaultsKey.userNickname)
        
        standard.set(avatar.largeUrl, forKey: UserDefaultsKey.userLargeAvatar)
        standard.set(avatar.mediumUrl, forKey: UserDefaultsKey.userMediumAvatar)
        standard.set(avatar.smallUrl, forKey: UserDefaultsKey.userSmallAvatar)
        
        standard.set(sign, forKey: UserDefaultsKey.userSign)
        
        standard.set(email, forKey: UserDefaultsKey.userEmail)
        standard.synchronize()

        keychain["password"] = password
    }
    
    func updateAuth() {
        consolePrint("Update user auth…")
        let standard = UserDefaults.standard
        let keychain = Keychain(service: "https://api.bgm.tv")
        
        guard let email = standard.string(forKey: UserDefaultsKey.userEmail),
        let pass = keychain["password"] else {
            consolePrint("… can not get email or password")
            return
        }
        
        BangumiRequest.shared.userLogin(email, password: pass) { (user: Result<User>) in
            do {
                let user = try user.resolve()
                
                consolePrint("… fetch user auth success, save it")
                user.saveInfo(with: email, password: pass)
                BangumiRequest.shared.user = user
            } catch {
                consolePrint("… request occur error: \(error)")
            }
        }
    }

}


extension User {
    
    static func isLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.hasLoginKey)
    }
    
    static func removeInfo() {
        consolePrint("Remove user info")
        let keychain = Keychain(service: "https://api.bgm.tv")
        let standard = UserDefaults.standard
        
        // Always Remove flag and value together to make sure restore could correctly
        standard.set(false, forKey: UserDefaultsKey.hasLoginKey)
        
        standard.set(nil, forKey: UserDefaultsKey.userID)
        standard.set(nil, forKey: UserDefaultsKey.userAuth)
        standard.set(nil, forKey: UserDefaultsKey.userAuthEncode)
        
        standard.set(nil, forKey: UserDefaultsKey.userURL)
        standard.set(nil, forKey: UserDefaultsKey.username)
        standard.set(nil, forKey: UserDefaultsKey.userNickname)
        
        standard.set(nil, forKey: UserDefaultsKey.userLargeAvatar)
        standard.set(nil, forKey: UserDefaultsKey.userMediumAvatar)
        standard.set(nil, forKey: UserDefaultsKey.userSmallAvatar)
        
        standard.set(nil, forKey: UserDefaultsKey.userSign)
        
        standard.set(nil, forKey: UserDefaultsKey.userEmail)
        standard.synchronize()
        
        keychain["password"] = nil
    }

}

//
//    class func deleteUserInfo() {
//        print("$ Bangumi_User: user is log out status. Clean usre data")
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            
//            let myKeyChainWrapper = KeychainWrapper()
//            
//            NSstandardUserDefaults().setBool(false, forKey: UserDefaultsKey.hasLoginKey)
//            NSstandardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userID)
//            NSstandardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userEmail)
//            NSstandardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userAuth)
//            NSstandardUserDefaults().setValue(nil, forKey: UserDefaultsKey.userAuthEncode)
//            NSstandardUserDefaults().synchronize()
//            
//            myKeyChainWrapper.mySetObject(nil, forKey: kSecValueData)
//            myKeyChainWrapper.writeToKeychain()
//        })
//    }
//    
//    // FIXME: Something is wrong
//    class func refetchUserAuth() {
//        print("$ Bangumi_User: Refetch user auth")
//        let myKeyChainWrapper = KeychainWrapper()
//        let request = BangumiRequest.shared
//
//
//        if User.isUserLogin() {
//            let email = NSstandardUserDefaults().valueForKey(UserDefaultsKey.userEmail) as? String
//            let pass = myKeyChainWrapper.myObjectForKey(kSecValueData) as? String
//            print("$ Bangumi_User: Try to prase user json")
//            
//            if email != nil && pass != nil {
//                request.userLogin(email!, password: pass!) { (userData) -> Void in
//
//                    if let user = userData {
//                        debugPrint("$ Bangumi_User: User auth up to date: \(user.auth), save it in NSUserDefaults")
//                        debugPrint("$ Bangumi_User: request userData up to date")
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            
//                            NSstandardUserDefaults().setValue(user.auth, forKey: UserDefaultsKey.userAuth)
//                            NSstandardUserDefaults().synchronize()
//                        })
//                    }
//                }
//            }
//        }
//    }
//    
//    
//}
