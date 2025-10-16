//
//  DashBoardViewModel.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 16/10/25.
//

import AVFoundation
import Combine

class DashBoardViewModel: ObservableObject {
    
    // Danh sách giá vàng
    @Published var isLoadingListSJC: Bool = false
    @Published var listSJC: GoldListData?
    
    // Tỷ giá
    @Published var isLoadingCurrency: Bool = false
    @Published var currency: CurrencyPriceData?
    
    init() {
        getPriceSJC()
        getPrice999()
        getAg9999()
        
        getListPriceSJC()
        getListPrice999()
        
        getCurrency();
    }
    
    
    func getPriceSJC() {
        
    }
    
    func getPrice999() {
        
    }
    
    func getAg9999() {
        
    }
    
    func getListPriceSJC() {
        Task {
            await MainActor.run {
                isLoadingListSJC = true
            }
            
            do {
                let response = try await DashboardService.shared.fetchGoldList(request: GoldPriceRequest())
                
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
