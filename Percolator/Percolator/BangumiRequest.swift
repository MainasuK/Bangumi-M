//
//  BangumiRequest.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Haneke

public class BangumiRequest {
    
    // FIXME: NSDefault needed and
    // FIXME: userData need remove
    // but I'm not sure
    public var userData = User?()
    
    private let urlSession = NSURLSession(configuration: .ephemeralSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
    

    // MARK: - Singleton
    private static let instance = BangumiRequest()
    
    private init() {

    }
    
    public static var shared: BangumiRequest {
        return self.instance
    }
    
    // MARK: - POST
    public func sendEpsStatusRequest(animeItem: Anime, _ method: UpdateSatusMethod, _ rating: Int?, _ comment: String?, _ tags: [String]?, _ handler: (SendRequestStatus) -> Void) {
        
        let authEncode = userData!.authEncode
        let epsID = animeItem.subject.id
        
        var postBody = String(format: "auth=%@&status=%@", authEncode, method.rawValue)
        postBody += (rating != nil) ? "&rating=\(rating!)" : ""
        postBody += (comment != nil) ? "&comment=\(comment!)" : ""
        if tags != nil { postBody += "&tags=" + (tags!).joinWithSeparator(" ") }
        
        let urlPath = String(format: BangumiApiKey.UpdateSubjectStatus, animeItem.subject.id, BangumiApiKey.Percolator)
        
        self.getJsonFrom(urlPath, post: postBody) { (jsonData) -> Void in
            
            if let json = jsonData as? NSDictionary {
                let info = EpsCollectInfo(infoDict: json)
                handler(.success)
            } else {
                handler(.failed)
            }
        }
    }
    
    // POST
    public func sendEpStatusRequest(epIdList: [Int], method: UpdateSatusMethod, _ handler: (SendRequestStatus) -> Void) {
        
        let authEncode = userData!.authEncode
        let epID = epIdList.first!
        var epStr = ""
        for id in epIdList { epStr += "\(id)," }
        
        let postBody = String(format: "auth=%@&ep_id=%@", authEncode, epStr)
        let urlPath = String(format: BangumiApiKey.UpdateStatus, epID, method.rawValue , BangumiApiKey.Percolator)
        
        self.getJsonFrom(urlPath, post: postBody) { (jsonData) -> Void in
            
            if let json = jsonData as? NSDictionary {
                handler(SendRequestStatus.success)
            } else {
                handler(SendRequestStatus.failed)
            }
        }
    }
    
    // MARK: - GET
    public func getSearchWith(text: String, startIndex: Int, resultLimit: Int, _ handler: ([AnimeSubject]?, count: Int, NSError?) -> Void) {
        let authEncode = userData!.authEncode
        let urlPath = String(format: BangumiApiKey.SearchDetail, text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, resultLimit, startIndex, BangumiApiKey.Percolator, authEncode)
        
        getJsonFrom(urlPath) { (jsonData) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if let json = jsonData as? NSDictionary,
            let count = json["results"] as? Int,
            let list = json["list"] as? [NSDictionary] {
                if count == 1 {
                    handler(nil, count: 0, NSError(domain: "", code: 0, userInfo: nil))
                    return
                }
                
                var animeSubjectList = [AnimeSubject]()
                for subject in list {
                    animeSubjectList.append(AnimeSubject(animeSubjectDict: subject))
                }
                
                handler(animeSubjectList, count: count-1, nil)
            } else {
                handler(nil, count: 0, NSError(domain: "", code: 0, userInfo: nil))
            }
        }
    }
    
    // GET
    public func getEpCollectInfo(animeItem: Anime, _ handler: (SendRequestStatus, EpsCollectInfo?) -> Void) {
        
        let authEncode = userData!.authEncode
        let epsID = animeItem.subject.id
        
        let urlPath = String(format: BangumiApiKey.SubjectCollectionInfo, epsID, BangumiApiKey.Percolator, authEncode)
        
        getJsonFrom(urlPath) { (jsonData) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if let json = jsonData as? NSDictionary {
                handler(.success, EpsCollectInfo(infoDict: json))
            } else {
                handler(.failed, nil)
            }
        }   // getJsonFrom(…)
    }
    
    // GET
    public func getSubjectStatus(subjectID: Int, _ handler: (SubjectItemStatus) -> Void) {
        
        let authEncode = userData!.authEncode
        let uid = userData!.id
        
        let urlPath = String(format: BangumiApiKey.UserSubject, uid, subjectID, BangumiApiKey.Percolator, authEncode)
        var subjectStatus = SubjectItemStatus()
        
        getJsonFrom(urlPath) { (jsonData) -> Void in
            
            if jsonData != nil {
                if let subjectStatusDict = jsonData as? NSDictionary {
                    subjectStatus = SubjectItemStatus(subjectStatusDict: subjectStatusDict)
                }
            }
            
            handler(subjectStatus)
        }
    }
    
    // GET
    public func getSubjectStatus(uid: Int, authEncode: String, handler: ([Int: SubjectItemStatus]) -> Void) {
        let urlPath = String(format: BangumiApiKey.UserSubjectAll, uid, BangumiApiKey.Percolator, authEncode)
        var subjectAllStatus = [Int: SubjectItemStatus]()
        
        getJsonFrom(urlPath) { (jsonData) -> Void in
            
            if jsonData != nil {
                
                if let json = jsonData as? [NSDictionary] {
                    for subjectStausDict in json {
                        let subjectID = subjectStausDict[BangumiKey.subjectID] as! Int
                        subjectAllStatus[subjectID] = SubjectItemStatus(subjectStatusDict: subjectStausDict)
                    }
                }
            }
            
            handler(subjectAllStatus)
        }
    
    }
    
    public func getItemLargeDetail(id: Int, handler: (AnimeDetailLarge?) -> Void) {
        let urlPath = String(format: BangumiApiKey.ItemDetailLarge, id)
        
        getJsonFrom(urlPath){ (jsonData) -> Void in
            
            if jsonData != nil {
                if let jsonDict = jsonData as? NSDictionary {
                    handler(AnimeDetailLarge(json: jsonDict))
                } else {
                    handler(nil)
                }
            } else {
                handler(nil)
            }
        }
    }
    
    public func getSubjectDetailLarge(id: Int, handler: (AnimeDetailLarge?) -> Void) {
        var urlPath = String(format: BangumiApiKey.ItemDetailLarge, id)
        
        let cache = Shared.JSONCache
        let URL = NSURL(string: urlPath)!
        
        cache.fetch(URL: URL, failure: { (error) -> () in
            if error != nil {
                self.getJsonFrom(urlPath) { (jsonData) -> Void in
                    
                    if jsonData != nil {
                        if let jsonDict = jsonData as? NSDictionary {
                            handler(AnimeDetailLarge(json: jsonDict))
                        } else {
                            handler(nil)
                        }
                    } else {
                        handler(nil)
                    }
                }
            } else {
                NSLog("---> cache.fetch failure block : error is nil, so -->> success")
            }
        }, success: { JSON in
            if self.isJsonDataAvailable(JSON as? AnyObject) {
                
                let jsonData = JSON.dictionary
                handler(AnimeDetailLarge(json: jsonData))
                
            } else {
                
                self.getJsonFrom(urlPath) { (jsonData) -> Void in
                    if jsonData != nil {
                
                        if let jsonDict = jsonData as? NSDictionary {
                            handler(AnimeDetailLarge(json: jsonDict))
                        } else {
                            handler(nil)
                        }
                    } else {
                        handler(nil)
                    }
                }
                
            }
        })  // cache.fetch(…) { … } { … }
    }
    
    // MARK: Collection: get user watching anime
    public func getUserWatching(userID: Int, handler: ([Anime]?) -> Void) {
        
        let urlPath = String(format: BangumiApiKey.UserWatching, userID)
        
        getJsonFrom(urlPath) { (jsonData) -> Void in
            
            if jsonData != nil {
                var animeArr = [Anime]()
                let json = jsonData as! [NSDictionary]
                for animeDict in json {
                    let anime = Anime(json: animeDict)
                    animeArr.append(anime)
                }
                handler(animeArr)
            } else {
                handler(nil)
            }
        }
    }
    
    // MARK: Login
    public func userLogin(email: String, password pass: String, handler: (User?) -> Void) {
        
        let postBody = String(format: "username=%@&password=%@", email, pass)
        let urlPath = String(format: BangumiApiKey.Auth, BangumiApiKey.Percolator)
        
        getJsonFrom(urlPath, post: postBody) { (jsonData) -> Void in
            
            if jsonData != nil {
                let json = jsonData as! NSDictionary
                handler(User(json: json))
            } else {
                handler(nil)
            }
        }
    }
    
    // MARK: -
    // MARK: Async methods
    // MARK: GET
    private func getJsonFrom(urlPath: String, handler: (AnyObject?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 15)
        request.HTTPMethod = "GET"
        request.setValue("application/json;charest=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPShouldHandleCookies = true
        
        fetchJsonData(request, handler: handler)
    }
    
    // MARK: POST
    private func getJsonFrom(urlPath: String, post postBody: String, handler: (AnyObject?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 15)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPShouldHandleCookies = true
        
        fetchJsonData(request, handler: handler)
    }
    
    // MARK: JSON
    private func fetchJsonData(request: NSMutableURLRequest, handler: (AnyObject?) -> Void) {

        let task = urlSession.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            // Parse JSON data
            if error != nil {
                print(error!.localizedDescription)
                handler(nil)
            } else {
                if let json: AnyObject = self.parseJsonData(data!) {
                    handler(json)
                } else {
                    handler(nil)
                }
            }
            
//            NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity: 1024, diskCapacity: 0, diskPath: nil))
        })
        

        task.resume()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    private func parseJsonData(data: NSData) -> AnyObject? {
        
        var error: NSError?
        var jsonResult: AnyObject?
        
        // FIXME: Swift 2.0
        do {
            jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
        } catch let error1 as NSError {
            error = error1
            jsonResult = nil
        }
        
        if error != nil {
            print(error?.localizedDescription)
            return nil
        }
        
        if isJsonDataAvailable(jsonResult) {
            return jsonResult
        } else {
            return nil
        }
    }
    
    private func isJsonDataAvailable(json: AnyObject?) -> Bool {
        
        if json != nil {
            if let dict = json as? NSDictionary,
            let code = dict["code"] as? Int,
            let error = dict["error"] as? String {

                NSLog("HTTP request error: request: %@, error: %@, code: %d", dict["request"] as? String ?? "", error, code)
                switch code {
                case 200:
                    // That is available update post, get relax
                    return true
                case 400:   // FIXME: Nothing found with that ID, need decoupling...
                    SwiftNotice.noticeOnSatusBar("未标记条目", autoClear: true, autoClearTime: 3)
                    return false
                case 401:   // Unauthorized
                    SwiftNotice.noticeOnSatusBar("验证信息过期，请重新登录", autoClear: true, autoClearTime: 10)
                    return false
                case 404: fallthrough
                case 405: fallthrough
                case 413: fallthrough
                    
                default: return false
                }   // switch code { … }
            }
        }
        
        return true
    }
}

extension BangumiRequest {
    public func getSubjectHTML(subjectID ID: Int, handler: (String?) -> Void) {
        let urlPath = String(format: "http://bgm.tv/subject/%d", ID)
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15)
        request.HTTPMethod = "GET"
        request.HTTPShouldHandleCookies = true
        
        fetchHTMLData(request) { (html) -> Void in
            handler(html)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    private func fetchHTMLData(request: NSMutableURLRequest, handler: (String?) -> Void) {
        
        let task = urlSession.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            guard let data = data,
                let html = String(data: data, encoding: NSUTF8StringEncoding)
                where error == nil else {
                    print(error!.localizedDescription)
                    handler(nil)
                    return
            }
            
            handler(html)
        })
        
        
        task.resume()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

}

public enum SendRequestStatus {
    case timeout
    case failed
    case success
}