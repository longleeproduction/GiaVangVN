//
//  MarketCurrencyView.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import SwiftUI

struct MarketCurrencyView: View {
    
    @StateObject private var viewModel : CurrencyViewModel = CurrencyViewModel()
    
    @State private var isShowVCB: Bool = true
    
    var body: some View {
        VStack {
            if (viewModel.isLoading) {
                ProgressView()
                    .tint(Color.orange)
            } else {
                VStack {
                    // List Bank
                    HStack {
                        itemBranch(title: "Vietcombank", isSelected: isShowVCB) {
                            isShowVCB = true
                        }
                        
                        itemBranch(title: "BIDV", isSelected: !isShowVCB) {
                            isShowVCB = false
                        }
                        
                        Spacer()
                    }.padding(.bottom, 8)
                        .padding(.horizontal, 16)
                    
                    if isShowVCB && viewModel.vcb != nil {
                        CurrencyListItemView(data: viewModel.vcb!)
                    }
                    if !isShowVCB && viewModel.bidv != nil {
                        CurrencyListItemView(data: viewModel.bidv!)
                    }
                }
            }
        }.task {
            viewModel.refreshData()
        }
    }
    
    @ViewBuilder
    func itemBranch(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundStyle(isSelected ? .black : .white)
                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .background(isSelected ? Color.brown : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    Color.secondary,
                    lineWidth: isSelected ? 0 : 1
                )
        )
    }
}

#Preview {
    MarketCurrencyView()
}
