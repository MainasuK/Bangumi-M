//
//  UIButton.swift
//  Bangumi M
//
//  Created by Cirno MainasuK on 2017-9-1.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import UIKit

extension UIButton {

    func setTitleWithoutAnimation(_ title: String, for state: UIControlState) {
        UIView.performWithoutAnimation {
            setTitle(title, for: state)
            layoutIfNeeded()
        }
    }

}
