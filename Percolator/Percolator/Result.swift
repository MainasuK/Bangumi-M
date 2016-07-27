//
//  Result.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-11.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import Alamofire

enum Result<T> {
    case success(T)
    case failure(ErrorProtocol)
}

extension Result {
    
    func resolve() throws -> T {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
    init(_ expr: @noescape () throws -> T) {
        do {
            let value = try expr()
            self = Result.success(value)
        } catch {
            self = Result.failure(error)
        }
    }
    
}

extension Result {

    func map<U>(_ transform: @noescape (T) -> U) -> Result<U> {
        switch self {
        case .success(let t):
            return .success(transform(t))
        case .failure(let e):
            return .failure(e)
        }
    }
    
    func flatMap<U>(_ transform: @noescape (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let t):
            return transform(t)
        case .failure(let e):
            return .failure(e)
        }
    }
    
}


//extension Result {
//    
//    typealias Response = Alamofire.Response<T, NSError>
//    
//    init(from response: Response) {
//        switch response.result {
//        case .success(let val):
//            self = .success(val)
//        case .failure(let error):
//            self = .failure(error)
//        }
//    }
//    
//}
