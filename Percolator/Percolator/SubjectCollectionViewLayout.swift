//
//  SubjectCollectionViewLayout.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-6-21.
//  
//  Ref: https://github.com/strawberrycode/SCSectionBackground

import UIKit

class SubjectCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        register(SubjectCollectionReusableView.self, forDecorationViewOfKind: "sectionBackground")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var allAttributes = [UICollectionViewLayoutAttributes]()
        
        if let attributes = attributes {
            
            var lastDecorationAttrFrame = CGRect.zero
            for attr in attributes {
                
                if !(attr.representedElementCategory == UICollectionElementCategory.cell) {
                    continue
                }
                
                // Create decoration attributes
                let decorationAttributes = SubjectCollectionViewLayoutAttributes(forDecorationViewOfKind: "sectionBackground", with: attr.indexPath)
                
                // Set the color(s)
                if attr.indexPath.section == 0 {  // Book section
                    decorationAttributes.color = UIColor.myAnimeListBackground
                } else {                            // Not book section
                    decorationAttributes.color = UIColor.white
                }
                
                // Make the decoration view span the entire row
                let tmpWidth = self.collectionView!.bounds.width
                let tmpHeight = attr.bounds.height + self.minimumLineSpacing + self.sectionInset.top / 2 + self.sectionInset.bottom / 2
                let frame = CGRect(x: 0, y: attr.frame.origin.y - self.sectionInset.top, width: tmpWidth, height: tmpHeight)
                
                // Only add one decoration for one row
                if frame.equalTo(lastDecorationAttrFrame) {
                    continue
                } else {
                    lastDecorationAttrFrame = frame
                }
                
                decorationAttributes.frame = frame
                
                // Set the zIndex to be behind the item
                decorationAttributes.zIndex = attr.zIndex - 1
                
                // Add the attribute to the list
                allAttributes.append(decorationAttributes)
            }
            
            // Combine the items and decorations arrays
            allAttributes.append(contentsOf: attributes)
        }
        
        return allAttributes
    }
    
}
