//
//  AnimeCollectTableViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-7-25.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import TagWriteView
import Cosmos

protocol AnimeCollectionViewControllerDelegate {
    func pushAnimeCollectionVC(animeItem: Anime)
}

class AnimeCollectTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var animeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    @IBOutlet weak var airDate: UILabel!
    @IBOutlet weak var airWeekday: UILabel!
    @IBOutlet weak var epsStatus: UILabel!
    
    @IBOutlet weak var tagsWriteView: TagWriteView!
    @IBOutlet weak var tagsLabel: UILabel!
//    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var collectSegment: UISegmentedControl!
    
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var cosmosRatingView: CosmosView!
//    @IBOutlet weak var animeImageViewHeight: NSLayoutConstraint!
    
    var needComment = false
    var animeItem = Anime()
    var collectInfo: EpsCollectInfo?
//    var pushFromSearchTabelViewControllerFlag = false
    
    @IBAction func segmentSelected(sender: AnyObject) {
        saveButtonItem.enabled = true
    }
    
    // MARK: - Mark eps method
    @IBAction func saveButtonItemPressed(sender: UIBarButtonItem) {
        
        sender.enabled = false
        // FIXME:
        var method = UpdateSatusMethod.doing
        switch collectSegment.selectedSegmentIndex {
        case 2: method = .doing
        case 3: method = .hold
        case 4: method = .dropped
        case 0: method = .wish
        case 1: method = .collect
        default:
            sender.enabled = true
            self.noticeTop("请先对条目进行标注", autoClear: true, autoClearTime: 5)
            return
        }   // switch …
        
        let rating: Int? = (Int)(cosmosRatingView.rating)
//        let comment = commentTextField.text    // default @""
        let comment = commentTextView.text
        let tags = tagsWriteView.tags
        
        self.pleaseWait()
        BangumiAnimeModel.shared.markEpsWatched(BangumiRequest.shared, animeItem: animeItem, method, rating, comment, tags) { (status) -> Void in
            self.clearAllNotice()
            sender.enabled = true
            
            switch status {
            case .success:
                NSNotificationCenter.defaultCenter().postNotificationName("reloadModel", object: nil)
                self.noticeSuccess("保存成功", autoClear: true, autoClearTime: 3)
                
                // Pop view back
                let allViewControllers = self.navigationController!.viewControllers
                for vc in allViewControllers {
                    if vc.isKindOfClass(AnimeListTableViewController) {
                        self.navigationController?.popToViewController(vc as! UIViewController, animated: true)
                        return
                    }
                }

                self.navigationController?.popViewControllerAnimated(true)
                
            case .failed:
                debugPrintln("$ AnimeCollectTableVC: Mark eps failed")
            case .timeout:
                debugPrintln("$ AnimeCollectTableVC: Mark eps timeout")
            }
            
        }   // BangumiAnimeModel…
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationController?.title = "少女祈祷中…"
        let type = animeItem.subject.type
        let airDateList = ["日期", "发售日", "放送日期", "发售日期", "发行日期", "日期", "放送日期"]
        let airDateInfo = (animeItem.subject.airDate == "0000-00-00" || animeItem.subject.airDate == "") ? "未收录" : animeItem.subject.airDate
        
        
        nameLabel.text = animeItem.name
        nameCNLabel.text = animeItem.subject.nameCN
        airDate.text = "\(airDateList[type])：\(airDateInfo)"
        let weekArr: [String] = ["不确定", "每周一", "每周二", "每周三", "每周四", "每周五", "每周六", "每周日"]
        if type == 2 {
            airWeekday.text = "放送时间：\(weekArr[animeItem.subject.airWeekday])"
        } else {
            airWeekday.text = ""
        }
        let eps = (animeItem.subject.eps != 0) ? "\(animeItem.subject.eps)" : "??"
        epsStatus.text = "完成度：\(BangumiAnimeModel.shared.subjectAllStatusList[animeItem.subject.id]?.count ?? 0)" + "/" + eps
        saveButtonItem.title = "保存"
        tagsLabel.text = "标签（按空格创建，至多十个）："
        commentLabel.text = "我的吐槽（至多 200 字）："
        
//        let typeArr = ["Zero", "书籍", "动画", "音乐", "游戏", "Five", "三次元"]
        switch type {
        case 0: break
        case 1:         // Book
            collectSegment.setTitle("想读", forSegmentAtIndex: 0)
            collectSegment.setTitle("读过", forSegmentAtIndex: 1)
            collectSegment.setTitle("在读", forSegmentAtIndex: 2)
        case 2:         // Anime
            break
        case 3:         // Music
            collectSegment.setTitle("想听", forSegmentAtIndex: 0)
            collectSegment.setTitle("听过", forSegmentAtIndex: 1)
            collectSegment.setTitle("在听", forSegmentAtIndex: 2)
        case 4:         // Game
            collectSegment.setTitle("想玩", forSegmentAtIndex: 0)
            collectSegment.setTitle("玩过", forSegmentAtIndex: 1)
            collectSegment.setTitle("在玩", forSegmentAtIndex: 2)
        case 5:
            break
        case 6:         // Oh…
            break
        default:
            break
        }
        
        collectSegment.enabled = false
        saveButtonItem.enabled = false
        tagsWriteView.maxTagLength = 0
        
        ratingLabel.text = "我的评价："
        cosmosRatingView.userInteractionEnabled = false
        cosmosRatingView.settings.fillMode = .Full
        cosmosRatingView.settings.updateOnTouch = true
        cosmosRatingView.settings.minTouchRating = 0.0
        cosmosRatingView.didTouchCosmos = touchedTheStar

        animeImageView.hnk_setImageFromURL(NSURL(string: animeItem.subject.images.largeUrl)!, placeholder: UIImage(named: "404"))
//        animeImageView.hnk_setImageFromURL(NSURL(string: animeItem.subject.images.largeUrl)!, placeholder: UIImage(named: "404"), format: nil, failure: { (error) -> () in
//            if error != nil {
//                    self.noticeInfo("图片加载失败", autoClear: true, autoClearTime: 4)
//            }
//        }, success: { (image) -> () in
//            self.animeImageView.image = image
//            
//        })
    
        // fetch collect info
        getEpsCollectInfo()
        
        
        // configure cells appearance
        tagsWriteView.layer.backgroundColor = UIColor.clearColor().CGColor
        tagsWriteView.backgroundColorForDeleteButton = UIColor.clearColor()
        tagsWriteView.setDeleteButtonBackgroundImage(UIImage(named: "btn_tag_delete"), state: .Normal)
        tagsWriteView.verticalInsetForTag = UIEdgeInsetsMake(6.0, 8.0, 4.0, 0.0)
        tagsWriteView.sizeForDeleteButton = CGRectMake(0.0, 0.0, 17.0, 17.0)
        tagsWriteView.tagBackgroundColor = UIColor.grayColor()
        tagsWriteView.allowToUseSingleSpace = false

        
        commentTextView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin
        commentTextView.layer.borderColor = UIColor.myGrayColor().CGColor
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.cornerRadius = 5
        commentTextView.clipsToBounds = true
        
//        animeImageView.layer.cornerRadius   = 5
        animeImageView.layer.shadowOffset   = CGSizeMake(0, 0)
        animeImageView.layer.shadowRadius   = 4
        animeImageView.layer.shadowOpacity  = 0.3
        
        // Self Sizing Cells
        self.tableView.estimatedRowHeight = 170;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
        self.navigationController?.navigationBar.lt_reset()
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Eps info fetch method
    private func getEpsCollectInfo() {
        
        self.title = "少女祈祷中…"
        BangumiRequest.shared.getEpCollectInfo(animeItem) { (status, info) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                self.title = ""
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.cosmosRatingView.userInteractionEnabled = true
                self.tagsWriteView.userInteractionEnabled = true
                
                switch status {
                case .success:
                    self.collectInfo = info
                    self.saveButtonItem.enabled = true
                    self.collectSegment.enabled = true
                    debugPrint("@ AnimeListTableVC: Get eps info success")
                    
                    switch self.collectInfo!.status.type {
                    case .doing:
                        self.collectSegment.selectedSegmentIndex = 2
                    case .hold:
                        self.collectSegment.selectedSegmentIndex = 3
                    case .dropped:
                        self.collectSegment.selectedSegmentIndex = 4
                    case .wish:
                        self.collectSegment.selectedSegmentIndex = 0
                    case .collect:
                        self.collectSegment.selectedSegmentIndex = 1
                    default:
                        debugPrint("$ AnimeCollectTableVC: collect status is unknown type -> \(self.collectInfo!.status.type.rawValue)")
                    }   // switch …
                    
                    let infoRating = self.collectInfo?.rating ?? 0
                    debugPrintln(infoRating)
                    if infoRating != 0 {
                        self.ratingLabel.text = "我的评价：\(infoRating) 星"
                    }
                    self.cosmosRatingView.rating = (Double)(infoRating) * 1.0
                    
                    if let tags = self.collectInfo?.tags,
                    let tag = tags.first,
                    let comment = self.collectInfo?.comment {
                        self.tagsWriteView.maxTagLength = 100
                        if tag != "" { self.tagsWriteView.addTags(tags) }
                        if comment != "" { self.commentTextView.text = comment }
                    }
                    
                    if self.needComment {
                        self.commentTextView.becomeFirstResponder()
                    }
                    
                    
                case .failed:
                    self.saveButtonItem.enabled = true
                    self.collectSegment.enabled = true
                    self.tagsWriteView.maxTagLength = 20
                    debugPrint("@ AnimeListTableVC: Get eps info failed")
                    
                case .timeout:
                    self.navigationItem.title = "请返回重试"
                    self.collectSegment.enabled = false
                    self.tagsWriteView.userInteractionEnabled = false
                    self.cosmosRatingView.userInteractionEnabled = false
                    
                    self.noticeInfo("请求超时", autoClear: true, autoClearTime: 5)
                    debugPrint("@ AnimeListTableVC: Get eps info timeout")
                }   // switch status …
            }   // dispatch_async(…)
        }   // BangumiRequest.shared.getEpcollectInfo(…)
    }   // getEpsCollectInfo(…)

    // MARK: - TableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 4
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    

    // MARK: - Text Field Delegate
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        
//        textField.resignFirstResponder()
//        return true
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        if range.location >= 200 {
//            return false
//        }
//        
//        return true
//    }
        
    // MARK: Text View delegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if range.length >= 200 {
            return false
        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    private class func formatValue(value: Double) -> String {
        return String(format: "%.2f", value)
    }
    
    private func touchedTheStar(rating: Double) {
        debugPrintln(rating)
        ratingLabel.text = (rating != 0) ? "我的评价：\((Int)(rating/1.0)) 星" : "不评价"
    }
}
