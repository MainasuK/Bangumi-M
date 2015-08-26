//
//  MenuTableViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-11.
//
//

import UIKit

class MenuTableViewController: UITableViewController, MenuTransitionDelegate {
    
    @IBAction func superTopicButtonPressed(sender: AnyObject) {
        let url = "http://bangumi.tv/m"
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.revealViewController().revealToggle(nil)
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        })
    }
    
    @IBAction func aboutmeButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        debugPrintln("User logout")
        User.deleteUserInfo()
        BangumiAnimeModel.shared.dropModel()
        BangumiFavoriteModel.shared.dropModel()
        BangumiRequest.shared.userData = nil
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.loginVC) as! LoginViewController
        loginVC.delegate = self
        NSNotificationCenter.defaultCenter().postNotificationName("userLogout", object: nil)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(loginVC, animated: true, completion: nil)
        })
    }
    
    // MARK: - MenuTransitionDelegate
    func dismissLoginVC() {
        let tabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.animeTableViewVC) as! UINavigationController
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.revealViewController().revealToggle(nil)
        })
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("MenuTableViewController did load")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSLog("MenueTableViewController will disappear")
    }
    
    deinit {
        NSLog("MenuTableViewController is being deallocated")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }
    */

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

}
