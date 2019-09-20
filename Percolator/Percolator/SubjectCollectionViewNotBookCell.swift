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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.layer.masksToBounds = true
        nameCNLabel.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coverImageView.af_cancelImageRequest()
        coverImageView.layer.removeAllAnimations()
        coverImageView.image = nil
    }
    
    override func configure(with item: ItemType) {
        let subjectItem = item.0
        
        nameLabel.text = subjectItem.title
        nameCNLabel.text = subjectItem.subtitle
        
        coverImageView.backgroundColor = .systemFill
        let size = CGSize(width: 1, height: 1)
        if let url = URL(string: subjectItem.coverUrlPath) {
            coverImageView.af_setImage(withURL: url, placeholderImage: UIImage(), progressQueue: DispatchQueue.global(qos: .userInitiated), imageTransition: .crossDissolve(0.2))
        } else {
            coverImageView.image = nil
        }
        
        // Set iamge view corner
        coverImageView.layer.borderColor = UIColor.percolatorGray.cgColor
        coverImageView.layer.borderWidth = 0.5
        
        backgroundColor = .secondarySystemGroupedBackground
    }
    
}
