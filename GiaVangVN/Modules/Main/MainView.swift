//
//  MainView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//
import SwiftUI

enum MainTabItem: Hashable {
    case home
    case wallet
    case gold
    case currency
    case settings
}

struct MainView: View {
    var body: some View {
        TabView {
            DashBoardView()
                .tag(MainTabItem.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            WalletView()
                .tag(MainTabItem.wallet)
                .tabItem {
                    Label("Wallet", systemImage: "wallet.pass")
                }
            
            GoldView()
                .tag(MainTabItem.gold)
                .tabItem {
                    Label("Gold Price", systemImage: "g.circle")
                }
            
            CurrencyView()
                .tag(MainTabItem.currency)
                .tabItem {
                    Label("Currency", systemImage: "dollarsign.arrow.circlepath")
                }
            
            SettingView()
                .tag(MainTabItem.settings)
                .tabItem {
                    Label("Settings", systemImage: "circle.hexagongrid")
                }
        }
    }
}

#Preview {
    MainView()
}


