//
//  CMKCollectButton.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-19.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CMKCollectButton: UIButton {
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                backgroundColor = UIColor.collectButtonTint
            }
            else {
                backgroundColor = UIColor.white
            }
            
            super.isHighlighted = newValue
        }
    }

}
