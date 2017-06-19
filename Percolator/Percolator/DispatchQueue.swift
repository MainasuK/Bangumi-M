//
//  DispatchQueue.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-8-20.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    public class var cmkJson: DispatchQueue {
        return DispatchQueue(label: "com.mainasuk.json", qos: .userInitiated, attributes: .concurrent)
    }
    
}
