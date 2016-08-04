//
//  BangumiRequest+Subject.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: - Subject (fetch by id and responseGroup)
extension BangumiRequest {
    
    func subject(of id: Int, with responseGroup: ResponseGroup = .large, handler: (Result<Subject>) -> Void) {
        
        let urlPath = String(format: BangumiApiKey.Subject, id)
        let parameters = ["responseGroup" : responseGroup.rawValue]
        
        // Speeding up with HTTP protocol (without auth info)
        alamofireManager.request(.GET, urlPath, parameters: parameters).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
            
            let subject = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toSubject)
            
            handler(subject)
        }   // end alamofireManager.request(…) { … }
    }   // end func subject(…) { … }
    
}


extension BangumiRequest {

    enum ResponseGroup: String {
        case large = "large"
        case medium = "medium"
        case small = "small"
    }
    
}
extension BangumiRequest {
    
    // Validate JSON
    private func validate(json: JSON) -> Result<JSON> {
        // Bangumi API reture a JSON for error case
        if let error = json["error"].string,
        let code = json["code"].int {
            switch code {
            case 404 where error == "Not Found":
                return .failure(SubjectError.notFound)
                
            default:
                return .failure(Unknown.API(error: error, code: code))
            }
        }
        
        return .success(json)
    }
    
    // Unwrap JSON to Subjects
    private func toSubject(from json: JSON) -> Result<Subject> {
        return .success(Subject(from: json))
    }
    
}
