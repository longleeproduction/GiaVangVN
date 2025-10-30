//
//  GoldDetailView.swift
//  GiaVangVN
//
//  Created by ORL on 30/10/25.
//

import SwiftUI

struct GoldDetailView: View {
    var goldProductName: String
    var branch: GoldBranch
    var city: String

    @StateObject private var viewModel: GoldDetailViewModel = GoldDetailViewModel()

    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                VStack {
                    
                }
            } else {
                buildResult()
            }
        }.onAppear {
            viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
        }
    }
    
    @ViewBuilder
    func buildResult() -> some View {
        ScrollView {
            VStack {
                // Day Range
                HStack {
                    ForEach(ListRange.allCases, id: \.self) { item in
                        Button {
                            viewModel.range = item
                            viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
                        } label: {
                            Text(item.title)
                        }
                    }
                }
                // Chart
                if let data = viewModel.goldData {
                    GoldChartView(data: data)
                }
                
                // Build list
            }
        }
    }
}
