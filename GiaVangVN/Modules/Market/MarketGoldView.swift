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
                if goldViewModel.isLoading {
                    // Show loading placeholders
                    priceLoadingView(title: "Mua vào")
                    priceLoadingView(title: "Bán ra")
                } else if let latestData = goldViewModel.goldData?.list.first {
                    priceView(
                        title: "Mua vào",
                        price: ApiDecryptor.decrypt(latestData.buyDisplay),
                        percent: ApiDecryptor.decrypt(latestData.buyPercent),
                        delta: ApiDecryptor.decrypt(latestData.buyDelta)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    priceView(
                        title: "Bán ra",
                        price: ApiDecryptor.decrypt(latestData.sellDisplay),
                        percent: ApiDecryptor.decrypt(latestData.sellPercent),
                        delta: ApiDecryptor.decrypt(latestData.sellDelta)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    // Placeholder when no data
                    priceView(title: "Mua vào", price: "--", percent: "0%", delta: "0")
                    priceView(title: "Bán ra", price: "--", percent: "0%", delta: "0")
                }
                
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
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)

                            Text("Đang tải dữ liệu...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .transition(.opacity)
                    }
                    
                    if let data = goldViewModel.goldData, !goldViewModel.isLoading {
                        GoldChartView(data: data)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .animation(.easeInOut(duration: 0.4), value: goldViewModel.goldData?.list.count)
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
    func priceLoadingView(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color(hex: "A0AEC0"))

            HStack(alignment: .bottom, spacing: 12) {
                // Shimmer effect for price
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 150, height: 32)
                    .shimmer()

                // Shimmer effect for percent
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 20)
                    .shimmer()
            }
        }
    }

    @ViewBuilder
    func priceView(title: String, price: String, percent: String, delta: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color(hex: "A0AEC0"))

            HStack(alignment: .bottom) {
                Text(price)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Determine if price went up or down
                let isPositive = !delta.hasPrefix("-") && delta != "0"
                let isNegative = delta.hasPrefix("-")

                if !percent.isEmpty && percent != "0%" {
                    Text(percent)
                        .font(.caption)
                        .foregroundColor(isPositive ? Color(hex: "7FDF9A") : (isNegative ? .red : .white))
                        .padding(.bottom, 3)

                    if isPositive {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(Color(hex: "7FDF9A"))
                            .padding(.bottom, 3)
                    } else if isNegative {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.red)
                            .padding(.bottom, 3)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: price)
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
                    .multilineTextAlignment(.leading)
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

// MARK: - Shimmer Effect Extension
extension View {
    @ViewBuilder
    func shimmer() -> some View {
        self
            .overlay(
                GeometryReader { geometry in
                    ShimmerEffectView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            )
            .mask(self)
    }
}

struct ShimmerEffectView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.6),
                    Color.white.opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 2)
            .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
        }
    }
}
