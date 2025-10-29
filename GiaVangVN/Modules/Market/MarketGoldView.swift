//
//  MarketGoldView.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import SwiftUI

struct MarketGoldView: View {
    
    @EnvironmentObject private var viewModel : MarketViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {

            VStack {
            // Biểu đồ
                VStack {
                    Text("")
                }.frame(height: 400)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary)
            
            // List branch
            
                VStack(spacing: 8) {
                    ForEach(GoldBranch.allCases, id: \.self) { branch in
                        Button {
                            viewModel.currentGoldBranch = branch
//                            viewModel.getDailyGold(branch: branch)
                        } label: {
                            Text(branch.title)
                                .font(.caption2)
                                .fontWeight(viewModel.currentGoldBranch == branch ? .bold : .regular)
                                .foregroundColor(viewModel.currentGoldBranch == branch ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.currentGoldBranch == branch
                                    ? Color.orange
                                    : Color.gray.opacity(0.2)
                                )
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
