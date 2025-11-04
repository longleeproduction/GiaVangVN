//
//  AddBuyTransactionView.swift
//  GiaVangVN
//
//  Created by ORL on 23/10/25.
//

import SwiftUI

struct AddBuyTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var walletManager = WalletManager.shared
    @StateObject private var priceManager = GoldPriceManager.shared

    // Optional initial values
    var initialProduct: GoldBuyerProduct?
    var initialQuantity: Double?
    var initialUnitPrice: Double?

    @State private var selectedProduct: GoldBuyerProduct = .VangMiengSJC
    @State private var quantity: String = ""
    @State private var unitPrice: String = ""
    @State private var transactionDate: Date = Date()
    @State private var notes: String = ""

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                // Product Selection
                Section("Chọn sản phẩm vàng") {
                    Picker("Sản phẩm", selection: $selectedProduct) {
                        ForEach(GoldBuyerProduct.allCases, id: \.self) { product in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.rawValue)
                                    .font(.body)
                                HStack {
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
                            .tag(product)
                        }
                    }
                }

                // Transaction Details
                Section("Chi tiết giao dịch") {
                    HStack {
                        Text("Số lượng (chỉ)")
                        Spacer()
                        TextField("0.0", text: $quantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Giá mua (VNĐ/chỉ)")
                            Spacer()
                            TextField("0", text: $unitPrice)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }

                        if let suggestedPrice = priceManager.getSellDisplayPrice(for: selectedProduct) {
                            HStack {
                                Spacer()
                                Button {
                                    unitPrice = suggestedPrice
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.caption)
                                        Text("Giá hiện tại: \(suggestedPrice) VNĐ")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        } else if priceManager.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Đang tải giá...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    DatePicker("Ngày giao dịch", selection: $transactionDate, displayedComponents: .date)
                }

                // Notes
                Section("Ghi chú") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }

                // Total Amount
                if let qty = Double(quantity), let price = Double(unitPrice) {
                    Section("Tổng tiền") {
                        HStack {
                            Text("Thành tiền")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(formatCurrency(qty * price))
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Thêm giao dịch mua")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        saveBuyTransaction()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Thông báo", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .task {
                // Fetch prices if not available
                if !priceManager.hasPrices {
                    await priceManager.fetchAllPrices()
                }
            }
            .onAppear {
                // Set initial values if provided
                if let product = initialProduct {
                    selectedProduct = product
                }
                if let qty = initialQuantity {
                    quantity = String(format: "%.2f", qty)
                }
                if let price = initialUnitPrice {
                    unitPrice = String(format: "%.0f", price)
                }
            }
        }
    }

    private func saveBuyTransaction() {
        // Validation
        guard let qty = Double(quantity), qty > 0 else {
            alertMessage = "Vui lòng nhập số lượng hợp lệ"
            showAlert = true
            return
        }

        guard let price = Double(unitPrice), price > 0 else {
            alertMessage = "Vui lòng nhập giá mua hợp lệ"
            showAlert = true
            return
        }

        // Save transaction
        walletManager.addBuyTransaction(
            goldProduct: selectedProduct,
            quantity: qty,
            unitPrice: price,
            transactionDate: transactionDate,
            notes: notes.isEmpty ? nil : notes
        )

        dismiss()
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + " VNĐ"
    }
}

#Preview {
    AddBuyTransactionView()
}
