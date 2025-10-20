//
//  DashboardCurrencyView.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import SwiftUI

struct DashboardCurrencyView: View {
    
    @EnvironmentObject private var viewModel: DashBoardViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isLoadingCurrency {
                ProgressView()
                    .frame(height: 100)
            } else {
                if let model = viewModel.currency {
                    Text(model.title)
                        .font(.title)
                    
                    Text(ApiDecryptor.decrypt(model.dateUpdate))
                        .font(.callout)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Bán ra")
                            Text("Giá ngân hàng bán ra mỗi ngoại tệ(đ)")
                                .font(.caption2)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            Text(ApiDecryptor.decrypt(model.sellDisplay))
                                .font(.title2)
                            Text(ApiDecryptor.decrypt(model.sellDelta))
                            Text(ApiDecryptor.decrypt(model.sellPercent))
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Mua chuyển khoản")
                            Text("Giá ngân hàng mua vào qua chuyển khoản(đ)")
                                .font(.caption2)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            Text(ApiDecryptor.decrypt(model.transferDisplay))
                                .font(.title2)
                            Text(ApiDecryptor.decrypt(model.transferDelta))
                            Text(ApiDecryptor.decrypt(model.transferPercent))
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Mua vào")
                            Text("Giá ngân hàng mua vào tiền mặt(đ)")
                                .font(.caption2)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            Text(ApiDecryptor.decrypt(model.buyDisplay))
                                .font(.title2)
                            Text(ApiDecryptor.decrypt(model.buyDelta))
                            Text(ApiDecryptor.decrypt(model.buyPercent))
                        }
                    }
                    
                } else {
                    Button {
                        viewModel.getCurrency()
                    } label: {
                        Label("Refresh", systemImage: "arrow.2.circlepath.circle")
                    }

                }
            }
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    DashboardCurrencyView()
}
