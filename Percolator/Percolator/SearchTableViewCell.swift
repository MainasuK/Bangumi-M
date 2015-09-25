//
//  SearchTableViewCell.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-13.
//
//

import UIKit
import Haneke

class SearchTableViewCell: UITableViewCell {
    
    var isFirstInit = true
    var isSending: Bool {
        get {
            return self.isSending
        }
        set {
            if newValue {
                favoriteButton.hidden = true
                spinner.startAnimating()
            } else {
                favoriteButton.hidden = false
                spinner.stopAnimating()
            }
        }
    }
    
    var sendingStatus: Bool {
        get {
            isSending = isSending.boolValue
            return isSending
        }
    }
    var animeItem: AnimeSubject!
    var delegate: BangumiTabelViewCellDelegate?
    
    let request = BangumiRequest.shared
    let favoriteModel = BangumiFavoriteModel.shared

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var animeImageView: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var starImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    @IBOutlet weak var watchingLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func collectionButtonPressed(sender: UIButton) {
        delegate?.cellCollectionButtonpressed(animeItem.id)
    }
    
    @IBAction func favoriteButtonPressed(sender: UIButton) {
    
        if favoriteButton.titleLabel?.text == "保存" {

            debugPrint("@SearchTableViewCell: Save subject to cloud start…")
            isSending = true
            favoriteModel.saveSubjectToCloud(self.animeItem) { (success) -> Void in
                
                debugPrint("@SearchTableViewCell: Save subject to cloud is \(success)")
                let typeArr = ["Zero", "书籍", "动画", "音乐", "游戏", "Five", "三次元"]       // FIXME: It appaare more than once in file
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.isSending = false
                    if success {
                        SwiftNotice.noticeOnSatusBar("保存成功", autoClear: true, autoClearTime: 4)
                        self.favoriteButton.setTitle("已保存", forState: .Normal)
                        
                    } else {
                        SwiftNotice.showNoticeWithText(NoticeType.error, text: "保存失败", autoClear: true, autoClearTime: 5)
                        self.favoriteButton.setTitle("保存", forState: .Normal)
                    }
                }
            }
        }   // if favoriteButton.titleLabel?.text == "Like" …
    }

    // MARK: - Cell life cycle
    
    internal func initCell() {
                
        debugPrint("$ SearchTableViewCell init -> \(animeItem.name)")
        nameLabel.text = animeItem.name
        nameCNLabel.text = animeItem.nameCN
        let doingType = ["在看", "在读", "在看", "在听", "在玩", "在看", "在看"]
        watchingLabel.text = "\(animeItem.collection.doing) 人\(doingType[animeItem.type])"
        let typeArr = ["Zero", "书籍", "动画", "音乐", "游戏", "Five", "三次元"]
        typeLabel.text = typeArr[animeItem.type]
        
        animeImageView.layer.borderColor = UIColor.myGrayColor().CGColor
        animeImageView.layer.borderWidth = 1.0
        animeImageView.hnk_setImageFromURL(NSURL(string: animeItem.images.largeUrl)!, placeholder: UIImage(named: "404"))
        
        isSending = false
        if favoriteModel.isCloudAvailiable {
            if isFirstInit {
                initButton()
            }
        } else {
            self.favoriteButton.setTitle("不可用", forState: .Normal)
        }
    }
    
    private func initButton() {
        isFirstInit = false
        self.favoriteButton.setTitle("加载中…", forState: .Normal)

        debugPrint("@ SearchTabelViewCell: Init button method start")
        favoriteModel.isRecordExistInCloud(animeItem.id) { (isExist) -> Void in
            
            debugPrint("@ SearchTabelViewCell: Init button method end")
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.favoriteButton.setTitle( (isExist == true) ? "保存" : "已保存", forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
