//
//  CDSubject.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-26.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension CDSubject {
    
    func toSubject() -> Subject {
        return Subject(from: self)
    }
    
}
