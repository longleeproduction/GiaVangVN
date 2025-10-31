//
//  MarketViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import Combine
import Foundation

class GoldMarketModel: Identifiable, Equatable {
    static func == (lhs: GoldMarketModel, rhs: GoldMarketModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String = UUID().uuidString
    
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
    
    @Published var currentGoldMarket: GoldMarketModel?
    
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
    }    
}
