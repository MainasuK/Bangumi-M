//
//  ConfigurableHeader.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-25.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

protocol ConfigurableHeader {
    
    associatedtype ItemType
    
    func configure(with item: ItemType)
    
}
