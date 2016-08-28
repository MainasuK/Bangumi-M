//
//  SearchBoxTableViewswift
//  
//
//  Created by Cirno MainasuK on 2015-8-19.
//
//

import UIKit
import AlamofireImage
import MGSwipeTableCell

class SearchBoxTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var animeImageView: UIImageView!
    @IBOutlet weak var savedArrowImageView: UIImageView!
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var airDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    @IBOutlet weak var doingLabel: UILabel!
    
    @IBOutlet weak var indicatorLabel: UILabel!
    
    var isLast: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.layer.masksToBounds = true
        nameCNLabel.layer.masksToBounds = true
        typeLabel.layer.masksToBounds = true
        doingLabel.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        animeImageView.af_cancelImageRequest()
        animeImageView.layer.removeAllAnimations()
        animeImageView.image = nil
    }
}


extension SearchBoxTableViewCell: ConfigurableCell {
    
    typealias ItemType = (Subject, Result<CollectInfoSmall>)
    typealias ModelCollectError = SearchBoxTableViewModel.ModelCollectError
    
    func configure(with item: ItemType) {
        let (subject, result) = item
        setupCellStyle()
        configureLabel(with: subject)
        configureImage(with: subject.images)
        configureIndicator(with: result, subject: subject)
        
        layoutIfNeeded()
    }
    
}

extension SearchBoxTableViewCell {

    fileprivate func configureLabel(with subject: Subject) {
        nameLabel.text = subject.name
        nameCNLabel.text = subject.nameCN
        typeLabel.text = PercolatorKey.typeArr[subject.type]
        doingLabel.text = {
            let doingArr = PercolatorKey.typeDoingArr[subject.type]!
            return "\(subject.collection.doing) 人\(doingArr[2])"
        }()
        
        // Remove null data
        airDateLabel.text = subject.airDate
        
        // Hide label when text is empty
        [nameLabel, nameCNLabel, typeLabel, doingLabel, airDateLabel].forEach { $0?.isHidden = ($0?.text == "") }
        
        savedArrowImageView.isHidden = !subject.isSaved()
    }
    
    fileprivate func configureImage(with images: Images) {
        // Async load image
        let networkStatus = BangumiRequest.shared.networkStatus
        let imageURLValue = (networkStatus == ReachableViaWiFi) ? images.largeUrl : images.mediumUrl
        
        // Network profile
        
        // Use 1.0 MB get 159 subjects. Acceptable
        // let imageURLValue = images.mediumUrl
        
        // Use 1.0 MB get 249 subjects. Awesome
        // let imageURLValue = images.smallUrl
        
        let size = animeImageView.bounds.size
        
        if let urlVal = imageURLValue,
        let url = URL(string: urlVal) {
            animeImageView.af_setImage(withURL: url, placeholderImage: UIImage.fromColor(.placeholder, size: size), progressQueue: DispatchQueue.global(qos: .userInitiated), imageTransition: .crossDissolve(0.2))
        } else {
            animeImageView.image = UIImage.fromColor(.placeholder, size: size)
        }
    }
    
    fileprivate func configureIndicator(with result: Result<CollectInfoSmall>, subject: Subject) {
        indicatorLabel.text = ""
        
        do {
            let collect = try result.resolve()
            indicatorLabel.text = collect.name
            
        } catch ModelCollectError.unknown {
            consolePrint("Unknown subject collect info")
        } catch {
            consolePrint(error)
        }
    }
    
    fileprivate func setupCellStyle() {
        // Make cell get readable margin guideline
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true

        
        // Set iamge view corner
        animeImageView.layer.borderColor = UIColor.percolatorGray.cgColor
        animeImageView.layer.borderWidth = 0.5
    }
    
    fileprivate func setupLabelStyle() {
//        airDateLabel.asyncSetFont(with: "HiraginoSansGB-W3", placeholderFontName: "HiraginoSans-W3", size: 13.0)
//        typeLabel.asyncSetFont(with: "HiraginoSansGB-W3", placeholderFontName: "HiraginoSans-W3", size: 13.0)
//        
//        if nameLabel.text == nameCNLabel.text {
//            nameLabel.asyncSetFont(with: "STSongti-SC-Bold", placeholderFontName: "HiraMinProN-W6", size: 17.0, toLanguage: ["zh-Hans", "zh-Hant"])
//        } else {
//            nameLabel.font = UIFont(name: "HiraMinProN-W6", size: 17.0)
//        }
//        
//        nameCNLabel.asyncSetFont(with: "HiraginoSansGB-W3", placeholderFontName: "HiraginoSans-W3", size: 15.0)
//        
//        doingLabel.asyncSetFont(with: "HiraginoSansGB-W3", placeholderFontName: "HiraginoSans-W3", size: 13.0)
    }
    
}
