//
//  SubjectCollectionViewCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-24.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class SubjectCollectionViewCell: UICollectionViewCell, ConfigurableCell {
    
    typealias ItemType = SubjectCollectionViewModel.ItemType
    
    var isLast = false
    
    func configure(with item: ItemType) {
        // Do nothing
    }
    
}
