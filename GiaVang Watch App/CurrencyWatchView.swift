//
//  CurrencyWatchView.swift
//  GiaVang Watch App
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

struct CurrencyWatchView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)

                    Text("Tỷ Giá")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)

                Divider()

                // Currency Rates
                VStack(spacing: 8) {
                    CurrencyRateCard(
                        code: "USD",
                        name: "US Dollar",
                        buyRate: "25,450",
                        sellRate: "25,500",
                        change: "+0.1%"
                    )

                    CurrencyRateCard(
                        code: "EUR",
                        name: "Euro",
                        buyRate: "27,800",
                        sellRate: "27,900",
                        change: "+0.2%"
                    )

                    CurrencyRateCard(
                        code: "JPY",
                        name: "Yen",
                        buyRate: "165",
                        sellRate: "168",
                        change: "-0.3%"
                    )

                    CurrencyRateCard(
                        code: "GBP",
                        name: "Pound",
                        buyRate: "32,100",
                        sellRate: "32,300",
                        change: "+0.4%"
                    )
                }
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 8)
        }
    }
}

struct CurrencyRateCard: View {
    let code: String
    let name: String
    let buyRate: String
    let sellRate: String
    let change: String

    var changeColor: Color {
        if change.hasPrefix("+") {
            return .green
        } else if change.hasPrefix("-") {
            return .red
        } else {
            return .secondary
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 4) {
                        Text(code)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text(name)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(change)
                        .font(.caption2)
                        .foregroundColor(changeColor)
                }
                
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mua")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                        
                        Text(buyRate)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bán")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                        
                        Text(sellRate)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(8)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

#Preview {
    CurrencyWatchView()
}
