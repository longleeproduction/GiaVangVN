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
    
    @Published var isLoading: Bool = false
    
    @Published var vcb: CurrencyDailyData?
    @Published var bidv: CurrencyDailyData?
    
    @Published var vcbChart: CurrencyListData?
    @Published var bidvChart: CurrencyListData?
    
    init() {
    }
    
    func refreshData() {
        isLoading = true
        Task {
            await getDailyCurrency(type: .vcb)
            await getDailyCurrency(type: .bidv)
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func getDailyCurrency(type: CurrencyType) async {
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
    
    func getChartCurrency(type: CurrencyType) async {
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

class CurrencyDetailViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var currencyList: CurrencyListData?
    
    @Published var range: ListRange = .Range7d
    
    func getListCurrency(code: String, branch: String) {
        isLoading = true
        Task {
            do {
                let request = CurrencyListRequest(code: code, branch: branch, range: range.rawValue)
                let response = try await CurrencyService.shared.fetchCurrencyList(request: request)

                if let data = response.data {
                    await MainActor.run {
                        currencyList = data
                    }
                }
                
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                debugPrint("ERROR ---> CurrencyViewModel")
                debugPrint(error)
                
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    

}
