//
//  DashBoardView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI

struct DashBoardView: View {
    
    @StateObject private var viewModel = DashBoardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    // Vàng miếng SJC
                    
                    DashboardGoldView()
                    // Vàng nhẫn 9999
                    //
                    
                    //XAUUSD
                    WebEmbedView(url: URL(string: "https://giavang.pro/box.html?product=T0FOREE6WEFVVVNE&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)
                    
                    // Chênh lệch trong nước và thế giới
                    WebEmbedView(url: URL(string: "https://giavang.pro/diff.html?product=T0FOREE6WEFVVVNE&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)
                    
                    // Bạc thỏi phú quý 999
                    
                    // Phân tích kỹ thuật cho XAUUSD
                    WebEmbedView(url: URL(string: "https://giavang.pro/technical.html?product=T0FOREE6WEFVVVNE&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)
                    
                    // Bảng giá vàng miếng SJC
                    
                    
                    // Bảng giá vàng nhẫn 9999
                    
                    
                    // Tỷ giá USD của VCB
                    DashboardCurrencyView()
                    
                    // Biểu đồ vàng miếng SJC
                    // Biểu đồ vàng nhẫn 9999
                    
                    
                    
                    // BTCUSDT
                    WebEmbedView(url: URL(string: "https://giavang.pro/box.html?product=QklOQU5DRTpCVENVU0RU&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)

                    // USDVND
                    WebEmbedView(url: URL(string: "https://giavang.pro/box.html?product=RlhfSURDOlVTRFZORA==&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)
                    
                    // Tin tức mới nhất
                    DashboardNewsView()
                        .frame(maxHeight: 500)
                        .padding(.bottom, 40)
                }
            }.navigationTitle(Text("Home"))
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    DashBoardView()
}
