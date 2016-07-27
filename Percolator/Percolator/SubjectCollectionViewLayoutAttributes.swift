//
//  SubjectCollectionViewLayoutAttributes.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-21.
//
//  Ref: https://github.com/strawberrycode/SCSectionBackground

import UIKit

class SubjectCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var color = UIColor.white()
    
    override func copy(with zone: NSZone? = nil) -> AnyObject {
        let newAttributes = super.copy(with: zone) as! SubjectCollectionViewLayoutAttributes
        newAttributes.color = self.color.copy(with: zone) as! UIColor
        
        return newAttributes
    }
}
