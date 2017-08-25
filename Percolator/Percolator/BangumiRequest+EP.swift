//
//  BangumiRequest+EP.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-21.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: - Progress
extension BangumiRequest {
    
    // Batch mark ep needs ids: [Int]
    // DO NOT use API POST watched_eps method which is bug exists (please test 火影忍者疾风传 to verify the bug)
    func ep(of id: Int, with ids: [Int]?, of status: Status, handler: @escaping (Error?) -> Void) {
        
        guard let user = self.user else {
            handler(RequestError.userNotLogin)
            return
        }
        
        let urlPath = String(format: BangumiApiKey.EP, id, status.toURLParams(), BangumiApiKey.Percolator, user.authEncode)
        var parameters: [String : Any]? = nil
        if let epID = ids?.reduce("", { (str, id) in str?.appending("\(id),")}) {
            parameters = ["ep_id" : epID]
        }
        
        alamofireEphemeralManager.request(urlPath, method: .post, parameters: parameters).validate(contentType: ["application/json"]).responseJSON(queue: DispatchQueue.cmkJson) { (response: Response) in
            
            let json = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
            
            DispatchQueue.main.async {
                switch json {
                case .success:                  handler(nil)
                case .failure(let error):       handler(error)
                }
            }
        }   // end alamofireEphemeralManager.request(…) { … }
    }   // end func ep(…) { … }
    
}

extension BangumiRequest {
    
    // Validate JSON
    fileprivate func validate(json: JSON) -> Result<JSON> {
        
        // Bangumi API reture a JSON for error case
        // And 200 Ok…
        if let error = json["error"].string,
            let code = json["code"].int {
            switch code {
            case 200:
                return .success(json)
            case 401 where error == "Unauthorized":
                return .failure(ProgressError.unauthorized)
                
            default:
                return .failure(Unknown.API(error: error, code: code))
            }
        }
        
        return .success(json)
    }
    
}
