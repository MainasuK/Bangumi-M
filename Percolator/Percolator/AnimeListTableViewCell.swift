//
//  AnimeListTableViewCell.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Haneke


class AnimeListTableViewCell: UITableViewCell {
    
    var delegate: AnimeCollectionViewControllerDelegate?
    
    enum Marker {
        case ep
        case eps
        case posting
        case null
    }
    
    var mark = Marker.null
    var postMark = false
    var isPosting = false {
        willSet {
            NSNotificationCenter.defaultCenter().postNotificationName("setPostMark", object: newValue)
            NSNotificationCenter.defaultCenter().postNotificationName("setRefreshMark", object: !newValue)
            if newValue {
                watchedButton.hidden = true
                watchedSpinner.startAnimating()
            } else {
                watchedButton.hidden = false
                watchedSpinner.stopAnimating()
            }
        }
    }
    
    let animeModel = BangumiAnimeModel.shared
    let request = BangumiRequest.shared
    
    var animeItem = Anime()
    
    var lastTouchEp: EpStatus?
    var lastTouchEpSort = 0
    var nextMarkEp: EpStatus?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var animeImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var doingLabel: UILabel!
    @IBOutlet weak var watchedLabel: UILabel!
    
    @IBOutlet weak var watchedToLabel: UILabel!

    @IBOutlet weak var watchedButton: UIButton!
    
    // MARK: Button pressed method
    @IBAction func watchedButtonPressed(sender: UIButton) {
        debugPrint("$ AnimeTableList_Cell: Mark Button Pressed -> \(animeItem.name)")
        
        if postMark {
            return
        }
        
        switch mark {
        case Marker.ep:
            debugPrint("$ AnimeTableList_Cell: Mark ep")
            isPosting = true
            animeModel.markEpWatched(request, animeItem: animeItem, markEp: nextMarkEp!, { (status) -> Void in
                
                switch status {
                case .success: SwiftNotice.noticeOnSatusBar("ep.\(self.nextMarkEp!.sort) \(self.nextMarkEp!.name) 标记成功", autoClear: true, autoClearTime: 4)
                case .timeout: SwiftNotice.showNoticeWithText(NoticeType.info, text: "请求超时", autoClear: true, autoClearTime: 5)
                case .failed: SwiftNotice.showNoticeWithText(NoticeType.error, text: "请求失败", autoClear: true, autoClearTime: 5) //FIXME: Request Model need rebuild
                }

                self.reloadData(status)
            })
            
        case Marker.eps:
            debugPrint("$ AnimeTableList_Cell: Mark eps")
            delegate?.pushAnimeCollectionVC(self.animeItem)

        default:
            debugPrint("$ AnimeTableList_Cell: Unmarkable")
        }   // switch mark …
    }
    
    @IBOutlet weak var watchedSpinner: UIActivityIndicatorView!
    

    
    
    // MARK: init button text method
    private func initWatchButtonTitle() {

        if let nextEp = nextMarkEp  {   // get user next need mark ep
            switch nextEp.status {
            case AirState.air:
                watchedButton.setTitle("ep.\(nextEp.sort) \(nextEp.name) 看过", forState: .Normal)
                indicatorView.backgroundColor = UIColor.myPinkColor()
                mark = Marker.ep
                
            case AirState.notAir:
                let weekArr: [String] = ["有空", "周一", "周二", "周三", "周四", "周五", "周六", "周日"]
                
                watchedButton.setTitle("ep.\(nextEp.sort) 未放送 \(weekArr[animeItem.subject.airWeekday])再来吧", forState: .Normal)
                indicatorView.backgroundColor = UIColor.myRedColor()
                mark = Marker.null
                
            case AirState.today:
                let name = (nextEp.name != "") ? nextEp.name : "暂未收录（放送中）"
                watchedButton.setTitle("ep.\(nextEp.sort) \(name) 在看", forState: .Normal)
                indicatorView.backgroundColor = UIColor.myGreenColor()
                mark = Marker.ep
            }
            
        } else {
            if animeItem.subject.eps == 0 {
                let weekArr: [String] = ["过几天", "周一", "周二", "周三", "周四", "周五", "周六", "周日"]
                
                watchedButton.setTitle("未收录下一集，\(weekArr[animeItem.subject.airWeekday])再来看看吧", forState: .Normal)
                mark = Marker.null
                indicatorView.backgroundColor = UIColor.myRedColor()
                
            } else if (animeItem.subject.eps == animeModel.animeGridStatusList[animeItem.subject.id]!.normalTable.count) {
                watchedButton.setTitle("看完了 我要吐槽", forState: UIControlState.Normal)
                mark = Marker.eps
                indicatorView.backgroundColor = UIColor.myPurpleColor()
                
            } else {
                watchedButton.setTitle("喵帕斯～出错了？为什么什么也找不到？", forState: UIControlState.Normal)
                mark = Marker.null
                indicatorView.backgroundColor = UIColor.myRedColor()
                
            }
        }
    }
    

    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization codec
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    internal func initCell() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AnimeListTableViewCell.setPostingMark(_:)), name: "setPostMark", object: nil)
        
        let gridStatus = animeModel.animeGridStatusList[animeItem.subject.id]
        let animeStatus = animeModel.subjectAllStatusList[animeItem.subject.id] ?? SubjectItemStatus()
    
        lastTouchEp = gridStatus!.lastTouchEP(animeStatus)
        lastTouchEpSort = lastTouchEp?.sort ?? 0
        nextMarkEp = animeModel.animeGridStatusList[animeItem.subject.id]?.nextMarkEP(lastTouchEpSort)

        nameLabel.text = animeItem.name    // anime name of cell
        doingLabel.text = "\(animeItem.subject.collection.doing) 人在看"    // num of watching
        
        animeImageView.layer.borderColor = UIColor.myGrayColor().CGColor
        animeImageView.layer.borderWidth = 1.0
        animeImageView.hnk_setImageFromURL(NSURL(string: animeItem.subject.images.largeUrl)!, placeholder: UIImage(named: "404"))
        
        if lastTouchEp != nil {
            watchedToLabel.text = "看到"
            if lastTouchEp!.name == "" {     // No ep name, most condition is Movie or OVA
                watchedLabel.text = "ep.\(lastTouchEpSort) \(animeItem.subject.nameCN)"
            } else {
                watchedLabel.text = "ep.\(lastTouchEpSort) \(lastTouchEp!.name)"
            }
        } else {
            watchedLabel.text = ""
            watchedToLabel.text = ""
        }
        
        initWatchButtonTitle()
        
        isPosting = animeModel.animePostingStatusList[animeItem.subject.id]!.boolValue
    }
    
    private func reloadData(status: ModelModifyStatus) {
        self.isPosting = false
        
        switch status {
        case .success:  fallthrough
        case .failed:   fallthrough
        case .timeout:  fallthrough
        default:
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.animeModel.animePostingStatusList[self.animeItem.subject.id] = false
                self.initCell()
            }
        }   // switch status …
    }
    
    // MARK: Broadcast receive
    func setPostingMark(notification: NSNotification) {
        postMark = notification.object as! Bool
    }
    
}
