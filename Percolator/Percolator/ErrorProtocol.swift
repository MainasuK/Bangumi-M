//
//  ErrorProtocol.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-16.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension ErrorProtocol {
    
    func throwMyself() throws -> Void {
        throw self
    }
    
}
