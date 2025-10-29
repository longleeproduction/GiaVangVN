//
//  CurrencyListItemView.swift
//  GiaVangVN
//
//  Created by ORL on 20/10/25.
//


import SwiftUI

struct CurrencyListItemView: View {
    
    var data: CurrencyDailyData
    var currencyType: CurrencyType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Cập nhật: \(data.lastUpdate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Đơn vị: \(data.unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Text("Ngoại tệ")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Mua vào")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .trailing)

                Text("Bán ra")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .trailing)

                Text("Mua CK")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(data.list) { item in
                        NavigationLink {
                            CurrencyDetailView(item: item, currencyType: currencyType)
                        } label: {
                            CurrencyItemRow(item: item)
                        }.buttonStyle(.plain)

                        if item.id != data.list.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
    }
}
