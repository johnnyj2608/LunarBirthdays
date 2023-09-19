//
//  GoogleAds.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/18/23.
//

import SwiftUI
import GoogleMobileAds


struct AdBannerView: UIViewRepresentable {

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        //let testID = "ca-app-pub-3940256099942544/2934735716"
        let realID = "ca-app-pub-9801573933886337/8773279101"
        bannerView.adUnitID = realID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            bannerView.rootViewController = windowScene.windows.first?.rootViewController
        }
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
