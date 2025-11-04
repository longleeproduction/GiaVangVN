//
//  MarketView.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 29/10/25.
//

import SwiftUI
import SwiftUIIntrospect

struct MarketView: View {
    
    @StateObject private var viewModel = MarketViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Tab Picker
                Picker("Thị trường", selection: $viewModel.selectedTab) {
                    Text("Giá Vàng").tag(MarketViewModel.MarketTab.Gold)
                    Text("Tỷ Giá").tag(MarketViewModel.MarketTab.Currency)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $viewModel.selectedTab) {
                    MarketGoldView()
                        .tag(MarketViewModel.MarketTab.Gold)

                    MarketCurrencyView()
                        .tag(MarketViewModel.MarketTab.Currency)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .introspect(.scrollView, on: .iOS(.v16, .v17, .v18, .v26)) { scrollView in
                    scrollView.isScrollEnabled = false
                }
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Thị trường")
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    MarketView()
}



