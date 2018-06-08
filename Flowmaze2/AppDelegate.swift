    //
//  AppDelegate.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 26.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PersonalizedAdConsent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
   //     GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511") // TEST
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3752721631578562~1874643129") // PROD

        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(
            forPublisherIdentifiers: ["pub-3752721631578562"])
        {(_ error: Error?) -> Void in
            if let error = error {
                print("Error:"+error.localizedDescription)
                // Consent info update failed.
            } else {
                NSLog("Managed to get updated concent info")
                
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name("pauseGame"), object: nil)

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name("restartGame"), object: nil)

        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
 
}

