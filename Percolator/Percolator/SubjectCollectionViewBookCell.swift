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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bookNameLabel.layer.masksToBounds = true
        indicatorLabel.layer.masksToBounds = true
    }
    
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
        
        bookCover.backgroundColor = .systemFill
        let size = CGSize(width: 1, height: 1)
        if let url = URL(string: subjectItem.coverUrlPath) {
            bookCover.af_setImage(withURL: url, placeholderImage: UIImage(), progressQueue: DispatchQueue.global(qos: .userInitiated), imageTransition: .crossDissolve(0.2))
        } else {
            bookCover.image = nil
        }
        
        // Set iamge view corner
        bookCover.layer.borderColor = UIColor.percolatorGray.cgColor
        bookCover.layer.borderWidth = 0.5
        
        // Set background color
        backgroundColor = .secondarySystemGroupedBackground
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
