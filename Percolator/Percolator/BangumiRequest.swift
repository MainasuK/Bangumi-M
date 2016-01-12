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
        
        let urlPath = String(format: BangumiApiKey.SearchDetail, text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, resultLimit, startIndex)
        
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
        
        debugPrint("---> cache.fetch Start")
        cache.fetch(URL: URL, failure: { (error) -> () in
            if error != nil {
                print("---> cache.fetch failed")
                NSLog("Haneke fetch JSON failed, try to fetch via NSURLSession")
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
                print("---> cache.fetch failure block : error is nil, so -->> success")
            }
        }, success: { JSON in
            if self.isJsonDataAvailable(JSON as? AnyObject) {
                
                let jsonData = JSON.dictionary
                handler(AnimeDetailLarge(json: jsonData))
                print("---> cache.fetch from cache success")
                
            } else {
                print("---> cache.fetch from cache but failed, try to fetch via NSURLSession…")
                self.getJsonFrom(urlPath) { (jsonData) -> Void in
                    print("---> cache.fetch via NSURLSession…")
                    if jsonData != nil {
                
                        if let jsonDict = jsonData as? NSDictionary {
                            print("---> return and success")
                            handler(AnimeDetailLarge(json: jsonDict))
                        } else {
                            print("---> return but failed")
                            handler(nil)
                        }
                    } else {
                        print("---> return nil")
                        handler(nil)
                    }
                }
                
            }
        })  // cache.fetch(…) { … } { … }
        
//        ---- None cache method ----
//        getJsonFrom(urlPath) { (jsonData) -> Void in
//            
//            if jsonData != nil {
//                if let jsonDict = jsonData as? NSDictionary {
//                    handler(AnimeDetailLarge(json: jsonDict))
//                } else {
//                    handler(nil)
//                }
//            } else {
//                handler(nil)
//            }
//        }
    }
    
    // MARK: Collection: get user watching anime
    public func getUserWatching(userID: Int, handler: ([Anime]?) -> Void) {
        
        let urlPath = String(format: BangumiApiKey.UserWatching, userID)
        
        getJsonFrom(urlPath) { (jsonData) -> Void in
            
            if jsonData != nil {
                var animeArr = [Anime]()
                let json = jsonData as! [NSDictionary]
                print("$ Bangumi_Request: Get anime item")
                for animeDict in json {
                    let anime = Anime(json: animeDict)
                    print("\(anime.subject.id): \(anime.name) ep_status: \(anime.epStatus)")
                    animeArr.append(anime)
                }
                print("$ Bangumi_Request: Pass anime list to VC")
                handler(animeArr)
            } else {
                print("$ Bangumi_Request: Fail to get anime list, pass nil to handler")
                handler(nil)
            }
        }
    }
    
    // MARK: Login
    public func userLogin(email: String, password pass: String, handler: (User?) -> Void) {
        
        let postBody = String(format: "username=%@&password=%@", email, pass)
        let urlPath = String(format: BangumiApiKey.Auth, BangumiApiKey.Percolator)
        
        debugPrint("$ Bangumi_Request: Fetch user auth json")
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
        debugPrint("$ Bangumi_Request: fetch JSON from urlPath: \(urlPath)")
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 15)
        request.HTTPMethod = "GET"
        request.HTTPShouldHandleCookies = false
        
        fetchJsonData(request, handler: handler)
    }
    
    // MARK: POST
    private func getJsonFrom(urlPath: String, post postBody: String, handler: (AnyObject?) -> Void) {
        debugPrint("$ Bangumi_Request: fetch JSON urlPath: \(urlPath)")
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 15)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPShouldHandleCookies = false
        
        fetchJsonData(request, handler: handler)
    }
    
    // MARK: JSON
    private func fetchJsonData(request: NSMutableURLRequest, handler: (AnyObject?) -> Void) {
    
        let urlSession = NSURLSession(configuration: .ephemeralSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
//        let urlSession = NSURLSession(configuration: .ephemeralSessionConfiguration())
        let task = urlSession.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            // Parse JSON data
            if error != nil {
                print("$ Bangumi_Request: fetchJsonData...")
                print(error!.localizedDescription)
                handler(nil)
            } else {
                if var json: AnyObject = self.parseJsonData(data!) {
                    handler(json)
                } else {
                    handler(nil)
                }
            }
            
            NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity: 1024, diskCapacity: 0, diskPath: nil))
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
            print("$ Bangumi_Request: parseJsonData...")
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
                print("$ Bangumi_Request: isJsonDataAvailable...")
                print("Fetch JSON failed, with error: " + error)

                NSLog("HTTP request error: request: %@, error: %@, code: %d", dict["request"] as? String ?? "", error, code)
                switch code {
                case 200:
                    print("That is available update post, get relax")
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
        
        print("$ Bangumi_Request: Fetch JSON successful")
        return true
    }
}

public enum SendRequestStatus {
    case timeout
    case failed
    case success
}