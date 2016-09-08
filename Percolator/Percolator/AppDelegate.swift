//
//  AppDelegate.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-5-15.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
import SVProgressHUD
import EUMTouchPointView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    public var window: EUMShowTouchWindow? = EUMShowTouchWindow(frame: UIScreen.main.bounds)       // For App Preview
    lazy var coreDataStack: CoreDataStack = {
        let options: [AnyHashable : Any] = [NSPersistentStoreUbiquitousContentNameKey : "Percolator",
                                            NSMigratePersistentStoresAutomaticallyOption : true,
                                            NSInferMappingModelAutomaticallyOption : true]
        return CoreDataStack(modelName: "Percolator", storeName: "Percolator", options: options)
    }()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        
        // Restore user info and update auth
        if let user = User() {
            BangumiRequest.shared.user = user
            user.updateAuth()
        } else {
            User.removeInfo()
        }

        // Set version info in Setting
        UserDefaults.standard.setValue(UIApplication.appVersion(), forKey: "Percolator.appVersion")
        UserDefaults.standard.setValue(UIApplication.appBuild(), forKey: "Percolator.appBundle")
        UserDefaults.standard.synchronize()
        
        // Set AlamofireImage cache
        UIImageView.af_sharedImageDownloader = ImageDownloader(
            configuration: ImageDownloader.defaultURLSessionConfiguration(),
            downloadPrioritization: .fifo,
            maximumActiveDownloads: 4,
            imageCache: AutoPurgingImageCache()
        )
        
        setSVProgressHUD(style: .dark)
        
        return true
    }
    
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        // Only allow iPad device rotate
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.all
        }
        
        return UIInterfaceOrientationMask.portrait
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
