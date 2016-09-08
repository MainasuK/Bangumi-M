//
//  CollectionViewDataSource.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class CollectionViewDataSource<Model: DataProvider & HeaderDataProvider, Cell: ConfigurableCell, Header: ConfigurableHeader>: DataSource<Model>, UICollectionViewDataSource where Model.ItemType == Cell.ItemType, Cell: UICollectionViewCell, Model.HeaderItemType == Header.ItemType, Header: UICollectionReusableView {
    
    deinit {
        consolePrint("CollectionViewDataSource deinit")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = model.identifier(at: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Cell should be configurable")
        }
        
        cell.isLast = indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1
        cell.configure(with: model.item(at: indexPath))
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: model.headerIdentifier(at: indexPath), for: indexPath) as! Header
        
        headerView.configure(with: model.headerItem(at: indexPath))
        
        return headerView
    }
    
}
