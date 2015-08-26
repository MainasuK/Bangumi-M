//
//  ViewController.swift
//  demo
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import Haneke

let reuseTableViewCellIdentifier = "TableViewCell"
let reuseCollectionViewCellIdentifier = "CollectionViewCell"

class DetailViewController: UITableViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MGSwipeTableCellDelegate {
    
    private let kTableHeaderHeight: CGFloat = 300.0 - 36.0
    private let kTableHeaderCutAway: CGFloat = 50.0
    private let changePoint: CGFloat = -20
    private let changeShadowPoint: CGFloat = -350.0
    private let shadowMinAlpha: CGFloat = 1
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var AnimeSubjectImageView: UIImageView!
    
    var isFirstLoaded = true
    var isSending = false {
        willSet {
            if newValue {
                
            } else {
                
            }
        }
    }
    
    
//    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    var firstCellRightHeight: CGFloat?
    var headerView: UIView!
//    var sectionHeaderView: UIView!
    var headerMaskLayer: CAShapeLayer!
    
    var detailSource: BangumiDetailSource!
    var contentOffsetDictionary = NSMutableDictionary()
    
    var animeItem: Anime!
    var animeSubject: AnimeSubject!
    
    
    // TODO: (Discard)
//    @IBAction func segmentValueChanged(sender: AnyObject) {
//        if let segment = sender as? UISegmentedControl {
//            debugPrintln("\(segment.selectedSegmentIndex)")
//        }
//    }
    
    @IBAction func collectionButtonPressed(sender: UIBarButtonItem) {
        let collectVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeCollectVC) as! AnimeCollectTableViewController
        collectVC.animeItem = animeItem
        
        self.navigationController?.navigationBar.lt_reset()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.pushViewController(collectVC, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix the separator display when 0 rows in table
        tableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.estimatedRowHeight = 72.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
//        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.myNavigatinBarLooksLikeColor().colorWithAlphaComponent(0.5))
        headerView = self.tableView.tableHeaderView
        self.tableView.tableHeaderView = nil
        self.tableView.addSubview(headerView)
        self.tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        self.tableView.contentOffset = CGPoint(x: 0.0, y: -kTableHeaderHeight)
        
        //        headerMaskLayer = CAShapeLayer()
        //        headerMaskLayer.fillColor = UIColor.blackColor().CGColor
        
//        headerView.layer.mask = headerMaskLayer
        updateHeaderView()
        
        // FIXME: It's looks like App Store segment control which float under navigation bar,
        // but… tableview's offinset get it not work!
//        sectionHeaderView = self.tableView.tableFooterView
//        self.tableView.tableFooterView = nil
        // Then, sectionHeaderView in tableview delegate
        // (Discard)
        
        // Configure the tabel view
        AnimeSubjectImageView.hnk_setImageFromURL(NSURL(string: animeSubject.images.largeUrl)!, placeholder: UIImage(named: "404_landscape"))
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            return 175.0
        }
        
        if indexPath.section >= 3 {
            return 45.0
        }
        
        if indexPath.section == 0 && firstCellRightHeight != nil {
            return firstCellRightHeight!
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
//        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "naviBarbackground"), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.myNavigatinBarLooksLikeColor().colorWithAlphaComponent(0))
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        if isFirstLoaded {
            let indexSet = NSIndexSet(index: 0)
            tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
            if let frame = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.frame {
                firstCellRightHeight = frame.height
            }
            
            if !detailSource.sourceList.isEmpty {
                let indexSetTwo = NSIndexSet(index: 1)
                tableView.reloadSections(indexSetTwo, withRowAnimation: UITableViewRowAnimation.None)
            }
            
            isFirstLoaded = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.lt_reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateHeaderView()
        })
        
        if scrollView.isKindOfClass(UICollectionView) {
            // FIXME:
            let horizontalOffset: CGFloat = scrollView.contentOffset.x
            let collectionView: UICollectionView = scrollView as! UICollectionView
            self.contentOffsetDictionary.setValue(horizontalOffset, forKey: collectionView.tag.description)
            
        } else if scrollView.isKindOfClass(UITableView) {
            
            let color = UIColor.myNavigationBarColor()
            let offSetY = scrollView.contentOffset.y
            NSLog("offsetY --> \(offSetY)")
            
            var gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRectMake(0, 0, 320, 64)
        
            
            // FIXME: If someone want to change the UI, KEEP IN MIND IT, It's awesome, but made you mad
            if (offSetY > -350 && offSetY < 0) {    // some thing always is a trick
                let alpha: CGFloat = min(shadowMinAlpha, -offSetY / kTableHeaderHeight)
                NSLog("alpha --> \(alpha)")
                gradientLayer.colors = [UIColor(white: 0, alpha: alpha).CGColor, UIColor(white: 0, alpha: 0).CGColor]
                
                if let backgroundShadowImage = UIImage.imageFromLayer(gradientLayer) {
                    NSLog("---> Set shadow image under navigation bar success")
                    self.navigationController?.navigationBar.setBackgroundImage(backgroundShadowImage, forBarMetrics: .Default)
                } else {
                    NSLog("---> Set shadow image under navigation bar fail")
                }

            } else if (offSetY < changeShadowPoint) {
                let alpha: CGFloat = max(0, shadowMinAlpha - (changeShadowPoint - offSetY) / (-offSetY))
                NSLog("alpha --> \(alpha)")
                gradientLayer.colors = [UIColor(white: 0, alpha: alpha).CGColor, UIColor(white: 0, alpha: 0).CGColor]
                
                if let backgroundShadowImage = UIImage.imageFromLayer(gradientLayer) {
                    NSLog("---> Set shadow image under navigation bar success")
                    self.navigationController?.navigationBar.setBackgroundImage(backgroundShadowImage, forBarMetrics: .Default)
                } else {
                    NSLog("---> Set shadow image under navigation bar fail")
                }


            } else {    // offSetY > 0
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            }
            
            
            if (offSetY > changePoint) {
                let alpha: CGFloat = min(1, 1 - ( (changePoint + 64 - offSetY) / 64 ))
                self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(alpha))
            } else {
                self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(0))
            }
            
        }   // if scrollView.isKindOfClass() … else if …
    }
    
    
    func updateHeaderView() {
        
        var headerRect = CGRect(x: 0.0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        // Something MAGIC!!!
        // But we should take care of it
        
        //        let path = UIBezierPath()
        //        path.moveToPoint(CGPoint(x: 0.0, y: 0.0))
        //        path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
        //        path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height - kTableHeaderCutAway))
        //        path.addLineToPoint(CGPoint(x: headerRect.width/2, y: headerRect.height - kTableHeaderCutAway))
        //        path.addLineToPoint(CGPoint(x: headerRect.width/2 * 0.8, y: headerRect.height))
        //        path.addLineToPoint(CGPoint(x: 0, y: headerRect.height))
        //
        //        headerMaskLayer?.path = path.CGPath
        
        headerView.frame = headerRect
        
        //        println("headerView.frame -> \(headerView.frame), contentOffset.y -> \(tableView.contentOffset.y)")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 7
        // No.1 --> First cell
        // No.2 --> Topic cell
        // No.3 --> crt & staff
        // No.4/5/6 --> eps(ep/sp/ep/op)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 1                                            // first cell
        case 1: return detailSource.sourceList.count                // topic
        case 2: return detailSource.sourceArr.count                 // crt & staff
            
        case 3: return detailSource.gridStatusTable?.normalTable.count ?? 0
        case 4: return detailSource.gridStatusTable?.spTable.count ?? 0
        case 5: return detailSource.gridStatusTable?.opTable.count ?? 0
        case 6: return detailSource.gridStatusTable?.edTable.count ?? 0
            
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CMKTableViewCell
            if let animeDetail = detailSource.animeDetailLarge {
                cell.nameLabel.text = (animeDetail.name == "") ? animeDetail.name : animeDetail.nameCN
                cell.summaryLabel.text = (animeDetail.summary == "") ? "无简介" : animeDetail.summary     /// Use if let because it value not return with userCollection JSON but animeDetail JSON. Even more, it return when search API, it's same with userCollection list! Ohoooo.
                cell.airDateLabel.text = (animeDetail.airDate == "0000-00-00") ? "" : animeDetail.airDate
                
            } else {
                cell.nameLabel.text = (animeSubject.name == "") ? animeSubject.name : animeSubject.nameCN
                cell.summaryLabel.text = (animeSubject.summary == "") ? "无简介" : animeSubject.summary
                cell.airDateLabel.text = (animeSubject.airDate == "0000-00-00") ? "" : animeSubject.airDate
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as! CMKTopicTableViewCell
            
            let topic = detailSource.sourceList[indexPath.row]
            cell.nicknameLabel.text = topic.subtitle
            cell.titleLabel.text = topic.title
            cell.timeLabel.text = topic.time
            cell.replyLabel.text = "(+\(topic.reply))"
            cell.animeImageView.layer.borderColor = UIColor.blackColor().CGColor
            cell.animeImageView.layer.borderWidth = 0.1
//            cell.animeImageView.layer.cornerRadius = 5
            cell.animeImageView.layer.cornerRadius = cell.animeImageView.frame.width / 2
            cell.animeImageView.layer.masksToBounds = true
            cell.animeImageView.hnk_setImageFromURL(NSURL(string: topic.img)!, placeholder: UIImage(named: "404"))
            
            
            return cell
            
        } else if  indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseTableViewCellIdentifier) as! CMKCollectionTableViewCell
            cell.HeadlineLabel.text = detailSource.sourceNameList[indexPath.row]
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("epCell", forIndexPath: indexPath) as! CMKEPTableViewCell
            cell.indicatorView.backgroundColor = UIColor.myNavigatinBarLooksLikeColor()
//            cell.selectionStyle = .Blue
            
            if let ep = detailSource.gridStatusTable?.gridTable[indexPath.section - 3][indexPath.row] {
                cell.indicatorView.hidden = true
                
                cell.epTitleLabel.text = "\(ep.typeStr).\(ep.sortStr) \(ep.name)"
                cell.airDateLabel.text = "\(ep.airDate)"
                cell.replyLabel.text = "(+\(ep.comment))"
                cell.id = ep.id
                cell.delegate = self
                
                if let epStatus = detailSource.subjectStatusDict?.subjectStatus[ep.id] {
                    switch epStatus {
                    case .watched: cell.indicatorView.hidden = false
                    case .queue:
                        cell.indicatorView.hidden = false
                        cell.indicatorView.backgroundColor = UIColor.myQueueColor()
                    case .drop:
                        cell.indicatorView.hidden = false
                        cell.indicatorView.backgroundColor = UIColor.myDropColor()
                    default:
                        debugPrintln("^ Not marked ep")
                    }
                }
                
            } else {
                NSLog("Error! ^Not found ep cell in detasource")
                cell.epTitleLabel.text = ""
                cell.airDateLabel.text = ""
                cell.replyLabel.text = ""
                cell.indicatorView.hidden = true
                cell.id = 0
            }
            
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let collectionCell = cell as? CMKCollectionTableViewCell {
            collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, indexPath: indexPath)
            let index: NSInteger = collectionCell.collectionView.tag
            let value: AnyObject? = self.contentOffsetDictionary.valueForKey(index.description)
            let horizontalOffset: CGFloat = CGFloat(value != nil ? value!.floatValue : 0)
            collectionCell.collectionView.setContentOffset(CGPointMake(horizontalOffset, 0), animated: false)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        NSLog("\(indexPath)")
        if !detailSource.sourceList.isEmpty && indexPath.section == 1 {
            var url = ""
            let desktopUrl = detailSource.sourceList[indexPath.row].url
            let urlSplice = desktopUrl.componentsSeparatedByString("/")
            if let id = urlSplice.last {
                url = "http://bangumi.tv/m/topic/subject/\(id)"
                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            }
        }
        
        // FIXME:
        if let counts = detailSource.gridStatusTable?.counts() where indexPath.section >= 3 && indexPath.section <= 6 && counts != 0 {

            let cell = tableView.cellForRowAtIndexPath(indexPath) as! CMKEPTableViewCell
            let epID = cell.id
            var url = "http://bangumi.tv/m/topic/ep/\(epID)"
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    // MARK: - Collection View Data source and Delegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        if section == 0 {
        //            // catch it
        //        }
        
        let itemArr = self.detailSource.sourceArr[collectionView.tag] as [Item]
        NSLog("Section \(collectionView.tag): with \(itemArr.count) item(s)")
        return itemArr.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath) as! CMKCollectionViewCell
        let item = detailSource.sourceArr[collectionView.tag][indexPath.item]

        cell.titleLabel.text = item.title
        cell.subtitleLabel.text = item.subtitle
        cell.animeImageView.layer.borderColor = UIColor.myGrayColor().CGColor
        cell.animeImageView.layer.borderWidth = 1.0
        cell.animeImageView.layer.cornerRadius = 5
        cell.animeImageView.layer.masksToBounds = true
        cell.animeImageView.hnk_setImageFromURL(NSURL(string: item.img)!, placeholder: UIImage(named: "404"))
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var url = ""
        let desktopUrl = detailSource.sourceArr[collectionView.tag][indexPath.item].url
        let urlSplice = desktopUrl.componentsSeparatedByString("/")
        if let id = urlSplice.last {
            switch detailSource.sourceNameList[collectionView.tag] {
            case "出场人物": url = "http://bangumi.tv/m/topic/crt/" + id
            case "制作人员": url = "http://bangumi.tv/m/topic/prsn/" + id
            default:
                
                // url wrong
                NSLog("Error: Url parse error")
                return
            }
            
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
        
//        if UIDevice.currentDevice().systemVersion >= "8.0" {
//            let alert = UIAlertController(title: "第\(collectionView.tag)行", message: "第\(indexPath.item)个元素", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
//            let v: UIView = UIView(frame: CGRectMake(10, 20, 50, 50))
//            alert.view.addSubview(v)
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
    }
    
    
    // MARK: - Swipe Delegate
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        if let _cell = cell as? CMKEPTableViewCell {
            return (direction == MGSwipeDirection.LeftToRight) ? true : false
        }
        
        return false
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        swipeSettings.transition = MGSwipeTransition.Border
        expansionSettings.buttonIndex = 0
        
        var me = self
        
        if direction == .LeftToRight {
            expansionSettings.fillOnTrigger = false
            expansionSettings.threshold = 1.5
            
            let padding = 15
            
            let watchedButton = MGSwipeButton(title: "看过", backgroundColor: UIColor.myWatchedColor(), padding: padding, callback: { (cell) -> Bool in
//              
                if let _cell = cell as? CMKEPTableViewCell {
                    self.pleaseWait()
                    BangumiAnimeModel.shared.markEpWatched(BangumiRequest.shared, subjectID: _cell.subjectID, markEpID: _cell.id, method: UpdateSatusMethod.watched, { (success) -> Void in
                        if success {
                            // FIXME:
                            self.clearAllNotice()
                            self.detailSource.subjectStatusDict?.subjectStatus[_cell.id] = EpStatusType.watched
                            self.noticeTop("\(_cell.epTitleLabel.text!) 看过", autoClear: true, autoClearTime: 3)
                            _cell.indicatorView.hidden = false
                            _cell.indicatorView.backgroundColor = UIColor.myWatchedColor()
//                            let indexPath = self.tableView.indexPathForCell(cell)!
//                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                        } else {
                            self.noticeInfo("标记失败 请重试", autoClear: true, autoClearTime: 5)
//                            let indexPath = self.tableView.indexPathForCell(cell)!
//                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                        }
                    })
                }
                
                return true
            })
            
            let removeButton = MGSwipeButton(title: "撤销", backgroundColor: UIColor(red: 253.0/255.0, green: 204.0/255.0, blue: 49.0/255.0, alpha: 1.0), padding: padding, callback: { (cell) -> Bool in
                //
                if let _cell = cell as? CMKEPTableViewCell {
                    self.pleaseWait()
                    BangumiAnimeModel.shared.markEpWatched(BangumiRequest.shared, subjectID: _cell.subjectID, markEpID: _cell.id, method: UpdateSatusMethod.remove, { (success) -> Void in
                        if success {
                            // FIXME:
                            self.clearAllNotice()
                            self.detailSource.subjectStatusDict?.subjectStatus[_cell.id] = nil
                            self.noticeTop("撤销成功", autoClear: true, autoClearTime: 3)
                            _cell.indicatorView.hidden = true
                            _cell.indicatorView.backgroundColor = UIColor.myWatchedColor()
//                            let indexPath = self.tableView.indexPathForCell(cell)!
//                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                        } else {
                            self.noticeInfo("撤销失败", autoClear: true, autoClearTime: 5)
//                            let indexPath = self.tableView.indexPathForCell(cell)!
//                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                        }
                    })
                }
                
                return true
            })
            
            if let _cell = cell as? CMKEPTableViewCell,
            let status = self.detailSource.subjectStatusDict?.subjectStatus[_cell.id] {
                switch status {
                case .watched: return [removeButton]
                    
                default:
                    return [watchedButton]
                }
            }
            
            return [watchedButton]
            
        } else {
//            expansionSettings.fillOnTrigger = true
//            expansionSettings.threshold = 2.0
//            
//            let padding = 25
//            
//            let deleteButton = MGSwipeButton(title: "删除", backgroundColor: UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 50.0/255.0, alpha: 1.0), padding: padding, callback: { (cell) -> Bool in
//                
//                let indexPath = me.tableView.indexPathForCell(cell)!
//                let subjectToDelete = self.searchModel.subjectLocalList[indexPath.row]
//                Subject.deleteSubject(subjectToDelete, { (success) -> Void in
//                    NSLog("^ SearchBoxTableViewController: Delete is \(success)")
//                    if success {
//                        self.searchModel.subjectLocalList.removeAtIndex(indexPath.row)
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
//                        })
//                    }
//                })
//                
//                return false
//            })
            
            return nil
        }
        
        //        return nil
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        
        var str = ""
        var active = ""
        switch state {
        case .None: str = "None"
        case .SwipingLeftToRight: str = "SwipeingLeftToRight"
        case .SwipingRightToLeft: str = "SwipingRightToLeft"
        case .ExpandingLeftToRight: str = "ExpandingLeftToRight"
        case .ExpandingRightToLeft: str = "ExpandingRightToLeft"
        }
        
        active = (gestureIsActive) ? "Active" : "Ended"
        NSLog("Swipe state: \(str) ::: Gestrue: \(active)")
    }

    
    // Model build method
    func initFromSearchBox(request: BangumiRequest, _ subject: AnimeSubject) {
        var flag = 0
        var animeDetail = AnimeDetailLarge()
        var subjectStatus = SubjectItemStatus()
        
        // TODO: add spinner ? It's speed is enough, I think.
        
        // Task 1
        debugPrintln("@ DetailViewController: initnVC, step 1…")
        request.getSubjectDetailLarge(subject.id) { (animeDetailLarge) -> Void in

            if let _animeDetail = animeDetailLarge {
                debugPrintln("@ DetailViewController: step 1 success")
                animeDetail = _animeDetail
                ++flag
                
                if flag == 2 {
                    self.detailSource = BangumiDetailSource(subject: animeDetail)
                    self.detailSource.gridStatusTable = GridStatus(epsDict: animeDetail.eps.eps)
                    self.detailSource.animeDetailLarge = animeDetail
                    self.detailSource.subjectStatusDict = subjectStatus
                    self.tableView.reloadData()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            }
        }
        
        // Task 2
        debugPrintln("@ DetailViewController: initnVC, step 2…")
        request.getSubjectStatus(subject.id) { (subjectItemStatus) -> Void in
            debugPrintln("@ DetailViewController: step 2 success")
            subjectStatus = subjectItemStatus
            ++flag
            
            if flag == 2 {
                self.detailSource = BangumiDetailSource(subject: animeDetail)
                self.detailSource.gridStatusTable = GridStatus(epsDict: animeDetail.eps.eps)
                self.detailSource.animeDetailLarge = animeDetail
                self.detailSource.subjectStatusDict = subjectStatus
                self.tableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
        }
        
    }
}


