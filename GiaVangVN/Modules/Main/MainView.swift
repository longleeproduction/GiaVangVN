//
//  MainView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//
import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            DashBoardView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            GoldView()
                .tag(1)
                .tabItem {
                    Label("Gold Price", systemImage: "g.circle")
                }
            
            CurrencyView()
                .tag(2)
                .tabItem {
                    Label("Currency", systemImage: "dollarsign.arrow.circlepath")
                }
            
            SettingView()
                .tag(3)
                .tabItem {
                    Label("Settings", systemImage: "circle.hexagongrid")
                }
        }
    }
}

#Preview {
    MainView()
}


