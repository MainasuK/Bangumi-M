//
//  SubjectCollectionReusableView.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-21.
//
//  Ref: https://github.com/strawberrycode/SCSectionBackground

import UIKit

class SubjectCollectionReusableView: UICollectionReusableView {
 
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let subjectLayoutAttributes = layoutAttributes as! SubjectCollectionViewLayoutAttributes
        self.backgroundColor = subjectLayoutAttributes.color
    }
    
}
