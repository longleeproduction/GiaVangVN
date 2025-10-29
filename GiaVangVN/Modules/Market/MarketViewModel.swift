//
//  MarketViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import Combine

class MarketViewModel: ObservableObject {
    
    enum MarketTab {
        case Gold
        case Currency
    }
    
    
    @Published var selectedTab: MarketTab = .Gold
    
    @Published var currentGoldBranch: GoldBranch = .sjc
    
    func getListGoldBranch() {
        Task {
            
        }
    }
}
