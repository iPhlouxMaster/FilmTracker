//
//  AppDelegate.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 30/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: NSError?) {
    if let error = error {
        print("*** Fatal error: \(error), \(error.userInfo)")
    }
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var menuNav: UINavigationController!
    var viewControllersNav: UINavigationController!
    var viewControllers: [UIViewController]!
    
    var sidebarVC: SidebarViewController!
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
            if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let documentsDirectory = urls[0] 
                let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
                do {
                    let store = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
                    let context = NSManagedObjectContext()
                    context.persistentStoreCoordinator = coordinator
                    return context
                } catch let error as NSError {
                    print("Error adding persistent store at \(storeURL): \(error)")
                }
            } else {
                print("Error initializing model from: \(modelURL)")
            }
        } else {
            print("Could not find data model in app bundle")
        }
        
        abort()
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window?.tintColor = UIColor.blackColor()
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        _ = CountriesAndGenres()
        
        listenForFatalCoreDataNotifications()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        let movieListVC = storyboard.instantiateViewControllerWithIdentifier("MovieListVC") as! MovieListViewController
        movieListVC.delegate = self
        let searchVC = storyboard.instantiateViewControllerWithIdentifier("SearchVC") as! SearchViewController
        searchVC.delegate = self
        let aboutVC = storyboard.instantiateViewControllerWithIdentifier("AboutVC") as! AboutViewController
        aboutVC.delegate = self
        viewControllers = [movieListVC, searchVC, aboutVC]
    
        viewControllersNav = UINavigationController(rootViewController: viewControllers[0])
        
        let menuVC = storyboard.instantiateViewControllerWithIdentifier("MenuVC") as! MenuTableViewController
        menuVC.delegate = self
        menuNav = UINavigationController(rootViewController: menuVC)
        
        sidebarVC = SidebarViewController(menuViewController: menuVC, mainViewController: viewControllersNav, overlappedWidth: 60)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = sidebarVC
        window?.makeKeyAndVisible()
        
        return true
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
    
    func listenForFatalCoreDataNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            
            alert.addAction(action)
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

extension AppDelegate {
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                
                // Pass the userActivity to movieListViewController and call restoreUserActivityState()
                
                sidebarVC.closeMenuAnimated(false)
                
                let movieListViewController = viewControllers[0] as! MovieListViewController
                if viewControllersNav.topViewController != movieListViewController {
                    viewControllersNav.setViewControllers([movieListViewController], animated: true)
                    movieListViewController.managedObjectContext = managedObjectContext
                }
                
                movieListViewController.restoreUserActivityState(userActivity)
                
                return true
            }
            return false
        }
        return false
    }
}

extension AppDelegate: MovieListViewControllerDelegate {
    func movieListViewControllerDidTapMenuButton(controller: MovieListViewController) {
        sidebarVC.toggleMenuAnimated(true)
    }
}

extension AppDelegate: SearchViewControllerDelegate {
    func searchViewControllerDidTapMenuButton(controller: SearchViewController) {
        sidebarVC.toggleMenuAnimated(true)
    }
}

extension AppDelegate: AboutViewControllerDelegate {
    func aboutViewControllerDidTapMenuButton(controller: AboutViewController) {
        sidebarVC.toggleMenuAnimated(true)
    }
}

extension AppDelegate: MenuTableViewControllerDelegate {
    func menuTableViewController(controller: MenuTableViewController, didSelectRow row: Int) {
        
        sidebarVC.closeMenuAnimated(true)
    
        let destinationViewController = viewControllers[row - 1]
        if viewControllersNav.topViewController != destinationViewController {
            viewControllersNav.setViewControllers([destinationViewController], animated: true)
        }
    }
}

