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
    
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        VStack(spacing: 0) {
            // Preloading progress indicator
            if viewModel.isPreloading {
                PreloadingProgressView(progress: viewModel.preloadProgress)
                    .transition(.opacity)
            }
            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: 1)
                            .id("scrollTop")

                        VStack(alignment: .leading, spacing: 16) {
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
                                HStack(spacing: 10) {
                                    ForEach(ListRange.allCases, id: \.self) { item in
                                        MarketRangeItemView(range: item, isSelected: goldViewModel.range == item)
                                            .onTapGesture {
                                                goldViewModel.range = item
                                                refreshData()
                                            }
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 10)

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
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

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
                        }.frame(maxWidth: .infinity, alignment: .leading) // End inner VStack with spacing
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .onAppear {
                    self.scrollProxy = scrollProxy
                }
            }.task {
                if let item = viewModel.currentGoldMarket {
                    goldViewModel.getGoldDetail(product: item.product, branch: item.branch, city: item.city)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isPreloading)
    }
    
    private func refreshData() {
        guard let item = viewModel.currentGoldMarket else { return }

        // Scroll to top with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            self.scrollProxy?.scrollTo("scrollTop", anchor: .top)
        }

        // Check cache for selected range
        switch goldViewModel.range {
        case .Range7d:
            if let cachedData = item.data7Day {
                goldViewModel.goldData = cachedData
                return
            }
        case .Range30d:
            if let cachedData = item.data30Day {
                goldViewModel.goldData = cachedData
                return
            }
        case .Range60d:
            if let cachedData = item.data60Day {
                goldViewModel.goldData = cachedData
                return
            }
        case .Range180d:
            if let cachedData = item.data180Day {
                goldViewModel.goldData = cachedData
                return
            }
        case .Range365d:
            if let cachedData = item.data365Day {
                goldViewModel.goldData = cachedData
                return
            }
        }

        // Fetch new data if cache miss
        goldViewModel.getGoldDetail(product: item.product, branch: item.branch, city: item.city) {
            item.cacheDataForRange(goldViewModel.range, data: goldViewModel.goldData)
        }
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
        }.frame(maxWidth: .infinity, alignment: .leading)
        .animation(.easeInOut(duration: 0.3), value: price)
    }
}

struct MarketRangeItemView : View {
    var range: ListRange
    var isSelected: Bool

    var body: some View {
        Text(range.title)
            .font(.footnote)
            .foregroundColor(isSelected ? Color(hex: "7FDF9A") : .white)
            .padding(.bottom, 4)
            .padding(4)
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .fill(Color(hex: "7FDF9A"))
                        .frame(height: 2)
                }
            }
    }
}

struct MarketGoldItemView: View {
    @ObservedObject var item: GoldMarketModel
    var isSelected: Bool
    @State private var justLoaded: Bool = false

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

            // Price - Display actual data if available
            Group {
                if let latestData = item.data7Day?.list.first {
                    priceDisplay(
                        price: ApiDecryptor.decrypt(latestData.sellDisplay),
                        percent: ApiDecryptor.decrypt(latestData.sellPercent),
                        delta: ApiDecryptor.decrypt(latestData.sellDelta)
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity
                    ))
                    .id("price-\(latestData.dateUpdate)") // Force refresh on data change
                } else {
                    // Loading placeholder
                    priceLoadingPlaceholder()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: item.data7Day != nil)
        }
        .padding(.horizontal, 10)
        .background(
            Group {
                if isSelected {
                    Color.white.opacity(0.1)
                } else if justLoaded {
                    Color(hex: "7FDF9A").opacity(0.15)
                } else {
                    Color.clear
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onChange(of: item.data7Day != nil) { hasData in
            if hasData && !justLoaded {
                // Trigger brief highlight animation when data loads
                withAnimation(.easeInOut(duration: 0.4)) {
                    justLoaded = true
                }

                // Remove highlight after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        justLoaded = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func priceDisplay(price: String, percent: String, delta: String) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(price)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            // Determine if price went up or down
            let isPositive = !delta.hasPrefix("-") && delta != "0"
            let isNegative = delta.hasPrefix("-")

            HStack(spacing: 2) {
                if isPositive {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "7FDF9A"))
                } else if isNegative {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.red)
                }

                Text(percent)
                    .foregroundStyle(isPositive ? Color(hex: "7FDF9A") : (isNegative ? .red : .gray))
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private func priceLoadingPlaceholder() -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.15))
                .frame(width: 60, height: 12)
                .shimmer()

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.15))
                .frame(width: 45, height: 10)
                .shimmer()
        }
    }
}

// MARK: - Preloading Progress View
struct PreloadingProgressView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "7FDF9A")))
                    .scaleEffect(0.7)

                Text("Đang tải dữ liệu thị trường...")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "7FDF9A"))
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 2)

                    // Progress
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "7FDF9A"),
                                    Color(hex: "7FDF9A").opacity(0.7)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 2)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 2)
        }
        .background(Color.black.opacity(0.3))
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
