//
//  AnimeDetailTableViewCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-16.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit

class AnimeDetailTableViewCell: UITableViewCell {
    
    var animeItem = Anime()
    
    @IBOutlet weak var AnimeDetailImageView: UIImageView!
    @IBOutlet weak var nameCNLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
