//
//  BangumiRequest.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BangumiRequest {
    
    typealias Response = Alamofire.Response<Any, NSError>

    let internetReachability = Reachability.forInternetConnection()
    
    var timeoutErrorTimes = 0
    var networkStatus: NetworkStatus = NotReachable
    var user: User?
    
    // Use default manager for changeless resource (with cache)
    let alamofireManager: Alamofire.SessionManager = {
        let kTimeoutInterval: TimeInterval = 15.0
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = kTimeoutInterval
        configuration.timeoutIntervalForResource = kTimeoutInterval
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return Alamofire.SessionManager(configuration: configuration)
    }()
    // Use ephemeral manager for mutable resource (without cache)
    let alamofireEphemeralManager: Alamofire.SessionManager = {
        let kTimeoutInterval: TimeInterval = 15.0
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = kTimeoutInterval
        configuration.timeoutIntervalForResource = kTimeoutInterval
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return Alamofire.SessionManager(configuration: configuration)
    }()

    // MARK: - Singleton
    private static let instance = BangumiRequest()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(BangumiRequest.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        networkStatus = internetReachability?.currentReachabilityStatus() ?? NotReachable
        internetReachability?.startNotifier()
    }
    
    static var shared: BangumiRequest {
        return self.instance
    }

}

// MARK: - Reachability
extension BangumiRequest {
    
    @objc func reachabilityChanged(notification: NSNotification) {
        guard let currentReachability = notification.object as? Reachability else {
            return
        }
        
        networkStatus = currentReachability.currentReachabilityStatus()
        
    }
    
}
