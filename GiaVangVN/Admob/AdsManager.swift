//
//  AdsManager.swift
//

import Foundation
import GoogleMobileAds
import SwiftUI
import UserMessagingPlatform

struct Admob {
#if targetEnvironment(simulator) || DEBUG
    static let bannerId             = "ca-app-pub-3940256099942544/2934735716"
    static let nativeId             = "ca-app-pub-3940256099942544/2521693316"
    static let openAppId            = "ca-app-pub-3940256099942544/5575463023"
    static let fullScreenId         = "ca-app-pub-3940256099942544/4411468910"
#else
    static let bannerId             = "ca-app-pub-5018745952984578/1305690245"
    static let nativeId             = "ca-app-pub-5018745952984578/6991722281"
    static let openAppId            = "ca-app-pub-5018745952984578/4533079901"
    static let fullScreenId         = "ca-app-pub-5018745952984578/9180284814"
#endif

}


class AdsManager: NSObject, FullScreenContentDelegate {

    private static let sharedInstance = AdsManager()

    static func shared() -> AdsManager {
        return sharedInstance
    }

    private var interstitial: InterstitialAd?
    private var interstitialLastShowed: Date?
    private var cooldownAdsTime: Double = 5 // unit minute -
    private var completeFullScreenAds: AdmobVoidComplete?
    
    private var interstitialDiscover: InterstitialAd?
    private var discoverCount: Int = 0
    private var completeDiscover: AdmobVoidComplete?
    
    private var adsDiscoverCount: Int = 8
    
    private var isPayment: Bool {
        get {
            return false
        }
    }

    func loadConsentForm() {
        //Handle load form
        // Create a UMPRequestParameters object
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false

        // Request an update to the consent information
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters, completionHandler: { error in
            if error != nil {
                // Handle the error.
            } else {
                // The consent information state was updated. You are now ready to check if a form is available.
                let formStatus = ConsentInformation.shared.formStatus
                if formStatus == .available {
                    // Load the form
                    self.loadForm()
                }
            }
        })
    }
    
    // Load GDPR form
    private func loadForm() {
        ConsentForm.load { form, loadError in
            if loadError != nil {
                // Handle the error.
            } else {
                // Present the form. You can also hold on to the reference to present later.
                if ConsentInformation.shared.consentStatus == .required {
                    if let viewController = UIApplication.shared.keyWindowPresentedController {
                        form?.present(
                            from: viewController,
                            completionHandler: { dismissError in
                                if ConsentInformation.shared.consentStatus == .obtained {
                                    // App can start requesting ads.
                                }
                                // Handle dismissal by reloading form.
                                self.loadForm()
                            }
                        )
                    }
                } else {
                    // Keep the form available for changes to user consent.
                }
            }
        }
    }
    
    func showInterstitialAd(_ complete: AdmobVoidComplete? = nil) {
        if self.isPayment {
            if let action = complete {
                action()
            }
            return
        }
                
        self.completeFullScreenAds = nil
        if interstitial != nil {

            // Check 2: Cooldown period - don't show ads more than once per minute
            if let date = interstitialLastShowed {
                let timeSinceLastAd = Date.now.timeIntervalSince(date)
                if timeSinceLastAd < cooldownAdsTime * 60 { // 5 minute cooldown between ads
                    if let action = complete {
                        action()
                    }
                    debugPrint("[AdsManager] ---> Not show ads \(cooldownAdsTime) minute cooldown between ads")
                    return
                }
            }

            // Both checks passed, show the ad
            if let controller = UIApplication.shared.topMostViewController {
                interstitial?.present(from: controller)
                interstitialLastShowed = Date.now
                self.completeFullScreenAds = complete
            } else {
                if let action = complete {
                    action()
                }
            }
        } else {
            if let action = complete {
                action()
            }
            loadInterstitialAd()
        }
    }
    
    func showInterstitialAdDiscover(complete: @escaping AdmobVoidComplete) {
        completeDiscover = complete
        if self.isPayment {
            complete()
            return
        }
        // Add && self.discoverCount > 0 for display firt time call.
        if self.discoverCount < adsDiscoverCount && self.discoverCount > 0 {
            self.discoverCount += 1
            complete()
            return
        }
        if interstitialDiscover != nil {
            if let controller = UIApplication.shared.topMostViewController {
                interstitialDiscover?.present(from: controller)
                self.discoverCount = 1
            } else {
                complete()
            }
        } else {
            complete()
            loadInterstitialAdDiscover()
        }
    }
    
    func makeRequest() -> Request {
        let request = Request()
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            request.scene = scene
        }
        return request
    }
    
    func loadAds() {
        self.loadInterstitialAd()
        self.loadInterstitialAdDiscover()
    }
    
    //private func
    func loadInterstitialAd() {
        if interstitial != nil {
            return
        }
        
        InterstitialAd.load(with: Admob.fullScreenId,
                               request: self.makeRequest(),
            completionHandler: { [self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.interstitial = ad
                    self.interstitial?.fullScreenContentDelegate = self
                    print("loadInterstitialAd to load interstitial ad success!")
                }
            }
        )
    }
    
    func loadInterstitialAdDiscover() {
        if interstitialDiscover != nil {
            return
        }
        
        InterstitialAd.load(with: Admob.fullScreenId,
                               request: self.makeRequest(),
            completionHandler: { [self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.interstitialDiscover = ad
                    self.interstitialDiscover?.fullScreenContentDelegate = self
                    print("loadInterstitialAd to load interstitial ad success!")
                }
            }
        )
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        if (ad as? InterstitialAd) == self.interstitialDiscover {
            self.interstitialDiscover = nil
            self.loadInterstitialAdDiscover()
            if let complete = self.completeDiscover {
                complete()
            }
        }
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        if (ad as? InterstitialAd)  == self.interstitial {
            self.interstitial = nil
            self.loadInterstitialAd()
            if let action = self.completeFullScreenAds {
                action()
            }
        }
        if (ad as? InterstitialAd)  == self.interstitialDiscover {
            self.interstitialDiscover = nil
            self.loadInterstitialAdDiscover()
            if let complete = self.completeDiscover {
                complete()
            }
        }
    }

    
    
}
