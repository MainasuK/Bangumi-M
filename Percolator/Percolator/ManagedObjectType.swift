//
//  ManagedObjectType.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    
    // Default value
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    static var sortedFetchRequest: NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        
        return request
    }
    
}
