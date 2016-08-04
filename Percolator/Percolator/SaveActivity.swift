//
//  SaveActivity.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-26.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import SVProgressHUD

class SaveActivity: UIActivity {
    
    var subject: SubjectWrapper?

    override var activityType: String? {
        return "Percolator.Save"
    }
    
    override var activityTitle: String? {
        return NSLocalizedString("save to search box", comment: "")
    }
    
    override func canPerform(withActivityItems activityItems: [AnyObject]) -> Bool {
        for item in activityItems {
            if let subject = item as? SubjectWrapper {
                return !subject.isSaved()
            }
        }
        
        return false
    }
    
    override func prepare(withActivityItems activityItems: [AnyObject]) {
        for item in activityItems {
            if let subject = item as? SubjectWrapper {
                self.subject = subject
            }
        }
    }
    
    override var activityViewController: UIViewController? {
        return nil
    }
    
    override func perform() {
        guard subject?.saveToCoreData() == true else {
            SVProgressHUD.showInfo(withStatus: "保存失败")
            return
        }
        
        SVProgressHUD.showSuccess(withStatus: "保存成功")
    }
    
    
    override var activityImage: UIImage? {
        return #imageLiteral(resourceName: "AddArrow")
    }
    
}
