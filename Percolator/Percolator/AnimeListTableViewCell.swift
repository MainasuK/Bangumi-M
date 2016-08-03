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
        
//        debugPrint("$ AnimeTableList_Cell: Mark Button Pressed -> \(animeItem.name)")
//
//        if postMark {
//            return
//        }
//
//        switch mark {
//        case Marker.ep:
//            debugPrint("$ AnimeTableList_Cell: Mark ep")
//            isPosting = true
//            animeModel.markEpWatched(request, animeItem: animeItem, markEp: nextMarkEp!, { (status) -> Void in
//
//                switch status {
//                case .success: SwiftNotice.noticeOnSatusBar("ep.\(self.nextMarkEp!.sort) \(self.nextMarkEp!.name) 标记成功", autoClear: true, autoClearTime: 4)
//                case .timeout: SwiftNotice.showNoticeWithText(NoticeType.info, text: "请求超时", autoClear: true, autoClearTime: 5)
//                case .failed: SwiftNotice.showNoticeWithText(NoticeType.error, text: "请求失败", autoClear: true, autoClearTime: 5) //FIXME: Request Model need rebuild
//                }
//
//                self.reloadData(status)
//            })
//
//        case Marker.eps:
//            debugPrint("$ AnimeTableList_Cell: Mark eps")
//            delegate?.pushAnimeCollectionVC(self.animeItem)
//
//        default:
//            debugPrint("$ AnimeTableList_Cell: Unmarkable")
//        }   // switch mark …

    }
    
    @IBOutlet weak var watchedSpinner: UIActivityIndicatorView!
}

extension AnimeListTableViewCell: ConfigurableCell {
    
    typealias ItemType = AnimeListTableViewModel.ItemType
    typealias History = Result<AnimeListTableViewModel.SubjectHistory>
    typealias ProgressesStatus = AnimeListTableViewModel.ProgressesStatus
    
    func configure(with item: ItemType) {
        let (subject, history) = item
        mark = .none
        
        setupCellStyle()
        configureLabel(with: subject)
        configureIamge(with: subject.images)
        configureButton(with: history, subject)
        
//        setupLabelStyle()
        
        layoutIfNeeded()
    }
}

extension AnimeListTableViewCell {
    
    private func configureLabel(with subject: Subject) {
        nameLabel.text = (subject.name != "") ? subject.name : subject.nameCN
        
        // Set text in configureButton…
        watchedToLabel.text = "看到："
        watchedLabel.text = "努力分析中…"
    }
    
    private func configureIamge(with images: Images) {
        // Async load image
        let networkStatus = BangumiRequest.shared.networkStatus
        let imageURLValue = (networkStatus == ReachableViaWiFi) ? images.largeUrl : images.mediumUrl
        let size = animeImageView.bounds.size
        
        animeImageView.af_cancelImageRequest()
        if let urlVal = imageURLValue, let url = URL(string: urlVal) {
            animeImageView.af_setImageWithURL(url, placeholderImage: UIImage.fromColor(.placeholder, size: size), imageTransition: .crossDissolve(0.2))
        } else {
            animeImageView.image = UIImage.fromColor(.placeholder, size: size)
        }
    }
    
    // TL; DR
    private func configureButton(with result: History, _ subject: Subject) {
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
                watchedLabel.text = (subject.epTable.count != 0) ? "来开始标记吧～" : "喵帕斯～"
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
    
    private func setupCellStyle() {
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
    
//    private func setupLabelStyle() {
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
