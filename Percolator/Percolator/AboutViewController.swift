//
//  AboutViewController.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-24.
//
//

import UIKit

class AboutViewController: UIViewController, SWRevealViewControllerDelegate {

    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.revealViewController().revealToggle(nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
