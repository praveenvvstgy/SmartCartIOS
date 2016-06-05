//
//  AppDelegate.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 5/22/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import Firebase
import FoldingTabBar
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        FIRApp.configure()
        print("There are \(shoppingList.count()) items in shopping List")
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setupTabBarController()
        return true
    }
    
    func setupTabBarController() {
        let tabBarController = window?.rootViewController as! YALFoldingTabBarController
        
        let searchItem = YALTabBarItem(itemImage: UIImage(named: "search"), leftItemImage: nil, rightItemImage: nil)
        let listItem = YALTabBarItem(itemImage: UIImage(named: "list"), leftItemImage: nil, rightItemImage: nil)
        tabBarController.leftBarItems = [searchItem, listItem]
        
        let cartItem = YALTabBarItem(itemImage: UIImage(named: "cart"), leftItemImage: UIImage(named: "recommend"), rightItemImage: UIImage(named: "checkout"))
        tabBarController.rightBarItems = [cartItem]
        
        tabBarController.centerButtonImage = UIImage(named: "menu")
        tabBarController.tabBarView.tintColor = FlatWhite()
        
        tabBarController.tabBarView.backgroundColor = ClearColor()
        tabBarController.tabBarView.tabBarColor = FlatMint()
        tabBarController.tabBarView.dotColor = FlatLime()
        tabBarController.tabBarViewHeight = YALTabBarViewDefaultHeight
        tabBarController.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets
        tabBarController.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets
        
        tabBarController.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight
        tabBarController.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

