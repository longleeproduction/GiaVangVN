//
//  MainView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//
import SwiftUI
import Combine
import AppTrackingTransparency

enum MainTabItem: Hashable {
    case market
    case wallet
    case calculator
    case news
    case gold
    case settings
}

class MainViewModel: ObservableObject {
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                debugPrint("ATT Status: \(status.rawValue)")
            }
        }
    }
}

struct MainView: View {
    // Check if running iOS 18 or later
    private var isIOS18OrLater: Bool {
        if #available(iOS 18.0, *) {
            return true
        }
        return false
    }

    // Get wallet icon based on iOS version
    private var walletIconName: String {
        isIOS18OrLater ? "wallet.bifold" : "wallet.pass"
    }
    
    
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        TabView {
            MarketView()
                .tag(MainTabItem.market)
                .tabItem {
                    Label("Thị trường", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            GoldView()
                .tag(MainTabItem.gold)
                .tabItem {
                    Label("Giá Vàng", systemImage: "chart.bar.xaxis")
                }

            GoldCalculatorView()
                .tag(MainTabItem.calculator)
                .tabItem {
                    Label("Chuyển đổi", systemImage: "function")
                }

            WalletView()
                .tag(MainTabItem.wallet)
                .tabItem {
                    Label("Ví", systemImage: walletIconName)
                }
            
            
            NewsView()
                .tag(MainTabItem.news)
                .tabItem {
                    Label("Tin tức", systemImage: "newspaper")
                }
            
//            SettingView()
//                .tag(MainTabItem.settings)
//                .tabItem {
//                    Label("Cài đặt", systemImage: "gear")
//                }.tint(Color(hex: "FFAC30"))
        }.tint(Color(hex: "FFAC30"))
        
    }
}

#Preview {
    MainView()
}


