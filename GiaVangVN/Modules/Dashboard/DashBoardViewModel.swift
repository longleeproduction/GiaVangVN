//
//  DashBoardViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import AVFoundation
import Combine

class DashBoardViewModel: ObservableObject {
    
    @Published var isLoadingPriceSJC: Bool = false
    @Published var priceSJC: GoldPriceData?
    
    @Published var isLoadingPrice9999: Bool = false
    @Published var price9999: GoldPriceData?

    @Published var isLoadingPriceAg999: Bool = false
    @Published var priceAg999: GoldPriceData?

    
    // Danh sách giá vàng
    @Published var isLoadingListSJC: Bool = false
    @Published var listSJC: GoldListData?
    
    @Published var isLoadingList9999: Bool = false
    @Published var list9999: GoldListData?

    
    // Tỷ giá
    @Published var isLoadingCurrency: Bool = false
    @Published var currency: CurrencyPriceData?
    
    init() {
        getPriceSJC()
        getPrice999()
        getAg9999()
        
        #if !os(watchOS)
        getListPriceSJC()
        getListPrice999()
        #endif
        
        getCurrency();
    }
    
    
    func getPriceSJC() {
        Task {
            await MainActor.run {
                isLoadingPriceSJC = true
            }
            
            do {
                let request = GoldPriceRequest(
                    product: "Vàng miếng SJC",
                    city: "Hồ Chí Minh",
                    branch: GoldBranch.sjc.rawValue.uppercased()
                )
                let response = try await DashboardService.shared.fetchGoldPrice(request: request)
                
                if let data = response.data {
                    await MainActor.run {
                        priceSJC = data
                    }
                }
            } catch {
                print("ERROR ---> ....s")
                print(error)
            }
            
            await MainActor.run {
                isLoadingPriceSJC = false
            }
        }
    }
    
    func getPrice999() {
        Task {
            await MainActor.run {
                isLoadingPrice9999 = true
            }
            
            do {
                let request = GoldPriceRequest()
                let response = try await DashboardService.shared.fetchGoldPrice(request: request)
                
                if let data = response.data {
                    await MainActor.run {
                        price9999 = data
                    }
                }
            } catch {
                print("ERROR ---> ....s")
                print(error)
            }
            
            await MainActor.run {
                isLoadingPrice9999 = false
            }
        }
    }
    
    func getAg9999() {
        Task {
            await MainActor.run {
                isLoadingPriceAg999 = true
            }
            
            do {
                let request = GoldPriceRequest(
                    product: "Bạc thỏi Phú Quý 999",
                    city: "Hà Nội",
                    branch: GoldBranch.phuquy.rawValue.uppercased()
                )
                let response = try await DashboardService.shared.fetchGoldPrice(request: request)
                
                if let data = response.data {
                    await MainActor.run {
                        priceAg999 = data
                    }
                }
            } catch {
                print("ERROR ---> ....s")
                print(error)
            }
            
            await MainActor.run {
                isLoadingPriceAg999 = false
            }
        }
    }
    
    func getListPriceSJC() {
        Task {
            await MainActor.run {
                isLoadingListSJC = true
            }
            
            do {
                let request = GoldPriceRequest(
                    product: "Vàng miếng SJC",
                    city: "Hồ Chí Minh",
                    branch: GoldBranch.sjc.rawValue.uppercased()
                )
                let response = try await DashboardService.shared.fetchGoldList(request: request)

                if let data = response.data {
                    await MainActor.run {
                        listSJC = data
                    }
                }
            } catch {
                print("ERROR ---> ....s")
                print(error)
            }
            
            await MainActor.run {
                isLoadingListSJC = false
            }
        }
    }
    
    func getListPrice999() {
        Task {
            await MainActor.run {
                isLoadingList9999 = true
            }
            
            do {
                let request = GoldPriceRequest()
                let response = try await DashboardService.shared.fetchGoldList(request: request)
                
                if let data = response.data {
                    await MainActor.run {
                        list9999 = data
                    }
                }
            } catch {
                print("ERROR ---> ....s")
                print(error)
            }
            
            await MainActor.run {
                isLoadingList9999 = false
            }
        }
    }
    
    func getCurrency() {
        Task {
            await MainActor.run {
                isLoadingCurrency = true
            }
            
            do {
                let response = try await DashboardService.shared.fetchCurrencyPrice(request: CurrencyPriceRequest())
                
                if let data = response.data {
                    await MainActor.run {
                        currency = data
                    }
                }
            } catch {
                print("ERROR ---> ....s")
                print(error)
            }
            
            await MainActor.run {
                isLoadingCurrency = false
            }
        }
    }
    
}
