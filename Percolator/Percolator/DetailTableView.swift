//
//  DetailTableView.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

// Fix tableView section header location issue by side effect from custom tableView offset  
// Ref: http://www.b2cloud.com.au/tutorial/uitableview-section-header-positions/
class DetailTableView: UITableView {

    var shouldManuallyLayoutHeaderViews = false
    var headerViewInsets = UIEdgeInsets.zero
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if shouldManuallyLayoutHeaderViews {
            layoutHeaderView()
        }
    }
    
    func setHeaderView(_ insets: UIEdgeInsets) {
        headerViewInsets = insets
        
        shouldManuallyLayoutHeaderViews = !UIEdgeInsetsEqualToEdgeInsets(headerViewInsets, .zero)
        setNeedsLayout()
    }
    
    private func layoutHeaderView() {
        let inset = contentInset
        let offset = contentOffset
        let sectionViewMinimumOriginY = headerViewInsets.top + inset.top + offset.y
        
        for section in 0 ..< numberOfSections {
            if let sectionView = headerView(forSection: section) {
                var sectionHeaderViewFrame = sectionView.frame
                let sectionFrame = rect(forSection: section)
                let y = sectionFrame.origin.y
                
                sectionHeaderViewFrame.origin.y = ((y < sectionViewMinimumOriginY) ? sectionViewMinimumOriginY : y);
                
                // If it's not last section, manually 'stick' it to the below section if needed
                // Section frame include header… Really?
                // Yep, SDK say that "includes header, footer and all rows"
                if section < numberOfSections - 1 {
                    let nextSectionFrame = rect(forSection: section + 1)
                    if sectionHeaderViewFrame.maxY > nextSectionFrame.minY {
                        sectionHeaderViewFrame.origin.y = nextSectionFrame.origin.y - sectionHeaderViewFrame.size.height
                    }
                }
                
                sectionView.frame = sectionHeaderViewFrame
            }   // if let …
        }   // for section in …
    }

}
