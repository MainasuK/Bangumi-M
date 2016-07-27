//
//  DeleteActivity.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-26.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit
import SVProgressHUD

class DeleteActivity: UIActivity {
    var subject: SubjectWrapper?
    
    override func activityType() -> String? {
        return "Percolator.Delete"
    }
    
    override func activityTitle() -> String? {
        return NSLocalizedString("delete from search box", comment: "")
    }
    
    override func canPerform(withActivityItems activityItems: [AnyObject]) -> Bool {
        for item in activityItems {
            if let subject = item as? SubjectWrapper {
                return subject.isSaved()
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
    
    override func activityViewController() -> UIViewController? {
        return nil
    }
    
    override func perform() {
        guard subject?.deleteFromCoreData() == true else {
            SVProgressHUD.showInfo(withStatus: "删除失败")
            return
        }
        
        SVProgressHUD.showSuccess(withStatus: "删除成功")
    }
    
    
    override func activityImage() -> UIImage? {
        return #imageLiteral(resourceName: "RemoveArrow")
    }
}
