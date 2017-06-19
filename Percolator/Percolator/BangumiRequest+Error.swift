//
//  BangumiRequest+Errort.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import Alamofire

// Model need headle API Error
// Controller should handle network error and unknown error
extension BangumiRequest {
    
    enum LoginError: Error {
        case userNameNotEmail
        case unauthorized
    }
    
    enum SearchError: Error {
        case notFound
    }
    
    enum CollectionError: Error {
        case noCollection
        case unauthorized
    }
    
    enum SubjectError: Error {
        case notFound
    }
    
    enum ProgressError: Error {
        case noProgress
        case unauthorized
    }
    
    enum EpError: Error {
        case unauthorized
    }
    
    enum HTMLError: Error {
        case notHTML
    }
    
    // For auth request
    enum RequestError: Error {
        case userNotLogin
    }
    
    // NSURLError
    enum NetworkError: Error {
        case timeout
        case notConnectedToInternet
        case dnsLookupFailed
    }
    
    // NSError
    enum AlamofireError: Error {
        case contentTypeValidationFailed
    }
    
    enum Unknown: Error {
        case API(error: String, code: Int)
        case network(error: URLError)
        case alamofire(error: AFError)
    }
    
}

// Wrap error
extension BangumiRequest {
    
    func wrap(_ error: Error) -> Error {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .timedOut:
                timeoutErrorTimes += 1
                return NetworkError.timeout
            case .notConnectedToInternet:
                return NetworkError.notConnectedToInternet
            case .dnsLookupFailed:
                return NetworkError.dnsLookupFailed
            default:
                return Unknown.network(error: urlError)
            }
            
        case let afError as AFError:
            switch afError {
            case .responseValidationFailed:
                return AlamofireError.contentTypeValidationFailed
                
            default:
                return Unknown.alamofire(error: afError)
            }
            
        default:
            return error
        }
    }

}
