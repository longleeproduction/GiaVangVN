//
//  CurrencyView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI

enum CurrencyViewMode: String, CaseIterable {
    case list = "Danh sách"
    case chart = "Biểu đồ"
}

struct CurrencyView: View {

    @StateObject private var viewModel = CurrencyViewModel()
    @State private var selectedMode: CurrencyViewMode = .list

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment Control
                Picker("View Mode", selection: $selectedMode) {
                    ForEach(CurrencyViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Divider()

                // Content based on selected mode
                if selectedMode == .list {
                    if let vcbData = viewModel.vcb {
                        buildCurrencyList(data: vcbData)
                    } else {
                        buildEmptyState()
                    }
                } else {
                    if let chartData = viewModel.vcbChart {
                        ScrollView {
                            CurrencyChartView(data: chartData)
                                .padding(.top, 16)
                        }
                    } else {
                        buildChartEmptyState()
                    }
                }
            }
            .navigationTitle(Text("Currency"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if selectedMode == .list {
                            Task {
                                await viewModel.getDailyCurrency(type: .vcb)
                            }
                        } else {
                            Task {
                                await viewModel.getChartCurrency(type: .vcb)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .environmentObject(viewModel)
        }
    }

    @ViewBuilder
    private func buildCurrencyList(data: CurrencyDailyData) -> some View {
        CurrencyListItemView(data: data)
    }

    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu tỷ giá")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                Task {
                    await viewModel.getDailyCurrency(type: .vcb)
                }
            } label: {
                Label("Làm mới", systemImage: "arrow.clockwise")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func buildChartEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu biểu đồ")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                Task {
                    await
                    viewModel.getChartCurrency(type: .vcb)
                }
            } label: {
                Label("Làm mới", systemImage: "arrow.clockwise")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CurrencyView()
}
