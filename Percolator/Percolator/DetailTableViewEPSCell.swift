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
    
    static let SFAlternativesFormRegularFont: UIFont = {
        let descriptor = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightRegular).fontDescriptor
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
        return UIFont(descriptor: adjusted, size: 17.0)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sortStatusView.layer.cornerRadius = 6.0
        sortStatusView.layer.borderWidth = 0.5
        sortStatusView.layer.borderColor = UIColor(red: 0.00, green: 0.38, blue: 0.74, alpha: 1.00).cgColor
        
        commentButton.titleLabel?.font = type(of: self).SFAlternativesFormFont
        
        // Move arrow to right. Awesome
        // Ref: http://stackoverflow.com/questions/7100976/how-do-i-put-the-image-on-the-right-side-of-the-text-in-a-uibutton
        commentButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        commentButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        commentButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
    }
    
}

extension DetailTableViewEPSCell {
    
    fileprivate func configureLabel(with episode: Episode) {
        
        let attributedText: NSMutableAttributedString = {
            let sortAttributes = [NSFontAttributeName : type(of: self).SFAlternativesFormRegularFont]
            let nameAttributes = [NSFontAttributeName : UIFont(name: "HiraginoSans-W3", size: 16.0) ?? type(of: self).SFAlternativesFormRegularFont]
            
            let string = NSMutableAttributedString()
            string.append(NSAttributedString(string: episode.sortString, attributes: sortAttributes))
            string.append(NSAttributedString(string: " "))
            string.append(NSAttributedString(string: episode.name, attributes: nameAttributes))
            
            return string
        }()
        nameLabel.attributedText = attributedText
        nameCNLabel.text = episode.nameCN
        
        let title = "\(episode.comment)"
        commentButton.setTitle(title, for: .normal)
    }
    
    fileprivate func configureProgressView(with status: Status?) {
        var color = UIColor.clear
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
    
    fileprivate func configureButton(with episode: Episode) {
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
