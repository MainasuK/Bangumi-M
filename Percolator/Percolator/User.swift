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
    
    fileprivate let url: String
    fileprivate let username: String
    let nickname: String
    
    let avatar: Avatar

    fileprivate let sign: String
    
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
