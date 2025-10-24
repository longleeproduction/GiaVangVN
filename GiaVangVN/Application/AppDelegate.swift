//
//  AppDelegate.swift
//  GiaVangVN
//
//  Created by ORL on 20/10/25.
//

import Foundation
import UIKit
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        MobileAds.shared.start(completionHandler: nil)
                
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "11b702896278c9f0ec05068381b9bc3e",
            "dbe3bcf9a65be507e173311167947ecb",
            "4b776a3ac71259d116be2e9870bad7f5",
            "1add247b0794c2329ba1e1cc12979aa1"
        ]
        //Handle load form
        AdsManager.shared().loadConsentForm()
        AdsOpenApp.shared().requestOpenAppAds()
        AdsManager.shared().loadInterstitialAdDiscover()

        return true
    }
    
    //MARK: Life cirle
    func applicationDidBecomeActive() {
        AdsOpenApp.shared().tryToPresentAd()
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
