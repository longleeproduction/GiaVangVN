//
//  GoldCalculatorView.swift
//  GiaVangVN
//
//  Created by ORL on 22/10/25.
//


import SwiftUI

// MARK: - Main Calculator View
struct GoldCalculatorView: View {
    @StateObject private var viewModel = GoldCalculatorViewModel()
    @StateObject private var priceManager = GoldPriceManager.shared
    @State private var showingWeightConversion = false
    @State private var showingProductPicker = false
    @State private var showingAddTransaction = false
    @State private var isPresentedSetting: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Gold Product Selector
                    goldProductSelector

                    // Weight Input Section
                    weightInputSection

                    // Quick Weight Buttons
                    quickWeightButtons

                    // Total Price Display
                    totalPriceDisplay

                    // Add to Wallet Button
                    addToWalletButton

                    // Price Breakdown
                    priceBreakdownSection

                    // Conversion
                    WeightConversionView(viewModel: viewModel)
                        .padding(.bottom, 40)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        AppHeaderView(title: "Chuyển đổi")
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresentedSetting.toggle()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }

                }
                .fullScreenCover(isPresented: $isPresentedSetting) {
                    SettingView()
                }
                .sheet(isPresented: $showingWeightConversion) {
                    WeightConversionView(viewModel: viewModel)
                }
                .sheet(isPresented: $showingProductPicker) {
                    productPickerSheet
                }
                .sheet(isPresented: $showingAddTransaction) {
                    AddBuyTransactionView(
                        initialProduct: viewModel.selectedGoldProduct,
                        initialQuantity: viewModel.weightInChi,
                        initialUnitPrice: priceManager.getPrice(for: viewModel.selectedGoldProduct)
                    )
                }
                .task {
                    AdsManager.shared().showInterstitialAd()
                    
                    // Fetch prices if not available
                    if !priceManager.hasPrices {
                        await priceManager.fetchAllPrices()
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
        }
    }
    
    var goldProductSelector: some View {
        Button(action: {
            showingProductPicker = true
        }) {
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.selectedGoldProduct.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    HStack(spacing: 4) {
                        Text(viewModel.selectedGoldProduct.city)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.selectedGoldProduct.branch.uppercased())
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                if priceManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding()
        }
    }

    var productPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(GoldBuyerProduct.allCases, id: \.self) { product in
                    Button(action: {
                        viewModel.selectedGoldProduct = product
                        showingProductPicker = false
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.rawValue)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                HStack(spacing: 4) {
                                    Text(product.city)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(product.branch.uppercased())
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }

                            Spacer()

                            if viewModel.selectedGoldProduct == product {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chọn sản phẩm vàng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        showingProductPicker = false
                    }
                }
            }
        }
    }
    
    var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trọng lượng")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                TextField("1", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 30, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 80)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                
                Button(action: {
                    showingWeightConversion = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: viewModel.selectedUnit.icon)
                            .font(.title2)
                            .foregroundColor(viewModel.selectedUnit.color)
                        Text(viewModel.selectedUnit.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(viewModel.selectedUnit.displayName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 100, height: 80)
                    .background(viewModel.selectedUnit.color.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.selectedUnit.color, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    var quickWeightButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chọn nhanh trọng lượng")
                .font(.body)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(viewModel.quickWeights, id: \.self) { weight in
                    Button(action: {
                        viewModel.weight = String(weight)
                    }) {
                        VStack(spacing: 2) {
                            Text("\(weight)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text(viewModel.selectedUnit.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var totalPriceDisplay: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Tổng giá trị")
                    .font(.headline)
                    .foregroundColor(.gray)

                Spacer()

                Text("VND")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }

            if priceManager.isLoading {
                ProgressView()
                    .padding()
            } else if priceManager.hasPrices {
                Text(viewModel.formattedPrice)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.orange)

                Text("\(viewModel.selectedGoldProduct.rawValue) • \(String(format: "%.2f", viewModel.weightInGrams)) g")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 8) {
                    Text("Không có dữ liệu giá")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Tải lại") {
                        Task {
                            await priceManager.refreshPrices()
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding()
    }
    
    var priceBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chi tiết giá")
                .font(.headline)
                .padding(.horizontal)

            if priceManager.hasPrices {
                HStack {
                    Text("Giá mỗi gram:")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Spacer()
                    Text(viewModel.formattedPricePerGram)
                        .font(.caption)
                        .padding(.horizontal)
                }

                HStack {
                    Text("Khối lượng (gram):")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Spacer()
                    Text(String(format: "%.2f g", viewModel.weightInGrams))
                        .font(.caption)
                        .padding(.horizontal)
                }

                Divider()

                HStack {
                    Text("Tổng cộng:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    Spacer()
                    Text(viewModel.formattedPrice)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                }
            }
        }.padding()
    }

    var addToWalletButton: some View {
        Button(action: {
            showingAddTransaction = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Thêm vào Ví Vàng")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(!priceManager.hasPrices || viewModel.weightInChi <= 0)
        .opacity((!priceManager.hasPrices || viewModel.weightInChi <= 0) ? 0.5 : 1.0)
        .padding(.horizontal)
    }
}

#Preview {
    GoldCalculatorView()
}
