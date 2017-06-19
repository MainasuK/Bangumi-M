//
//  TopicTableViewCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class TopicTableViewCell: UITableViewCell, ConfigurableCell {
    
    typealias ItemType = TopicTableViewModel.ItemType
    
    static let SFAlternativesFormFont: UIFont = {
        let descriptor = UIFont.systemFont(ofSize: 11.0, weight: UIFontWeightLight).fontDescriptor
        let adjusted = descriptor.addingAttributes(
            [
                UIFontDescriptorFeatureSettingsAttribute: [
                    [
                        UIFontFeatureTypeIdentifierKey: kStylisticAlternativesType,
                        UIFontFeatureSelectorIdentifierKey: kStylisticAltOneOnSelector
                    ]
                ]
            ]
        )
        return UIFont(descriptor: adjusted, size: 11.0)
    }()

    var isLast: Bool = false

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!

    func configure(with item: TopicTableViewCell.ItemType) {
        setupCellStyle()
        
        titleLabel.text = item.title
        userNameLabel.text = item.userName
        dateLabel.text = item.dateStr
        
        commentButton.titleLabel?.font = type(of: self).SFAlternativesFormFont
        commentButton.setTitle("\(item.replies)", for: .normal)
    }
}

extension TopicTableViewCell {
    
    fileprivate func setupCellStyle() {
        // Make cell get readable margin guideline
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        commentButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        commentButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        commentButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
}
