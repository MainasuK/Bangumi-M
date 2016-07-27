//
//  SubjectWrapper.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-26.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

// Wrap subject struct in class to comform AnyObject Protocol
class SubjectWrapper {
    private let subject: Subject
    
    init(with subject: Subject) {
        self.subject = subject
    }
}

extension SubjectWrapper {
    
    func saveToCoreData() -> Bool {
        return subject.saveToCoreData()
    }
    
    func deleteFromCoreData() -> Bool {
        return subject.deleteFromCoreData()
    }
    
    func isSaved() -> Bool {
        return subject.isSaved()
    }
    
}
