//
//  SubjectCollectionViewBookCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-20.
//
//  Ref: https://github.com/strawberrycode/SCSectionBackground

import UIKit
import AlamofireImage

class SubjectCollectionViewBookCell: SubjectCollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    // No subtitle for book
    
    override func configure(with item: ItemType) {
        bookNameLabel.text = item.title
        
        let size = bookCover.bounds.size
        if let url = URL(string: item.coverUrlPath) {
            bookCover.af_setImageWithURL(url, placeholderImage: UIImage.fromColor(.placeholder, size: size), imageTransition: .crossDissolve(0.2))
        } else {
            bookCover.image = UIImage.fromColor(.placeholder, size: size)
        }
        
        // Set iamge view corner
        bookCover.layer.borderColor = UIColor.percolatorGray.cgColor
        bookCover.layer.borderWidth = 0.5
        
        // Set background color
        backgroundColor = UIColor.white
    }
    
}
