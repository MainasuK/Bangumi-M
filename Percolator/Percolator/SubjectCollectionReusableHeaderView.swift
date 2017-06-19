//
//  SubjectCollectionReusableHeaderView.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-21.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class SubjectCollectionReusableHeaderView: UICollectionReusableView, ConfigurableHeader {
    
    typealias ItemType = String
    
    @IBOutlet weak var typeLabel: UILabel!
    
    func configure(with item: SubjectCollectionReusableHeaderView.ItemType) {
        typeLabel.text = item
        
        if item != "" {
            backgroundColor = UIColor.white.withAlphaComponent(0.6)
        } else {
            backgroundColor = UIColor.myAnimeListBackground
        }
    }
        
}
