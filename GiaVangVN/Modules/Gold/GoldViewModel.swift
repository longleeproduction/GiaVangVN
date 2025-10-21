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
    
    var title: String {
        switch self {
        case .sjc: return "SJC"
        case .pnj: return "PNJ"
        case .doji: return "DOJI"
        case .btmc: return "Bảo Tín Minh Châu"
        case .mihong: return "Mi Hồng"
        case .btmh: return "Bảo Tín Mạnh Hải"
        case .phuquy: return "Phú Qúy"
        case .ngoctham: return "Ngọc Thẩm"
            
        }
    }
}

class GoldViewModel: ObservableObject {
    
    @Published var sjc: GoldDailyData?
    
    @Published var sjcChart: GoldListData?
    @Published var dojiChart: GoldListData?
    
    
    @Published var currentBranch: GoldBranch = .sjc
    
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



class GoldDetailViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var goldData: GoldListData?
    
    @Published var range: ListRange = .Range7d
    
    func getGoldDetail(product: String, branch: GoldBranch, city: String) {
        
        isLoading = true
        Task {
            do {
                let request = GoldListRequest(city: city, product: product, branch: branch.rawValue, range: self.range.rawValue)
                let response = try await GoldService.shared.fetchGoldListByRange(request: request)
                
                if let data = response.data {
                    await MainActor.run {
                        goldData = data
                    }
                }
                
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                debugPrint("ERROR ---> GoldViewModel")
                debugPrint(error)
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
