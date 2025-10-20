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
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "banknote")
                        .foregroundColor(.blue)
                    
                    Text("VCB - Vietcombank")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Cập nhật: \(data.lastUpdate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Đơn vị: \(data.unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
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
