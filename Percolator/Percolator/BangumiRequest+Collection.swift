//
//  BangumiRequest+Collection.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-17.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


// MARK: - User now watching anime collection list (API return 50 MAX)
extension BangumiRequest {
    
    typealias CollectionSubjects = [Subject]
    typealias CollectDict = [SubjectID : CollectInfoSmall]
    
    // Discard no use info excepte subect
    func userCollection(handler: (Result<CollectionSubjects>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let urlPath = String(format: BangumiApiKey.UserWatchingCollection, user.id)
        let parameters = ["cat" : "watching"]
        
        alamofireEphemeralManager.request(.GET, urlPath, parameters: parameters).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
            
            let subjects = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toSubjects)
            
            handler(subjects)
        }   // end alamofireEphemeralManager.request(…) { … }
    }   // end func userCollection(…) { … }
    
    func collection(of subjectID: SubjectID, handler: (Result<CollectInfo>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let urlPath = String(format: BangumiApiKey.UserSubjectCollection, subjectID, BangumiApiKey.Percolator, user.authEncode)
    
        alamofireEphemeralManager.request(.GET, urlPath, parameters: nil).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
        
            let collectInfo = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toCollectInfo)
            
            handler(collectInfo)
        }
    }
    
    func collection(of subjectIDs: [SubjectID], handler: (Result<CollectDict>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let ids = subjectIDs.reduce("", { (str, id) in
            if id != subjectIDs.last {
                return str.appending("\(id),")
            } else {
                return str.appending("\(id)")
            }
        })
        let urlPath = String(format: BangumiApiKey.UserSubjectCollectionSmall, user.id, ids, BangumiApiKey.Percolator, user.authEncode)
        
        alamofireEphemeralManager.request(.GET, urlPath, parameters: nil).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
            
            let collectDict = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toCollecDict)
            
            handler(collectDict)
        }
    }
    
    func updateCollection(of subjectID: SubjectID, with statusType: CollectInfo.StatusType, _ rating: Int?, _ comment: String?, _ tags: [String]?, isPrivacy: Bool, handler: (Result<CollectInfo>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let urlPath = String(format: BangumiApiKey.UpdateSubjectStatus, subjectID, BangumiApiKey.Percolator, user.authEncode)
        var postBody: [String : AnyObject] = ["status" : statusType.rawValue,
                                              "privacy" : isPrivacy ? "1" : "0"]  // Do Not Public It. Keep it in privacy.
        if let rating = rating { postBody["rating"] = rating }
        if let comment = comment { postBody["comment"] = comment }
        if let tags = tags { postBody["tags"] = "\(tags.joined(separator: " "))" }
        
        alamofireEphemeralManager.request(.POST, urlPath, parameters: postBody).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
            
            let collectInfo = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toCollectInfo)
            
            handler(collectInfo)
        }
    }
    
}


extension BangumiRequest {
    
    // Validate JSON
    private func validate(json: JSON) -> Result<JSON> {
        // Bangumi API reture a "null" for no collection case
        guard json.rawString() != "null" else {
            return .failure(CollectionError.noCollection)
        }
        
        // Unknown case
        if let error = json["error"].string,
        let code = json["code"].int {
            switch code {
            case 400:
                return .failure(CollectionError.noCollection)
            case 401 where error == "Unauthorized":
                return .failure(CollectionError.unauthorized)
                
            default:
                return .failure(Unknown.API(error: error, code: code))
            }
        }
        
        return .success(json)
    }
    
    // Unwrap JSON to Subjects
    private func toSubjects(from json: JSON) -> Result<CollectionSubjects> {
        let subjects = json.arrayValue.map { Subject(from: $0["subject"]) }

        return .success(subjects)
    }
    
    // Unwrap JSON to CollectInfo
    private func toCollectInfo(from json: JSON) -> Result<CollectInfo> {
        return .success(CollectInfo(from: json))
    }
    
    // Unwrap JSON to CollectDict
    private func toCollecDict(from json: JSON) -> Result<CollectDict> {
        var dict = CollectDict()
        for (key, subJSON) in json.dictionaryValue {
            if let subjectID = Int(key) {
                dict[subjectID] = CollectInfoSmall(from: subJSON)
            }
        }
        
        return .success(dict)
    }
}
