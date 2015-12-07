//
//  AppDelegate.swift
//  Sandvik 365
//
//  Created by Karl Söderström on 22/07/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loadingView: LoadingView?
    var activityIndicator: UIActivityIndicatorView?
    var logoButton: UIButton?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let jsonManager = JSONManager()
        jsonManager.copyPreloadedFiles()
        jsonManager.checkforUpdate({ (success, lastModified) -> () in
            print("checkforUpdate. Last modified: %@", lastModified)
        })
        //always read
        jsonManager.readJSONFromFileAsync { (success) -> () in
            print("read json from file. success = %@", success)
        }
        
        let image = UIImage(named: "sandvik_small_back_arrow")?.resizableImageWithCapInsets((UIEdgeInsetsMake(0, 24, 0, 0)))
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(image, forState: .Normal, barMetrics: .Default)
        UIBarButtonItem.appearance().setBackButtonBackgroundVerticalPositionAdjustment(15, forBarMetrics: .Default)

        UINavigationBar.appearance().setTitleVerticalPositionAdjustment(15, forBarMetrics: .Default)

        UIViewController.swizzleViewDidLoad()
        if let window = self.window {
            window.makeKeyAndVisible()
            addLogoToView(window)
            showLoadingView()
            activityIndicator = UIActivityIndicatorView(frame: window.bounds)
            activityIndicator!.activityIndicatorViewStyle = .WhiteLarge
            activityIndicator!.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(activityIndicator!)
        }
        
        return true
    }
    
    private func addLogoToView(view: UIView) -> UIButton?
    {
        if let image = UIImage(named: "SANDVIK-logo-small") {
            self.logoButton = UIButton(type: .Custom)
            self.logoButton?.setImage(image, forState: .Normal)
            self.logoButton?.setImage(image, forState: .Disabled)
            let topConstraint = NSLayoutConstraint(item: self.logoButton!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 25)
            let trailConstraint = NSLayoutConstraint(item: self.logoButton!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -20)
            self.logoButton!.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self.logoButton!)
            NSLayoutConstraint.activateConstraints([topConstraint, trailConstraint])
            self.logoButton?.addTarget(self, action: Selector("popToRootAction"), forControlEvents: .TouchUpInside)
        }
        return self.logoButton
    }

    func hideLogoView() {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.logoButton?.alpha = 0.0
        }
    }
    
    func showLogoView() {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.logoButton?.alpha = 1.0
        }
    }
    
    func enableLogoButton(){
        self.logoButton?.enabled = true
    }
    
    func disableLogoButton(){
        self.logoButton?.enabled = false
    }
    
    func popToRootAction() {
        if let navController = self.window?.rootViewController as? UINavigationController {
            navController.popToRootViewControllerAnimated(true)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        addLoadingView()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        JSONManager().checkforUpdate({ (success, lastModified) -> () in
            print("checkforUpdate. Last modified: %@", lastModified)
        })
        showLoadingView()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func showLoadingView () {
        if loadingView == nil {
            addLoadingView()
        }
        
        if let loadingView = self.loadingView {
            loadingView.startLoadingAnimation()
        }
    }
    
    private func addLoadingView() {
        if let window = self.window {
            for v in window.subviews {
                if v.isKindOfClass(LoadingView) {
                    v.removeFromSuperview()
                }
            }
            loadingView = LoadingView(frame: window.bounds)
            if loadingView != nil {
                window.addSubview(loadingView!)
            }
        }
    }

}

