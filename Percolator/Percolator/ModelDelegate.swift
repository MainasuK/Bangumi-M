//
//  ModelDelegate.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-12.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

protocol ModelDelegate {
    
    associatedtype T
    
    func append(contentsOf items: [T])
    func clean()
    
}
