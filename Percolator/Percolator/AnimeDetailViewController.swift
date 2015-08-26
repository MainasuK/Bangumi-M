//
//  AnimeDetailViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-21.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit

class AnimeDetailViewController: UIViewController, SlidingContainerViewControllerDelegate {
    
    @IBAction func collectionButtonPressed(sender: UIBarButtonItem) {
        let collectVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeCollectVC) as! AnimeCollectTableViewController
        collectVC.animeItem = animeItem
        self.navigationController?.pushViewController(collectVC, animated: true)
    }
    
    var animeItem = Anime()
    let request = BangumiRequest.shared
    
    var subjectAllStatus: [Int: SubjectItemStatus]?
    var animeDetailLarge: AnimeDetailLarge?

    
    var isSubviewAdded = false
    
    @IBOutlet weak var fetchingSpinner: UIActivityIndicatorView!
    
    // MARK: view life cycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isSubviewAdded {
            // FIXME: need move init method in VC viewdidload
            if let _animeDetailLarge = animeDetailLarge {
                initDeatilViewWithData()
            } else {
                initDetailViewWithoutData()
            }

        }
    }
    
    private func initDetailViewWithoutData() {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userID) as! Int
        let authEncode = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.userAuthEncode) as! String
        
        request.getSubjectStatus(uid, authEncode: authEncode) { (statusDict) -> Void in
            
            self.subjectAllStatus = statusDict
            self.fetchAnimeDatailLargeData({ (animeDetailData) -> Void in
                
                if let detailData = animeDetailData {
                    
                    self.animeDetailLarge = detailData
                    self.initDeatilViewWithData()
                } else {
                    // FIXME: fail to fetch data, alert need
                }
            })
        }
    }
    
    private func initDeatilViewWithData() {
        let vc1 = self.animeDetailTableVC(self.animeItem, detailData: animeDetailLarge!)
        let vc2 = self.gridCollectionVC(self.animeItem.subject.id, detailData: animeDetailLarge!)
//        let vc3 = self.viewControllerWithColorAndTitle(UIColor.whiteColor(), title: "Third View Controller")
//        let vc4 = self.viewControllerWithColorAndTitle(UIColor.whiteColor(), title: "Forth View Controller")
        
//        let slidingContainerViewController = SlidingContainerViewController (
//            parent: self,
//            contentViewControllers: [vc1, vc2, vc3, vc4],
//            titles: ["简介", "章节", "工事中", "工事中"])
        
        let slidingContainerViewController = SlidingContainerViewController (
            parent: self,
            contentViewControllers: [vc1, vc2],
            titles: ["简介", "章节"])
        
        // Configure slide menu
        slidingContainerViewController.sliderView.appearance.backgroundColor = UIColor.myGrayColor()

        
        
        self.fetchingSpinner.stopAnimating()
        self.view.addSubview(slidingContainerViewController.view)
        
        
        slidingContainerViewController.sliderView.appearance.outerPadding = 0
        slidingContainerViewController.sliderView.appearance.innerPadding = 50
        slidingContainerViewController.setCurrentViewControllerAtIndex(0)
        
        self.isSubviewAdded = true

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: SlidingContainerViewControllerDelegate
    
    func slidingContainerViewControllerDidShowSliderView(slidingContainerViewController: SlidingContainerViewController) {
        
    }
    
    func slidingContainerViewControllerDidHideSliderView(slidingContainerViewController: SlidingContainerViewController) {
        
    }
    
    func slidingContainerViewControllerDidMoveToViewController(slidingContainerViewController: SlidingContainerViewController, viewController: UIViewController) {
        
    }
    
    func slidingContainerViewControllerDidMoveToViewControllerAtIndex(slidingContainerViewController: SlidingContainerViewController, index: Int) {
        
    }
    
    // MARK: VC builder
    
    func animeDetailTableVC(animeItem: Anime, detailData: AnimeDetailLarge) -> AnimeDetailTableViewController {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeDetailTableVC) as! AnimeDetailTableViewController
        vc.animeItem = animeItem
        vc.animeDetailLarge = detailData
        
        return vc
    }
    
    func gridCollectionVC(subjectID: Int, detailData: AnimeDetailLarge) -> GridCollectionViewController {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.GridCollectionVC) as! GridCollectionViewController
        vc.subjectID = subjectID
        vc.animeDetailLarge = detailData
        
        let epsDict = detailData.eps.eps
        vc.gridStatusTable = GridStatus(epsDict: epsDict)

        if let statusDict = self.subjectAllStatus where statusDict[subjectID] != nil{
            vc.subjectStatusDict = statusDict[subjectID]!
        }
        
        
        return vc
    }
    
    func viewControllerWithColorAndTitle (color: UIColor, title: String) -> UIViewController {
        
        let vc = UIViewController()
        vc.view.backgroundColor = color
        
        let label = UILabel (frame: vc.view.frame)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.font = UIFont (name: "HelveticaNeue-Light", size: 25)
        label.text = title
        
        label.sizeToFit()
        label.center = view.center
        
        vc.view.addSubview(label)
        
        return vc
    }

    
    func fetchAnimeDatailLargeData(handle: (AnimeDetailLarge?) -> Void ) {
        fetchingSpinner.startAnimating()
        
        self.request.getItemLargeDetail(animeItem.subject.id) { (animeDetailLargeData) -> Void in
            
            if let detailData = animeDetailLargeData {
                println("@ AnimeDetailVC: Get anime deatil data")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
    
                    self.fetchingSpinner.stopAnimating()
                    handle(detailData)
                })
            } else {
                println("@ AnimeDetailVC: Fail to get anime deatil data")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.fetchingSpinner.stopAnimating()
                    handle(nil)
                })
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
