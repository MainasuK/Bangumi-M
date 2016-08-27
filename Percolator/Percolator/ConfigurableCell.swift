//
//  ConfigurableCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-13.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

protocol ConfigurableCell: class {
    
    associatedtype ItemType
    
    /// Is the last cell of the section
    var isLast: Bool { get set }
    
    /// Configure cell with associatedtype
    func configure(with item: ItemType)
    
}
