//
//  DataSource.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class DataSource<Model: DataProvider>: NSObject {
    
    weak var model: Model!
    
    required init(model: Model) {
        self.model = model
    }
    
}
