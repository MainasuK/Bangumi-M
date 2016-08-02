//
//  DetailTableViewEPSCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-19.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class DetailTableViewEPSCell: DetailTableViewCell {
    
    weak var delegate: DetailTableViewEPSCellDelegate?
    
    // Ref: WWDC 15 - Session 803
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

    @IBOutlet weak var sortStatusView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        delegate?.commentButtonPressed(sender)
    }

    override func configure(with item: DetailTableViewCell.ItemType) {
        super.configure(with: item)
        
        do {
            let detailItem = try item.resolve()
            switch  detailItem {
            case .episode(let episode, let status):
                configureLabel(with: episode)
                configureProgressView(with: status)
                configureButton(with: episode)
                
            default: return
            }
            
        } catch {
            consolePrint("Topic cell get error: \(error)")
        }
        
    }
}

extension DetailTableViewEPSCell {
    
    private func configureLabel(with episode: Episode) {
        
        nameLabel.text = "\(episode.sortString) \(episode.name)"
        nameCNLabel.text = episode.nameCN
        
        let title = "\(episode.comment)"
        commentButton.titleLabel?.font = self.dynamicType.SFAlternativesFormFont
        commentButton.setTitle(title, for: .normal)
        commentButton.setTitle(title, for: .selected)
        
        // Move arrow to right. Awesome
        // Ref: http://stackoverflow.com/questions/7100976/how-do-i-put-the-image-on-the-right-side-of-the-text-in-a-uibutton
        commentButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        commentButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        commentButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
    }
    
    private func configureProgressView(with status: Status?) {
        sortStatusView.layer.cornerRadius = (sortStatusView.bounds.width == 0) ? 6.0 : sortStatusView.bounds.width / 2.0
        sortStatusView.layer.borderWidth = 0.5
        sortStatusView.layer.borderColor = UIColor(red: 0.00, green: 0.38, blue: 0.74, alpha: 1.00).cgColor

        var color: UIColor = UIColor.clear
        sortStatusView.tintColor = color
        sortStatusView.backgroundColor = color
        
        let progressStatus = status ?? .none
        switch progressStatus {
        case .watched:      color = UIColor.myWatched
        case .queue:        color = UIColor.myQueue
        case .drop:         color = UIColor.myDrop
        case .none:         color = UIColor.clear
        }
        
        UIView.animate(withDuration: 0.2) { 
            self.sortStatusView.tintColor = color
            self.sortStatusView.backgroundColor = color
            self.sortStatusView.layer.borderColor = (progressStatus != .none) ? color.cgColor : UIColor.lightGray.cgColor
        }
    }
    
    private func configureButton(with episode: Episode) {
        commentButton.tag = episode.id
    }
    
}

// Override the selected and hightlighted method for display subview correctly when selecting cell
extension DetailTableViewEPSCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = sortStatusView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            sortStatusView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = sortStatusView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            sortStatusView.backgroundColor = color
        }
    }

}
