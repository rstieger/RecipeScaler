//
//  AppDelegate.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/6/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
                            
    var window: UIWindow?
    var recipes = RecipeList()
    var documentsUrl: NSURL?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        NSUserDefaults.standardUserDefaults().registerDefaults([
            "SettingsEnableUnitsUS": true,
            "SettingsEnableUnitsUK": false,
            "SettingsEnableUnitsMetric": true
            ])
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        documentsUrl = NSURL(fileURLWithPath: documentsPath)
        self.recipes = RecipeList.load(documentsUrl!)
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        // initialize master controller
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .AllVisible
        let masterViewController : RecipeListViewController = masterNavigationController.viewControllers[0] as! RecipeListViewController
        masterViewController.recipes = self.recipes
        // initialize detail controller
        let detailNavigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1]as! UINavigationController
        splitViewController.delegate = self
        let detailViewController : ScalingViewController = detailNavigationController.viewControllers[0] as! ScalingViewController
        if self.recipes.count == 0 {
            self.recipes.append(Recipe())   // so we always have one to see in detail view
        }
        // TODO: remember the last recipe viewed instead of the first by default
        // TODO?: go to it directly if iPhone?
        detailViewController.recipe = self.recipes[0]
        if let itemToScale = self.recipes[0].scaleToItem {
            detailViewController.itemToScale = itemToScale
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.saveState()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveState()
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        if let primaryAsNavController = primaryViewController as? UINavigationController {
            if let recipeListController = primaryAsNavController.topViewController as? RecipeListViewController {
                if let _ = recipeListController.tableView.indexPathForSelectedRow {
                    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
                        if let controller = secondaryAsNavController.topViewController as? CommonViewController {
                            controller.changeToCollapsedView()
                        }
                    }
                    return false
                }
            }
        }
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        if let primaryAsNavController = primaryViewController as? UINavigationController {
            if let recipeListController = primaryAsNavController.topViewController as? RecipeListViewController {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RecipeToScale") as! ScalingViewController
                var row: Int
                if let selectedPath = recipeListController.tableView.indexPathForSelectedRow {
                    row = selectedPath.row
                }
                else {
                    row = 0
                }
                vc.recipe = self.recipes[row]
                vc.title = self.recipes[row].name
                return UINavigationController(rootViewController: vc)
            }
            else if let secondaryAsNavController = primaryAsNavController.topViewController as? UINavigationController {
                if let controller = secondaryAsNavController.topViewController as? CommonViewController {
                    controller.changeToSplitView()
                }
                else {
                    RonicsError.report(.InvalidController)
                }
            }
            else {
                RonicsError.report(.InvalidController)
            }
        }

        return nil
    }
    
    func saveState() {
        recipes.save(documentsUrl!)
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
//        self.window?.rootViewController?.restoreUserActivityState(userActivity)
        print("got an activity!")
        return true
    }
}

