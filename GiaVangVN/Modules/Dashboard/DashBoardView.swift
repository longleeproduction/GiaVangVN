//
//  DashBoardView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI

struct DashBoardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    WebEmbedView(url: URL(string: "https://giavang.pro/box.html?product=T0FOREE6WEFVVVNE&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)
                    
                    WebEmbedView(url: URL(string: "https://giavang.pro/box.html?product=QklOQU5DRTpCVENVU0RU&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)
                    
                    WebEmbedView(url: URL(string: "https://giavang.pro/box.html?product=RlhfSURDOlVTRFZORA==&theme=light")!, isScrollEnabled: false)
                        .frame(height: 400)
                    
                }
            }.navigationTitle(Text("Home"))
        }
    }
}

#Preview {
    DashBoardView()
}
