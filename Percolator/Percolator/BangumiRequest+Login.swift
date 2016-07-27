//
//  BangumiRequest+Login.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


// MARK: - User Login
extension BangumiRequest {
    
    func userLogin(_ email: String, password pass: String, handler: (Result<User>) -> Void) {
        
        let urlPath = String(format: BangumiApiKey.Auth, BangumiApiKey.Percolator)
        let parameters = ["username" : email, "password" : pass]

        alamofireEphemeralManager.request(.POST, urlPath, parameters: parameters).validate().responseJSON { (response: Response) in
            
            let user = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toUser)
            
            handler(user)
        }   // end alamofireEphemeralManager.request(…) { … }
    }   // end func userLogin(…) { … }
    
}


extension BangumiRequest {
    
        // Validate JSON
        private func validate(json: JSON) -> Result<JSON> {
            // Bangumi API reture a JSON for error case
            if let error = json["error"].string,
                let code = json["code"].int {
                switch code {
                // "code":401, "error":"40102 Error: Username is not an Email address"
                case 401 where error == "40102 Error: Username is not an Email address":
                    return .failure(LoginError.userNameNotEmail)

                case 401 where error == "Unauthorized":
                    return .failure(LoginError.unauthorized)

                default:
                    return .failure(Unknown.API(error: error, code: code))
                }
            }
            
            return .success(json)
        }
        
        // Unwrap JSON to User
        private func toUser(from json: JSON) -> Result<User> {
            return .success(User(json: json))
        }
        
}
