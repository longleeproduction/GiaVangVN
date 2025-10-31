//
//  MarketGoldView.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import SwiftUI

struct MarketGoldView: View {
    
    @EnvironmentObject private var viewModel : MarketViewModel
    
    @StateObject var goldViewModel = GoldDetailViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                // Price in - out
                priceView(title: "Mua vào", price: "$13,240.11", percent: "1.74%")
                
                priceView(title: "Bán ra", price: "$13,240.11", percent: "1.74%")
                
                // Biểu đồ
                VStack {
                    HStack {
                        ForEach(ListRange.allCases, id: \.self) { item in
                            MarketRangeItemView(range: item, isSelected: goldViewModel.range == item)
                                .onTapGesture {
                                    goldViewModel.range = item
                                    refreshData()
                                }
                        }
                        //goldViewModel.range
                    }.frame(maxWidth: 500)
                    
                    if goldViewModel.isLoading {
                        ProgressView()
                            .padding()
                        
                        Text("Loading")
                    }
                    
                    if let data = goldViewModel.goldData {
                        GoldChartView(data: data)
                    }
                }.frame(maxHeight: 400)
                    .frame(maxWidth: .infinity)
                
                // List branch
                
                VStack(spacing: 0) {
                    ForEach(viewModel.listGoldMarkets, id: \.id) { item in
                        Button {
                            viewModel.currentGoldMarket = item
                            refreshData()
                        } label: {
                            MarketGoldItemView(item: item, isSelected: viewModel.currentGoldMarket == item)
                        }
                    }
                }
            }.padding(.horizontal, 16)
        }.task {
            if let item = viewModel.currentGoldMarket {
                goldViewModel.getGoldDetail(product: item.product, branch: item.branch, city: item.city)
            }
        }
        
    }
    
    private func refreshData() {
        guard let item = viewModel.currentGoldMarket else { return }
        goldViewModel.getGoldDetail(product: item.product, branch: item.branch, city: item.city)
    }
    
    @ViewBuilder
    func priceView(title: String, price: String, percent: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color(hex: "A0AEC0"))
            
            HStack(alignment: .bottom) {
                Text(price)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(percent)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.bottom, 3)
                
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .padding(.bottom, 3)
            }
        }
    }
}

struct MarketRangeItemView : View {
    var range: ListRange
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(range.title)
                .font(.footnote)
                .foregroundColor(isSelected ? Color(hex: "7FDF9A") : .white)
            
            if isSelected {
                Divider()
                    .frame(height: 1)
                    .foregroundStyle(Color(hex: "7FDF9A"))
            }
        }
    }
}

struct MarketGoldItemView: View {
    var item: GoldMarketModel
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Image(item.branch.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 21))
            
            VStack(alignment: .leading) {
                Text(item.branch.title)
                    .font(.footnote)
                
                Text(item.product)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }.frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 43)
                .padding(.vertical, 10)
            
            // Price
            
            VStack(alignment: .trailing) {
                Text("21,98")
                    .font(.footnote)
                    .fontWeight(.semibold)
                
                Text("+1 (+0,53%)")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }.padding(.horizontal, 10)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
