//
//  DetailTableViewCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell, ConfigurableCell {
    
    typealias ItemType = DetailTableViewModel.ItemType
    
    var isLast: Bool = false
    
    func configure(with item: DetailTableViewCell.ItemType) { }

}
