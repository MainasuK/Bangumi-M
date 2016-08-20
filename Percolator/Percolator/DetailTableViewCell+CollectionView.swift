//
//  DetailTableViewCell+CollectionView.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-29.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import QuartzCore
import AlamofireImage

class DetailTableViewCell_CollectionView: DetailTableViewCell {
    
    typealias DetailItem = DetailTableViewModel.DetailItem

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var collectionView: CMKCollectionView!

    override func configure(with item: ItemType) {
        super.configure(with: item)
        
        defer {
            collectionView.reloadData()
        }
        
        guard case let ItemType.success(result) = item,
        case let DetailItem.collection(dataSource, delegate, headline, indexPath) = result else {
            return
        }
        
        headlineLabel.text = headline
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        collectionView.tag = indexPath.row
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass || traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            setCollectionViewEdgeInset()
            layoutIfNeeded()
        }
    }
    
    private func setCollectionViewEdgeInset() {
        let isCompact = (traitCollection.horizontalSizeClass == .compact) ? true : false
        
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset = isCompact ? UIEdgeInsets(top: 0, left: superview?.layoutMargins.left ?? 16, bottom: 0, right: superview?.layoutMargins.right ?? 8) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }

}

class CMKCollectionView: UICollectionView {
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.white.withAlphaComponent(1).cgColor,
                        UIColor.white.withAlphaComponent(0).cgColor,
                        UIColor.white.withAlphaComponent(0).cgColor,
                        UIColor.white.withAlphaComponent(1).cgColor]
        layer.locations = [0.0, 0.02, 0.98, 1.0]
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        
        return layer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = true
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.layer.drawsAsynchronously = true
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutGradientLayer()
    }
    
    private func layoutGradientLayer() {
        let threshold = 20.0 / self.bounds.width
        
        // Fix layout delay issue
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, min(threshold, (abs(self.contentOffset.x) + 0.5) / self.bounds.width) as NSNumber, 0.97, 1.0]
        CATransaction.commit()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.horizontalSizeClass == .compact {
            gradientLayer.isHidden = true
            self.clipsToBounds = false
        } else {
            gradientLayer.isHidden = false
            self.clipsToBounds = true
        }
    }
    
}

class CMKCollectionViewCell: UICollectionViewCell, ConfigurableCell {
    typealias ItemType = DetailTableViewModel.CollectionItem
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var isLast: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        itemImageView.af_cancelImageRequest()
        itemImageView.layer.removeAllAnimations()
        itemImageView.image = nil
    }
    
    func configure(with item: ItemType) {
        setupCellStyle()
        
        switch item {
        case .crt(let crt):
            titleLabel.text = crt.name
            subtitleLabel.text = crt.actors.first?.name ?? ""
            if let urlPath = crt.images.gridUrl,
            let url = URL(string: urlPath) {
                itemImageView.af_setImageWithURL(url, placeholderImage: UIImage.fromColor(.placeholder, size: CGSize(width: 80, height: 80)), imageTransition: .crossDissolve(0.2))
            } else {
                itemImageView.image = UIImage(named: "404")!
            }
        case .staff(let staff):
            titleLabel.text = staff.name
            subtitleLabel.text = staff.jobs.first ?? ""
            if let urlPath = staff.images.gridUrl,
                let url = URL(string: urlPath) {
                itemImageView.af_setImageWithURL(url, placeholderImage: UIImage.fromColor(.placeholder, size: CGSize(width: 80, height: 80)), imageTransition: .crossDissolve(0.2))
            } else {
                itemImageView.image = UIImage(named: "404")!
            }
        }
    }
}

extension CMKCollectionViewCell {
    
    fileprivate func setupCellStyle() {
        itemImageView.layer.drawsAsynchronously = true
        itemImageView.layer.cornerRadius = 5
        itemImageView.layer.borderColor = UIColor.percolatorLightGray.withAlphaComponent(0.8).cgColor
        itemImageView.layer.borderWidth = 0.5  // 1px
    }
    
}
