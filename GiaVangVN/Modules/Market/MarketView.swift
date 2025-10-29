//
//  MarketView.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 29/10/25.
//

import SwiftUI

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
                }.tabViewStyle(.page)
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Thị trường")
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    MarketView()
}


struct MarketGoldView: View {
    var body: some View {
        Text("Gold  View")
    }
}



struct MarketCurrencyView: View {
    var body: some View {
        Text("Gold  View")
    }
}
