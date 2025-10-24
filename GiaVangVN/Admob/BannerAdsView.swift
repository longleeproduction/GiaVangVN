//
//  BannerAdsView.swift
//

import SwiftUI
import GoogleMobileAds

struct BannerAdsView: UIViewRepresentable {

    var unitID: String
    var size: AdSize

    func makeCoordinator() -> Coordinator {
        // For Implementing Delegates..
        return Coordinator()
    }

    func makeUIView(context: Context) -> BannerView{
        let adView = BannerView(adSize: size)

        adView.adUnitID = unitID
        adView.rootViewController = UIApplication.shared.getRootViewController()

        adView.load(AdsManager.shared().makeRequest())

        return adView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {

    }

    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("bannerViewDidReceiveAd")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

        func bannerViewDidRecordImpression(_ bannerView: BannerView) {
            print("bannerViewDidRecordImpression")
        }

        func bannerViewWillPresentScreen(_ bannerView: BannerView) {
            print("bannerViewWillPresentScreen")
        }

        func bannerViewWillDismissScreen(_ bannerView: BannerView) {
            print("bannerViewWillDIsmissScreen")
        }

        func bannerViewDidDismissScreen(_ bannerView: BannerView) {
            print("bannerViewDidDismissScreen")
        }
    }
}
