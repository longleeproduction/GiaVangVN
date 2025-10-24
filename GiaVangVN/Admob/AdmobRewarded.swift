//
//  AdmobRewarded.swift
//

import Foundation
import GoogleMobileAds

public typealias AdmobVoidComplete = () -> Void
public typealias AdmobBoolComplete = (_ rewarded: Bool) -> Void

final public class AdmobRewarded: NSObject, FullScreenContentDelegate {
    
    var rewardedAd: RewardedAd?
    
    private var isEarnRewarded: Bool = false
    public var completion: AdmobBoolComplete?
    public var rewardFunction: AdmobBoolComplete?
    //private var loadCompletion: ((RewardedAd?, Error?) -> Void )?
    
    
    private var showAfterLoaded: Bool = false
    
    public init(
        rewardId: String,
        loadCompletion: ((RewardedAd?, Error?) -> Void )? = nil,
        showAfterLoaded: Bool = false,
        completion: AdmobBoolComplete? = nil
    ) {
        super.init()
        self.showAfterLoaded = showAfterLoaded
        self.completion = completion
        self.loadReward(rewardId, loadCompletion: loadCompletion)
    }
    
    deinit {
        debugPrint("[AdmobRewarded] --> DEINIT")
    }
    
    func loadReward(_ rewardId: String, loadCompletion: ((RewardedAd?, Error?) -> Void )? = nil){
        let request = Request()
        // add extras here to the request, for example, for not presonalized Ads
        RewardedAd.load(with: rewardId, request: request, completionHandler: {rewardedAd, error in
            if error != nil {
                // loading the rewarded Ad failed :(
                debugPrint("[AdmobRewarded] --> ADS LOADING: error \(String(describing: error?.localizedDescription))")
            } else {
                debugPrint("[AdmobRewarded] --> ADS LOADING: SUCCESS")
                self.rewardedAd = rewardedAd
                if self.showAfterLoaded {
                    guard let root = UIApplication.shared.topMostViewController else {
                        return
                    }
                    self.rewardedAd?.fullScreenContentDelegate = self
                    self.rewardedAd?.present(from: root) {
                        if let action = self.rewardFunction {
                            action(true)
                        }
                        self.isEarnRewarded = true
                    }
                }
            }
            if let action = loadCompletion {
                action(rewardedAd, error)
            }
        })
    }
    
    public func showReward(rewardFunction: @escaping AdmobVoidComplete, rewardComplete: @escaping AdmobBoolComplete) -> Bool {
        guard let rewardedAd = rewardedAd else {
            return false
        }
        
        guard let root = UIApplication.shared.topMostViewController else {
            return false
        }
        self.isEarnRewarded = false
        //Save for dismis and callback
        self.completion = rewardComplete
        
        rewardedAd.fullScreenContentDelegate = self
        rewardedAd.present(from: root) {
            rewardFunction()
            // Ok reward
            self.isEarnRewarded = true
        }
        return true
    }
    
    public func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        debugPrint("adDidDismissFullScreenContent ---->")
        if let action = self.completion {
            debugPrint("adDidDismissFullScreenContent ----> CALLBACK REWARED...")
            action(self.isEarnRewarded)
        }
    }
    
    public func adWillDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        
    }
}
