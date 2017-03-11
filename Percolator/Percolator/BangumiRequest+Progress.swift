//
//  BangumiRequest+Progress.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: - Progress
extension BangumiRequest {
    
    // [SubjectID : Progress]
    typealias Progresses = [Int : Progress]
    
    func progress(of subjectID: Int, handler: @escaping (Result<Progress>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let urlPath = String(format: BangumiApiKey.Progress, user.id, subjectID, BangumiApiKey.Percolator, user.authEncode)
        
        alamofireEphemeralManager.request(urlPath, method: .get).validate(contentType: ["application/json"]).responseJSON(queue: DispatchQueue.cmkJson) { (response: Response) in
            
            let progress = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toProgress)
            
            DispatchQueue.main.async {
                handler(progress)
            }
        }   // end alamofireEphemeralManager.request(…) { … }
    }   // end func progress(…) { … }
    
    func progresses(handler: @escaping (Result<Progresses>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let urlPath = String(format: BangumiApiKey.Progresses, user.id, BangumiApiKey.Percolator, user.authEncode)
        
        alamofireEphemeralManager.request(urlPath, method: .get, parameters: nil).validate(contentType: ["application/json"]).responseJSON(queue: DispatchQueue.cmkJson) { (response: Response) in
            
            let progresses = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toProgresses)
            
            DispatchQueue.main.async {
                handler(progresses)
            }
        }   // end alamofireEphemeralManager.request(…) { … }
    }   // end func progresses(…) { … }
    
}

extension BangumiRequest {
    
    // Validate JSON
    fileprivate func validate(json: JSON) -> Result<JSON> {
        // Bangumi API reture a "null" for no progress case
        guard json.rawString() != "null" else {
            return .failure(ProgressError.noProgress)
        }
        
        // Bangumi API reture a JSON for error case
        if let error = json["error"].string,
            let code = json["code"].int {
            switch code {
            case 401 where error == "Unauthorized":
                return .failure(ProgressError.unauthorized)

            default:
                return .failure(Unknown.API(error: error, code: code))
            }
        }
        
        return .success(json)
    }
    
    // Unwrap JSON to Subjects
    fileprivate func toProgress(from json: JSON) -> Result<Progress> {
        var progress = Progress()
        json[BangumiKey.eps].arrayValue.forEach {
            guard let key = $0[BangumiKey.id].int,
            let statusID = $0[BangumiKey.status][BangumiKey.id].int,
            let status = Status(rawValue: statusID) else { return }
            
            progress[key] = status
        }
        
        return .success(progress)
    }
    
    fileprivate func toProgresses(from json: JSON) -> Result<Progresses> {
        var progresses = Progresses()
        json.arrayValue.forEach {
            guard let key = $0[BangumiKey.subjectID].int,
            let progress = try? toProgress(from: $0).resolve() else { return }
            
            progresses[key] = progress
        }
        
        return .success(progresses)
    }
    
}
