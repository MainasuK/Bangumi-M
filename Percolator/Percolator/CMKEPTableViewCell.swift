//
//  CMKEPTableViewCell.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-22.
//
//

import UIKit

class CMKEPTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var epTitleLabel: UILabel!
    @IBOutlet weak var airDateLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    var id = 0
    var subjectID = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func initCell(name: String, type: Int, reply: Int, status: Int, airDate: String) {
//        
//    }

}
