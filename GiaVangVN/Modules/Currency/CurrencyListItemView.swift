//
//  CurrencyListItemView.swift
//  GiaVangVN
//
//  Created by ORL on 20/10/25.
//


import SwiftUI

struct CurrencyListItemView: View {
    
    var data: CurrencyDailyData
    
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
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            
            Divider()

            HStack(spacing: 8) {
                Text("Ngoại tệ")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Text("Mua vào")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()

                Text("Bán ra")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()

                Text("Chuyển khoản")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(data.list) { item in
                        CurrencyItemRow(item: item)
                        
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
