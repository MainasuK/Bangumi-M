//
//  AnimeDetailTableViewController.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-16.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit

class AnimeDetailTableViewController: UITableViewController {
    
    let request = BangumiRequest.shared
    let animeModel = BangumiAnimeModel.shared
    var animeItem = Anime()
    var animeDetailLarge = AnimeDetailLarge?()

    var isFirstLoaded = true
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        refreshControl?.beginRefreshing()
        let item = animeItem
        print("getDetail start")
        
            self.request.getItemLargeDetail(item.subject.id) { (animeDetailLargeData) -> Void in
                
                if let detailData = animeDetailLargeData {
                    print("@ AnimeDetailTableVC: Get anime deatil data")
                    self.animeDetailLarge = detailData
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    })
                } else {
                    print("@ AnimeDetailTableVC: Fail to get anime deatil data")
                    self.refreshControl?.endRefreshing()
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        tableView.registerClass(AnimeDetailTableViewCell.self, forCellReuseIdentifier: Storyboard.animeDetailTitleCellIdentifier)
//        
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if isFirstLoaded {
            let indexSet = NSIndexSet(index: 0)
            tableView.reloadSections(indexSet, withRowAnimation: .None)
            isFirstLoaded = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if animeDetailLarge?.summary != "" {
            return 2
        }
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier(StoryboardKey.animeDetailTitleCell, forIndexPath: indexPath) as! AnimeDetailTableViewCell

            cell.nameLabel.text = animeItem.subject.name
            cell.nameCNLabel.text = animeItem.subject.nameCN
            
            cell.AnimeDetailImageView.hnk_setImageFromURL(NSURL(string: animeItem.subject.images.largeUrl)!, placeholder: UIImage(named: "404"))
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier(StoryboardKey.animeDetailSummayTableViewCell, forIndexPath: indexPath) as! AnimeDetailSummayTableViewCell
            
            cell.summary.text = animeDetailLarge?.summary
            
            return cell
        }
    }
    

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

}
