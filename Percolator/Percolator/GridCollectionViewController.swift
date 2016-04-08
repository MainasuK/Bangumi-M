//
//  GridCollectionViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-22.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

/*
import UIKit

let reuseIdentifier = "Cell"

class GridCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var subjectID = 0
    var subjectStatusDict = SubjectItemStatus()
    var animeDetailLarge = AnimeDetailLarge()
    
    var gridStatusTable = GridStatus()

    func fetchGridData() {
        // FIXME: get refresh method need
    }
    
    
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(GridCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        if subjectStatusDict.count == 0 {
            fetchGridData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return gridStatusTable.gridTable.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return gridStatusTable.gridTable[section].count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GridCollectionViewCell
    
        // Configure the cell
        
        let ep = gridStatusTable.gridTable[indexPath.section][indexPath.row]
        let epID = ep.id
        let epType = ep.type
        let epSort = ep.sort

        cell.GridNumberLabel.text = "\(epSort)"
        
        print("id:\(epID), sort:\(epSort), type:\(epType), bool:\(subjectStatusDict.subjectStatus[epID])")
        
        if let epStatusType = subjectStatusDict.subjectStatus[epID] {
            switch (epType, epStatusType) {
            case (EpisodeType.normal, let type) where type == EpStatusType.watched:
                cell.GridNumberLabel.backgroundColor = UIColor.blueColor()
            case (EpisodeType.normal, let type) where type == EpStatusType.queue:
                cell.GridNumberLabel.backgroundColor = UIColor.purpleColor()
            case (EpisodeType.normal, let type) where type == EpStatusType.drop:
                cell.GridNumberLabel.backgroundColor = UIColor.redColor()
                
            case (EpisodeType.op, _):     cell.GridNumberLabel.backgroundColor = UIColor.orangeColor()
            case (EpisodeType.sp, _):     cell.GridNumberLabel.backgroundColor = UIColor.greenColor()
            case (EpisodeType.ed, _):     cell.GridNumberLabel.backgroundColor = UIColor.redColor()
                
            default: print("Unknown type")
            }
            cell.GridNumberLabel.textColor = UIColor.whiteColor()
        } else {
            cell.GridNumberLabel.backgroundColor = UIColor.whiteColor() // reuse cell will turn white
            cell.GridNumberLabel.textColor = UIColor.blackColor()
        }

        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewSize = collectionView.frame.size
//        let collectionViewArea = Double(collectionViewSize.width * collectionViewSize.height)

        let sidezSize = (Double(collectionViewSize.width) / Double(8))
        return CGSize(width: sidezSize, height: sidezSize)
    }

}

 */