//
//  MarketViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import Combine

class GoldMarket {
    var branch: GoldBranch
    var city: String
    var product: String
    
    var data7Day: GoldListData? = nil
    
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
    
    @Published var currentGoldBranch: GoldBranch = .sjc
    
    func getListGoldBranch() {
        Task {
            
        }
    }
}
