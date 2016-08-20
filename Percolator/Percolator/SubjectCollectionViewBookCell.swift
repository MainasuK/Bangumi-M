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
    
    typealias ModelCollectError = SubjectCollectionViewModel.ModelCollectError
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    // No subtitle for book
    @IBOutlet weak var indicatorLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bookCover.af_cancelImageRequest()
        bookCover.layer.removeAllAnimations()
        bookCover.image = nil
    }
    
    override func configure(with item: ItemType) {
        let subjectItem = item.0
        bookNameLabel.text = subjectItem.title
        
        configureIndicator(with: item.1)
        
        let size = bookCover.bounds.size
        if let url = URL(string: subjectItem.coverUrlPath) {
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

extension SubjectCollectionViewBookCell {
    
    fileprivate func configureIndicator(with result: Result<CollectInfoSmall>) {
        indicatorLabel.text = ""
        
        do {
            let collect = try result.resolve()
            indicatorLabel.text = collect.name
            
        } catch ModelCollectError.unknown {
            consolePrint("Unknown subject collect info")
        } catch {
            consolePrint(error)
        }
    }
    
}
