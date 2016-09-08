//
//  BangumiRequest+URL.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-8-7.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension BangumiRequest {
    
    typealias ResponseData = Alamofire.DataResponse<Data>
    
    func html(from url: String, handler: @escaping (Result<String>) -> Void) {
        
        BangumiRequest.shared.alamofireManager.request(url, method: .get).validate().responseData(queue: DispatchQueue.cmkJson) { (response: ResponseData) in
            
            let html = self.getResult(from: response)
                .flatMap(self.toHTML)
            
            DispatchQueue.main.async {
                handler(html)
            }
        }   // end request
        
    }
}

extension BangumiRequest {
    
    func getResult(from response: ResponseData) -> Result<Data> {
        switch response.result {
        case .success(let value):   return .success(value)
        case .failure(let error):   return Result { throw wrap(error) }
        }
    }
    
    fileprivate func toHTML(from object: Data) -> Result<String> {
        guard let html = String(data: object, encoding: String.Encoding.utf8) else {
            return .failure(HTMLError.notHTML)
        }
        
        return .success(html)
    }
    
}
