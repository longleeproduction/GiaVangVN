//
//  GoldViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import Combine

enum GoldBranch: String, CaseIterable {
    case sjc = "sjc"
    case pnj = "pnj"
    case doji = "doji"
    case btmc = "btmc"
    case mihong = "mihong"
    case btmh = "btmh"
    case phuquy = "phuquy"
    case ngoctham = "ngoctham"
}

class GoldViewModel: ObservableObject {
    
    @Published var sjc: GoldDailyData?
    
    @Published var sjcChart: GoldListData?
    @Published var dojiChart: GoldListData?
    
    init() {
        getDailyGold(branch: .sjc)
        
        getChartGold(branch: .sjc)
    }
    
    func getDailyGold(branch: GoldBranch) {
        Task {
            do {
                let response = try await GoldService.shared.fetchGoldDaily(request: GoldDailyRequest(branch: branch.rawValue))

                if let data = response.data {
                    await MainActor.run {
                        if branch == .sjc {
                            sjc = data
                        }
                    }
                }
            } catch {
                debugPrint("ERROR ---> GoldViewModel")
                debugPrint(error)
            }
        }
    }
    
    
    //Note: current only support .sjc and .doji
    func getChartGold(branch: GoldBranch) {
        
        Task {
            var request: GoldListRequest = .init()
            if (branch == .sjc) {
                request = GoldListRequest(city: "Hồ Chí Minh", product: "Vàng miếng SJC", branch: branch.rawValue, range: 60)
            }
            if (branch == .doji) {
                request = GoldListRequest(city: "Bảng giá tại Hồ Chí Minh", product: "SJC - Bán Lẻ", branch: branch.rawValue, range: 60)
            }
            
            do {
                let response = try await GoldService.shared.fetchGoldListByRange(request: request)

                if let data = response.data {
                    await MainActor.run {
                        if branch == .sjc {
                            sjcChart = data
                        }
                        
                        if branch == .doji {
                            dojiChart = data
                        }
                    }
                }
            } catch {
                debugPrint("ERROR ---> GoldViewModel")
                debugPrint(error)
            }
        }
    }
}
