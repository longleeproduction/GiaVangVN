//
//  CurrencyViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import Combine

enum CurrencyType: String, CaseIterable {
    case vcb = "vcb"
    case bidv = "bidv"
}

class CurrencyViewModel: ObservableObject {
    
    @Published var vcb: CurrencyDailyData?
    @Published var bidv: CurrencyDailyData?
    
    @Published var vcbChart: CurrencyListData?
    @Published var bidvChart: CurrencyListData?
    
    init() {
        getDailyCurrency(type: .vcb)
        
        getChartCurrency(type: .vcb)
    }
    
    func getDailyCurrency(type: CurrencyType) {
        Task {
            do {
                let response = try await CurrencyService.shared.fetchCurrencyDaily(request: CurrencyDailyRequest(branch: type.rawValue))

                if let data = response.data {
                    await MainActor.run {
                        if type == .vcb {
                            vcb = data
                        }
                        
                        if type == .bidv {
                            bidv = data
                        }
                    }
                }
                
            } catch {
                debugPrint("ERROR ---> CurrencyViewModel")
                debugPrint(error)
            }
        }
    }
    
    func getChartCurrency(type: CurrencyType) {
        Task {
            do {
                let response = try await CurrencyService.shared.fetchCurrencyList(request: CurrencyListRequest(branch: type.rawValue, range: 60))

                if let data = response.data {
                    debugPrint("Get data chart currency successfully: \(data.list.count) items")
                    await MainActor.run {
                        if type == .vcb {
                            vcbChart = data
                        }
                        
                        if type == .bidv {
                            bidvChart = data
                        }
                    }
                }
                
            } catch {
                debugPrint("ERROR ---> CurrencyViewModel")
                debugPrint(error)
            }
        }
    }
}
