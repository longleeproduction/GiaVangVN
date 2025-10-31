//
//  MarketViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import Combine
import Foundation

class GoldMarketModel: Identifiable, Equatable, ObservableObject {
    static func == (lhs: GoldMarketModel, rhs: GoldMarketModel) -> Bool {
        return lhs.id == rhs.id
    }

    var id: String = UUID().uuidString

    var branch: GoldBranch
    var city: String
    var product: String

    @Published var data7Day: GoldListData? = nil

    init(branch: GoldBranch, city: String, product: String) {
        self.branch = branch
        self.city = city
        self.product = product
    }

}

class MarketViewModel: ObservableObject {

    enum MarketTab {
        case Gold
        case Currency
    }


    @Published var selectedTab: MarketTab = .Gold

    @Published var currentGoldMarket: GoldMarketModel?

    @Published var isPreloading: Bool = false
    @Published var preloadProgress: Double = 0.0

    // Hardcode list golds
    @Published var listGoldMarkets: [GoldMarketModel] = [
        GoldMarketModel(branch: .sjc, city: "Toàn quốc", product: "Vàng miếng SJC"),
        GoldMarketModel(branch: .sjc, city: "Toàn quốc", product: "Vàng nhẫn 9999 (99.99%)"),
        
        GoldMarketModel(branch: .pnj, city: "TPHCM", product: "PNJ"),
        GoldMarketModel(branch: .pnj, city: "TPHCM", product: "SJC"),
        
        GoldMarketModel(branch: .doji, city: "Bảng giá tại Hồ Chí Minh", product: "SJC - Bán Lẻ"),
        GoldMarketModel(branch: .doji, city: "Bảng giá tại Hồ Chí Minh", product: "Nhẫn Tròn 9999 Hưng Thịnh Vượng - Bán Lẻ"),
        
        GoldMarketModel(branch: .btmc, city: "Hà Nội", product: "VÀNG MIẾNG VRTL BẢO TÍN MINH CHÂU"),
        GoldMarketModel(branch: .btmc, city: "Hà Nội", product: "VÀNG MIẾNG SJC"),
        GoldMarketModel(branch: .btmc, city: "Hà Nội", product: "NHẪN TRÒN TRƠN BẢO TÍN MINH CHÂU"),
        GoldMarketModel(branch: .btmc, city: "Hà Nội", product: "TRANG SỨC VÀNG RỒNG THĂNG LONG 999.9"),
        
        GoldMarketModel(branch: .mihong, city: "Hồ Chí Minh", product: "SJC"),
        GoldMarketModel(branch: .mihong, city: "Hồ Chí Minh", product: "999"),
        
        GoldMarketModel(branch: .btmh, city: "Hà Nội", product: "Vàng miếng SJC (Cty CP BTMH)"),
        GoldMarketModel(branch: .btmh, city: "Hà Nội", product: "Nhẫn ép vỉ Kim Gia Bảo"),
        GoldMarketModel(branch: .btmh, city: "Hà Nội", product: "Nhẫn ép vỉ Vàng Rồng Thăng Long"),
        
        GoldMarketModel(branch: .phuquy, city: "Hà Nội", product: "Vàng miếng SJC"),
        GoldMarketModel(branch: .phuquy, city: "Hà Nội", product: "Nhẫn tròn Phú Quý 999.9"),
        
        GoldMarketModel(branch: .ngoctham, city: "Mỹ Tho", product: "Vàng miếng SJC"),
        GoldMarketModel(branch: .ngoctham, city: "Mỹ Tho", product: "Nhẫn 999.9"),
    ]
    
    init() {
        currentGoldMarket = listGoldMarkets.first
        // Start preloading 7-day data for all markets
        preloadAllMarketData()
    }

    /// Preload 7-day data for all gold markets concurrently for high performance
    func preloadAllMarketData() {
        isPreloading = true
        preloadProgress = 0.0

        Task {
            let totalMarkets = listGoldMarkets.count

            // Use TaskGroup for concurrent fetching
            await withTaskGroup(of: (Int, GoldListData?).self) { group in
                // Launch concurrent tasks for each market
                for (index, market) in listGoldMarkets.enumerated() {
                    group.addTask {
                        do {
                            let request = await GoldListRequest(
                                city: market.city,
                                product: market.product,
                                branch: market.branch.rawValue,
                                range: ListRange.Range7d.rawValue  // 7-day data
                            )
                            let response = try await GoldService.shared.fetchGoldListByRange(request: request)
                            return (index, response.data)
                        } catch {
                            debugPrint("ERROR preloading market \(market.product) - \(market.branch.title): \(error)")
                            return (index, nil)
                        }
                    }
                }

                // Collect results as they complete
                var completedCount = 0
                for await (index, data) in group {
                    completedCount += 1

                    // Update the market data on main thread
                    await MainActor.run {
                        if index < listGoldMarkets.count {
                            listGoldMarkets[index].data7Day = data
                            // Manually trigger update to ensure UI refreshes
                            objectWillChange.send()
                        }
                        // Update progress
                        preloadProgress = Double(completedCount) / Double(totalMarkets)
                    }
                }
            }

            // Mark preloading as complete
            await MainActor.run {
                isPreloading = false
                preloadProgress = 1.0
                debugPrint("✅ Preloading completed for \(totalMarkets) markets")
            }
        }
    }

    /// Refresh data for a specific market
    func refreshMarket(_ market: GoldMarketModel) {
        Task {
            do {
                let request = GoldListRequest(
                    city: market.city,
                    product: market.product,
                    branch: market.branch.rawValue,
                    range: ListRange.Range7d.rawValue
                )
                let response = try await GoldService.shared.fetchGoldListByRange(request: request)

                await MainActor.run {
                    if let index = listGoldMarkets.firstIndex(where: { $0.id == market.id }) {
                        listGoldMarkets[index].data7Day = response.data
                        // Manually trigger update to ensure UI refreshes
                        objectWillChange.send()
                    }
                }
            } catch {
                debugPrint("ERROR refreshing market: \(error)")
            }
        }
    }
}
