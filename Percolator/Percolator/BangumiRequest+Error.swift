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
    
    enum LoginError: ErrorProtocol {
        case userNameNotEmail
        case unauthorized
    }
    
    enum SearchError: ErrorProtocol {
        case notFound
    }
    
    enum CollectionError: ErrorProtocol {
        case noCollection
        case unauthorized
    }
    
    enum SubjectError: ErrorProtocol {
        case notFound
    }
    
    enum ProgressError: ErrorProtocol {
        case noProgress
        case unauthorized
    }
    
    enum epError: ErrorProtocol {
        case unauthorized
    }
    
    // For auth request
    enum RequestError: ErrorProtocol {
        case userNotLogin
    }
    
    // NSURLError
    enum NetworkError: ErrorProtocol {
        case timeout
        case notConnectedToInternet
        case dnsLookupFailed
    }
    
    // NSError
    enum AlamofireError: ErrorProtocol {
        case contentTypeValidationFailed
    }
    
    enum Unknown: ErrorProtocol {
        case API(error: String, code: Int)
        case network(error: NSURLError)
        case alamofire(error: NSError)
    }
    
}


// Wrap error
extension BangumiRequest {
    
    func wrap(_ error: ErrorProtocol) -> ErrorProtocol {
        switch error {
        case let urlError as NSURLError:
            switch urlError {
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
            
        case let nsError as NSError:
            switch nsError.code {
            case Alamofire.Error.Code.contentTypeValidationFailed.rawValue:
                return AlamofireError.contentTypeValidationFailed
            default:
                return Unknown.alamofire(error: nsError)
            }
            
        default:
            return error
        }
    }

}
