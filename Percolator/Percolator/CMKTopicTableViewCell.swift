//
//  CMKTopicTableViewCell.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-21.
//
//

import UIKit

class CMKTopicTableViewCell: UITableViewCell {

    @IBOutlet weak var animeImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    
    var url: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
