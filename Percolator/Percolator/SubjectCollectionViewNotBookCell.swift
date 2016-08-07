//
//  SubjectCollectionViewNotBookCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class SubjectCollectionViewNotBookCell: SubjectCollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    
    override func configure(with item: ItemType) {
        let subjectItem = item.0
        
        nameLabel.text = subjectItem.title
        nameCNLabel.text = subjectItem.subtitle
        
        let size = coverImageView.bounds.size
        if let url = URL(string: subjectItem.coverUrlPath) {
            coverImageView.af_setImageWithURL(url, placeholderImage: UIImage.fromColor(.placeholder, size: size), imageTransition: .crossDissolve(0.2))
        } else {
            coverImageView.image = UIImage.fromColor(.placeholder, size: size)
        }
        
        // Set iamge view corner
        coverImageView.layer.borderColor = UIColor.percolatorGray.cgColor
        coverImageView.layer.borderWidth = 0.5
    }
    
}
