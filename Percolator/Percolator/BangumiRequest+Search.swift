//
//  BangumiRequest+Search.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: - Search
extension BangumiRequest {
    
    typealias SearchSubjects = (Int, [Subject])
    
    func search(for keywords: String, startIndex: Int, resultLimit: Int, type: Int, handler: (Result<SearchSubjects>) -> Void) {
    
        // TODO:
        //  let authEncode = userData!.authEncode
        
        let urlPath = String( format: BangumiApiKey.Search, keywords.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!)
        var parameters: [String : AnyObject] = ["responseGroup" : "large",
                                                "max_results" : resultLimit,
                                                "start" : startIndex]
        
        if type != 0 {
            parameters["type"] = type
        }
        if let authEncode = user?.authEncode {
            consolePrint("Send search request with auth token")
            parameters["source"] = BangumiApiKey.Percolator
            parameters["auth"] = authEncode
        } else {
            consolePrint("Send search request without auth token")
        }
        
        alamofireManager.request(.GET, urlPath, parameters: parameters).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
            
            let subjects = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toSubjects)
            
            handler(subjects)
        }   // end alamofireManager …
    }   // end func search(…) { … }

}

extension BangumiRequest {
    
    // 1. Convert response to Result<AnyObjet> and wrap error
    func getResult(from response: Response) -> Result<AnyObject> {
        switch response.result {
        case .success(let value):   return .success(value)
        case .failure(let error):   return Result { throw wrap(error) }
        }
    }
    
    // 2. Unwrap object to JSON
    func toJSON(from object: AnyObject) -> Result<JSON> {
        return .success(JSON(object))
    }
    
    // 3. Validate JSON
    private func validate(json: JSON) -> Result<JSON> {
        // Bangumi API reture a JSON for error case
        if let error = json["error"].string,
            let code = json["code"].int {
            switch code {
            // "code":404, "error":"Not Found"
            case 404 where error == "Not Found":
                return .failure(SearchError.notFound)
                
            default:
                return .failure(Unknown.API(error: error, code: code))
            }
        }
        
        return .success(json)
    }
    
    // 4. Unwrap JSON to Subjects
    private func toSubjects(from json: JSON) -> Result<SearchSubjects> {
        let totalCount      = json["results"].int!
        let subjectsArray   = json["list"].arrayValue
        let subjects        = (totalCount, subjectsArray.map { Subject.init(from: $0) })
        
        return .success(subjects)
    }
    
}
