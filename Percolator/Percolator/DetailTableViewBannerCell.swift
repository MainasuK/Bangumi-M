//
//  DetailTableViewBannerCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-19.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Cosmos

class DetailTableViewBannerCell: DetailTableViewCell {
    
    weak var delegate: DetailTableViewBannerCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var airDateLabel: UILabel!
    
    @IBOutlet weak var collectButton: CMKCollectButton! {
        didSet {
            // Add border
            collectButton.layer.cornerRadius = 5
            collectButton.layer.borderWidth = 1   // 2 px
            collectButton.layer.borderColor = UIColor.collectButtonTint().cgColor
            
            // Set title color for hightlight state
            collectButton.setTitleColor(UIColor.white(), for: UIControlState.highlighted)
        }
    }
    
    @IBAction func collectButtonPressed(_ sender: CMKCollectButton) {
        delegate?.collectButtonPressed(sender)
    }
    
    override func configure(with item: DetailTableViewCell.ItemType) {
        super.configure(with: item)
        
        do {
            let detailItem = try item.resolve()
            switch detailItem {
            case .subject(let subject):
                configureLabel(with: subject)
                
            default: return
            }
            
        } catch {
            consolePrint("Banner cell get error: \(error)")
        }
        
    }

}

extension DetailTableViewBannerCell {
    
    private func configureLabel(with subject: Subject) {
        nameLabel.text = subject.name
        nameCNLabel.text = subject.nameCN
        
        ratingView.settings.fillMode = .precise
        ratingView.rating = subject.rating.score * 0.5
        ratingLabel.text = (subject.rating.score == 0) ? "--" : "\(subject.rating.score)"
        
        typeLabel.text = PercolatorKey.typeArr[subject.type]
        
        let ratingCount = subject.rating.count.reduce(0) { $0 + $1.value }
        ratingCountLabel.text = "\(ratingCount) 人评分"
        
        
        summaryLabel.text = subject.summary
        airDateLabel.text = subject.airDate
    }
    
}

