//
//  GoldBranchPageView.swift
//  GiaVangVN
//
//  Created by ORL on 30/10/25.
//

import SwiftUI
import Combine

class GoldBranchPageViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var dailyGold: GoldDailyData?
    @Published var error: String?


    func getDailyGold(branch: GoldBranch) {
        if dailyGold != nil && !isLoading { return }

        isLoading = true
        error = nil

        Task {
            do {
                let response = try await GoldService.shared.fetchGoldDaily(request: GoldDailyRequest(branch: branch.rawValue))

                if let data = response.data {
                    await MainActor.run {
                        dailyGold = data
                        error = nil
                    }
                }
            } catch {
                debugPrint("ERROR ---> GoldBranchPageViewModel")
                debugPrint(error)

                await MainActor.run {
                    self.error = error.localizedDescription
                }
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }

}

struct GoldBranchPageView: View {
    let branch: GoldBranch

    @StateObject private var viewModel = GoldBranchPageViewModel()

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ActivityIndicatorView()
            } else if let error = viewModel.error {
                buildErrorView(error: error)
            } else if let data = viewModel.dailyGold {
                buildGoldList(data: data)
            } else {
                buildEmptyState()
            }
        }
        .onAppear {
            viewModel.getDailyGold(branch: branch)
        }
    }

    @ViewBuilder
    private func buildGoldList(data: GoldDailyData) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Branch logo
                        if let logoName = getLogoName(for: branch) {
                            Image(logoName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                        }

                        Text(branch.title)
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
                VStack(spacing: 0) {
                    ForEach(data.cities) { city in
                        Section {
                            ForEach(city.list) { item in
                                NavigationLink {
                                    GoldDetailView(goldProductName: item.name, branch: branch, city: city.city)
                                } label: {
                                    GoldItemRow(item: item)
                                }.buttonStyle(.plain)

                                if item.id != city.list.last?.id {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        } header: {
                            HStack {
                                Text(city.city)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.tertiarySystemBackground))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu giá vàng")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                viewModel.getDailyGold(branch: branch)
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
    private func buildErrorView(error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("Đã xảy ra lỗi")
                .font(.headline)
                .foregroundColor(.primary)

            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                viewModel.getDailyGold(branch: branch)
            } label: {
                Label("Thử lại", systemImage: "arrow.clockwise")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func getLogoName(for branch: GoldBranch) -> String? {
        // Return logo asset name if available in Assets
        return branch.rawValue
    }
}
