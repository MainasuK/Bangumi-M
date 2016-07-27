//
//  CGPoint.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-16.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//


import UIKit

extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt(self.x*self.x + self.y*self.y)
    }
    
}
