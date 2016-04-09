//
//  CMKCollectionViewCell.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-20.
//
//

import UIKit

let collectionViewCellIdentifier: NSString = "CollectionViewCell"

class CMKCollectionView: UICollectionView {
    
    var indexPath: NSIndexPath!
}

class CMKCollectionViewCell: UICollectionViewCell {
    
    var url: String?
    
    @IBOutlet weak var animeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
}

class CMKCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var HeadlineLabel: UILabel!
    @IBOutlet weak var collectionView: CMKCollectionView!

//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsetsMake(4, 5, 4, 5)
//        layout.minimumLineSpacing = 5
//        layout.itemSize = CGSizeMake(91, 91)
//        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
//        self.collectionView = CMKCollectionView(frame: CGRectZero, collectionViewLayout: layout)
//        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier as! String)
//        self.collectionView.backgroundColor = UIColor.whiteColor()
//        self.collectionView.showsHorizontalScrollIndicator = false
//        self.contentView.addSubview(self.collectionView)
//        self.layoutMargins = UIEdgeInsetsMake(10, 0, 10, 0)
//    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, index: NSInteger) {
//        
//        self.collectionView.dataSource = delegate
//        self.collectionView.delegate = delegate
//        self.collectionView.tag = index
//        self.collectionView.reloadData()
//    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, indexPath: NSIndexPath) {
        
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.indexPath = indexPath
        self.collectionView.tag = indexPath.row
        self.collectionView.reloadData()
    }

}
