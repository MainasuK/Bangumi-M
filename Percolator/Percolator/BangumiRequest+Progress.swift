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
    
    func progress(of subjectID: Int, handler: (Result<Progress>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let urlPath = String(format: BangumiApiKey.Progress, user.id, subjectID, BangumiApiKey.Percolator, user.authEncode)

        alamofireEphemeralManager.request(.GET, urlPath, parameters: nil).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
            
            let progress = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toProgress)
            
            handler(progress)
        }   // end alamofireEphemeralManager.request(…) { … }
    }   // end func progress(…) { … }
    
    func progresses(handler: (Result<Progresses>) -> Void) {
        
        guard let user = self.user else {
            handler(.failure(RequestError.userNotLogin))
            return
        }
        
        let urlPath = String(format: BangumiApiKey.Progresses, user.id, BangumiApiKey.Percolator, user.authEncode)
        
        alamofireEphemeralManager.request(.GET, urlPath, parameters: nil).validate(contentType: ["application/json"]).responseJSON { (response: Response) in
            
            let progresses = self.getResult(from: response)
                .flatMap(self.toJSON)
                .flatMap(self.validate)
                .flatMap(self.toProgresses)
            
            handler(progresses)
        }   // end alamofireEphemeralManager.request(…) { … }
    }   // end func progresses(…) { … }
    
}

extension BangumiRequest {
    
    // Validate JSON
    private func validate(json: JSON) -> Result<JSON> {
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
    private func toProgress(from json: JSON) -> Result<Progress> {
        var progress = Progress()
        json[BangumiKey.eps].arrayValue.forEach {
            guard let key = $0[BangumiKey.id].int,
            let statusID = $0[BangumiKey.status][BangumiKey.id].int,
            let status = Status(rawValue: statusID) else { return }
            
            progress[key] = status
        }
        
        return .success(progress)
    }
    
    private func toProgresses(from json: JSON) -> Result<Progresses> {
        var progresses = Progresses()
        json.arrayValue.forEach {
            guard let key = $0[BangumiKey.subjectID].int,
            let progress = try? toProgress(from: $0).resolve() else { return }
            
            progresses[key] = progress
        }
        
        return .success(progresses)
    }
}
