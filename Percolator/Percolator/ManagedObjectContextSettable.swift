//
//  ManagedObjectContextSettable.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-17.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectContextSettable: class {
    var context: NSManagedObjectContext! { get set }
}
