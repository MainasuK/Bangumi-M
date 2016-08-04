//
//  DetailTableViewMoreSubjectCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-19.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class DetailTableViewMoreSubjectCell: DetailTableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var subjectDetailLabel: UILabel!
    
    override func configure(with item: DetailTableViewCell.ItemType) {
        super.configure(with: item)
        
        do {
            let detailItem = try item.resolve()
            switch  detailItem {
            case .subject(_): break
            default: return
            }
            
        } catch {
            consolePrint("Topic cell get error: \(error)")
        }
        
    }

}
