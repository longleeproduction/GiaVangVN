//
//  AppDelegate.swift
//  GiaVangVN
//
//  Created by ORL on 20/10/25.
//

import Foundation
import UIKit
import GoogleMobileAds
import SwiftRater
import AppTrackingTransparency

class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // Configure test devices first
//        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
//            "11b702896278c9f0ec05068381b9bc3e",
//            "dbe3bcf9a65be507e173311167947ecb",
//            "4b776a3ac71259d116be2e9870bad7f5",
//            "1add247b0794c2329ba1e1cc12979aa1"
//        ]
//
//        // Start Mobile Ads SDK asynchronously
        MobileAds.shared.start { _ in
            // Load ads after SDK initialization completes
            DispatchQueue.main.async {
                AdsManager.shared().loadConsentForm()
                AdsOpenApp.shared().requestOpenAppAds()
                AdsManager.shared().loadInterstitialAd()
            }
        }
        
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.appLaunched()

        return true
    }
    
    //MARK: Life cirle
    func applicationDidBecomeActive() {
        AdsOpenApp.shared().tryToPresentAd()
        
        // Request ATT if not already requested (especially important for iPad)
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            // Delay slightly to ensure UI is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    debugPrint("ATT Status: \(status.rawValue)")
                }
            }
        }

    }
    
    func applicationDidEnterBackground() {
    }
    
    func applicationWillEnterForeground() {
    }
    
    func applicationWillTerminate() {
    }
    
    //
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Messaging.messaging().apnsToken = deviceToken
    }
    
}
