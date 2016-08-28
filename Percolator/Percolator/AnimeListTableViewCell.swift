//
//  AnimeListTableViewCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit


class AnimeListTableViewCell: UITableViewCell {
    
    weak var delegate: AnimeListTableViewCellDelegate?
    
    var mark: AnimeMark = .none
    var isLast: Bool = false
    var isSpinnning = false {
        didSet {
            if isSpinnning {
                watchedButton.isHidden = true
                watchedButton.isEnabled = false
                watchedSpinner.startAnimating()
            } else {
                watchedSpinner.stopAnimating()
                watchedButton.isHidden = false
                watchedButton.isEnabled = true
            }
        }
    }
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var animeImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var watchedLabel: UILabel!
    @IBOutlet weak var watchedToLabel: UILabel!

    @IBOutlet weak var watchedButton: UIButton!
    
    // MARK: Button pressed method
    @IBAction func watchedButtonPressed(_ sender: UIButton) {
        delegate?.watchedButtonPressed(sender, with: mark)
        switch mark {
        case .episode(_):   isSpinnning = true
        default:            break
        }
    }
    
    @IBOutlet weak var watchedSpinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        animeImageView.af_cancelImageRequest()
        animeImageView.layer.removeAllAnimations()
        animeImageView.image = nil
    }
}

extension AnimeListTableViewCell: ConfigurableCell {
    
    typealias ItemType = AnimeListTableViewModel.ItemType
    typealias History = Result<AnimeListTableViewModel.SubjectHistory>
    typealias ProgressesStatus = AnimeListTableViewModel.ProgressesStatus
    
    func configure(with item: ItemType) {
        let (subject, history) = item
        mark = .none
        
        configureLabel(with: subject)
        configureIamge(with: subject.images)
        configureButton(with: history, subject)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
//        setupLabelStyle()
    }
}

extension AnimeListTableViewCell {
    
    fileprivate func configureLabel(with subject: Subject) {
        nameLabel.text = (subject.name != "") ? subject.name : subject.nameCN
        
        // Set text in configureButton…
        watchedToLabel.text = "看到："
        watchedLabel.text = "努力分析中…"
    }
    
    fileprivate func configureIamge(with images: Images) {
        // Async load image
        let networkStatus = BangumiRequest.shared.networkStatus
        let imageURLValue = (networkStatus == ReachableViaWiFi) ? images.largeUrl : images.mediumUrl
        let size = animeImageView.bounds.size
        
        if let urlVal = imageURLValue, let url = URL(string: urlVal) {
            animeImageView.af_setImage(withURL: url, placeholderImage: UIImage.fromColor(.placeholder, size: size), progressQueue: DispatchQueue.global(qos: .userInitiated), imageTransition: .crossDissolve(0.2))
        } else {
            animeImageView.image = UIImage.fromColor(.placeholder, size: size)
        }
    }
    
    // TL; DR
    fileprivate func configureButton(with result: History, _ subject: Subject) {
        guard subject.responseGroup == .large else {
            isSpinnning = true
            return
        }
        
        do {
            let history = try result.resolve()
            
            watchedSpinner.stopAnimating()
            watchedButton.isEnabled = true
            watchedButton.isHidden = false
            
            if let lastEpisode = history.lastEpisode {
                let epName = [lastEpisode.name, lastEpisode.nameCN].filter { $0 != "" }.first ?? ""
                watchedToLabel.text = "看到："
                watchedLabel.text = "EP.\(lastEpisode.sortString) \(epName)"
            } else {
                watchedToLabel.text = (subject.epTable.count != 0) ? "\(subject.collection.doing)人在看" : ""
                watchedLabel.text = (subject.epTable.count != 0) ? "来标记吧～" : "喵帕斯～"
            }
            
            if let nextEpisode = history.nextEpisode {
                let epName = [nextEpisode.name, nextEpisode.nameCN].filter { $0 != "" }.first ?? ""
                switch nextEpisode.status {
                case .air:
                    watchedButton.setTitle("EP.\(nextEpisode.sortString) \(epName)", for: .normal)
                    mark = AnimeMark.episode(nextEpisode, subject)
                    indicatorView.backgroundColor = UIColor.percolatorPink
                    
                case .notAir:
                    let weekArr: [String] = ["有空", "周一", "周二", "周三", "周四", "周五", "周六", "周日"]
                    watchedButton.setTitle("EP.\(nextEpisode.sortString) 未放送 \(weekArr[subject.airWeekday])再来吧", for: .normal)
                    indicatorView.backgroundColor = UIColor.myRedColor
                
                case .today:
                    watchedButton.setTitle("EP.\(nextEpisode.sortString) \(epName)", for: .normal)
                    mark = AnimeMark.episode(nextEpisode, subject)
                    indicatorView.backgroundColor = UIColor.myGreenColor
                }
                
                if subject.epTable.first?.id == nextEpisode.id {
                    
                }
            } else {
                if subject.epTable.count == 0 {
                    watchedButton.isEnabled = false
                    watchedButton.setTitle("未收录章节信息", for: .normal)
                    indicatorView.backgroundColor = UIColor.myRedColor
                } else if subject.epTable.last?.id == history.lastEpisode?.id  {
                    watchedButton.setTitle("看完了 我要吐槽", for: .normal)
                    mark = AnimeMark.subject(subject)
                    indicatorView.backgroundColor = UIColor.myPurpleColor
                } else {
                    watchedButton.isEnabled = false
                    watchedButton.setTitle("喵帕斯～出错了？为什么什么也找不到", for: .normal)
                    indicatorView.backgroundColor = UIColor.myRedColor
                }
            }
            
        } catch ProgressesStatus.none {
            isSpinnning = false
            watchedButton.isEnabled = false
            watchedButton.setTitle("喵帕斯～出错了？找不到章节信息", for: .normal)
            indicatorView.backgroundColor = UIColor.myRedColor
            
        } catch ProgressesStatus.fetching {
            isSpinnning = true
            consolePrint("Waitting for reload \(nameLabel.text ?? "")")
        } catch ProgressesStatus.timeout {
            isSpinnning = false
            watchedButton.isEnabled = false
            watchedButton.setTitle("获取章节信息出错，请刷新重试", for: .normal)
            indicatorView.backgroundColor = UIColor.myRedColor
            
        } catch ProgressesStatus.unknownError {
            isSpinnning = false
            watchedButton.isEnabled = false
            watchedButton.setTitle("喵帕斯～出错了？未知错误", for: .normal)
            indicatorView.backgroundColor = UIColor.myRedColor
        } catch {
            isSpinnning = false
            watchedButton.isEnabled = false
            watchedButton.setTitle("喵帕斯～出错了？未知错误", for: .normal)
            indicatorView.backgroundColor = UIColor.myRedColor
        }
    
    }
    
    fileprivate func setupCellStyle() {
        
        nameLabel.layer.masksToBounds = true
        watchedLabel.layer.masksToBounds = true
        watchedToLabel.layer.masksToBounds = true
        
        // Configure the appearance of the cell
        backgroundColor = UIColor.myAnimeListBackground
        
        // Make cell get readable margin guideline
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        animeImageView.layer.cornerRadius = 5
        animeImageView.layer.borderColor = UIColor.percolatorLightGray.withAlphaComponent(0.8).cgColor
        animeImageView.layer.borderWidth = 0.5  // 1px
        
        watchedButton.setTitleColor(UIColor.percolatorPink, for: UIControlState.highlighted)
        indicatorView.backgroundColor = UIColor.percolatorGray
    }
    
//    fileprivate func setupLabelStyle() {
//        if nameLabel.text == nameCNLabel.text {
//            nameLabel.asyncSetFont(with: "STSongti-SC-Bold", placeholderFontName: "HiraMinProN-W6", size: 17.0, toLanguage: ["zh-Hans", "zh-Hant"])
//        } else {
//            nameLabel.font = UIFont(name: "HiraMinProN-W6", size: 17.0)
//        }
//        nameCNLabel.asyncSetFont(with: "STSongti-SC-Bold", placeholderFontName: "HiraMinProN-W6", size: 17.0)
//        nameCNLabel.isHidden = (nameLabel.text != "") ? true : false
//
//        watchedToLabel.asyncSetFont(with: "HiraginoSansGB-W3", placeholderFontName: "HiraginoSans-W3", size: 13.0)
//    }
    
}
