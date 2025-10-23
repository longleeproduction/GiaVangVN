//
//  AddSellTransactionView.swift
//  GiaVangVN
//
//  Created by ORL on 23/10/25.
//

import SwiftUI

struct AddSellTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var walletManager = WalletManager.shared

    let buyTransaction: GoldTransactionModel

    @State private var quantityToSell: String = ""
    @State private var sellAll: Bool = false
    @State private var unitPrice: String = ""
    @State private var transactionDate: Date = Date()
    @State private var notes: String = ""

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @State private var isLoadingPrice: Bool = false
    @State private var suggestedPrice: String = ""

    var body: some View {
        NavigationStack {
            Form {
                // Buy Transaction Info
                Section("Thông tin giao dịch mua") {
                    HStack {
                        Text("Sản phẩm")
                        Spacer()
                        Text(buyTransaction.goldProduct.rawValue)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Thành phố")
                        Spacer()
                        Text(buyTransaction.goldProduct.city)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Chi nhánh")
                        Spacer()
                        Text(buyTransaction.goldProduct.branch.uppercased())
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Số lượng còn lại")
                        Spacer()
                        Text("\(formatNumber(buyTransaction.remainingQuantity)) chỉ")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Giá mua")
                        Spacer()
                        Text(formatCurrency(buyTransaction.unitPrice))
                            .foregroundColor(.secondary)
                    }
                }

                // Sell Transaction Details
                Section("Chi tiết bán") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Số lượng bán (chỉ)")
                            Spacer()
                            TextField("0.0", text: $quantityToSell)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .disabled(sellAll)
                        }

                        Toggle("Bán tất cả", isOn: $sellAll)
                            .onChange(of: sellAll) { newValue in
                                if newValue {
                                    quantityToSell = String(buyTransaction.remainingQuantity)
                                } else {
                                    quantityToSell = ""
                                }
                            }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Giá bán (VNĐ/chỉ)")
                            Spacer()
                            TextField("0", text: $unitPrice)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }

                        if !suggestedPrice.isEmpty {
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
                        }
                    }

                    DatePicker("Ngày bán", selection: $transactionDate, displayedComponents: .date)
                }

                // Notes
                Section("Ghi chú") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }

                // Profit/Loss Calculation
                if let qty = Double(quantityToSell), let sellPrice = Double(unitPrice), qty > 0 {
                    Section("Tính toán") {
                        HStack {
                            Text("Thành tiền")
                            Spacer()
                            Text(formatCurrency(qty * sellPrice))
                                .foregroundColor(.blue)
                        }

                        HStack {
                            Text("Vốn gốc")
                            Spacer()
                            Text(formatCurrency(qty * buyTransaction.unitPrice))
                                .foregroundColor(.secondary)
                        }

                        let profitLoss = (qty * sellPrice) - (qty * buyTransaction.unitPrice)
                        HStack {
                            Text("Lãi/Lỗ")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(formatCurrency(profitLoss))
                                .fontWeight(.bold)
                                .foregroundColor(profitLoss >= 0 ? .green : .red)
                        }

                        if profitLoss != 0 {
                            let profitPercent = (profitLoss / (qty * buyTransaction.unitPrice)) * 100
                            HStack {
                                Text("Tỷ suất lợi nhuận")
                                Spacer()
                                Text(String(format: "%.2f%%", profitPercent))
                                    .foregroundColor(profitLoss >= 0 ? .green : .red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bán vàng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Bán") {
                        saveSellTransaction()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Thông báo", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                fetchSuggestedPrice()
            }
        }
    }

    private func fetchSuggestedPrice() {
        isLoadingPrice = true
        suggestedPrice = ""

        Task {
            do {
                let request = GoldPriceRequest(
                    product: buyTransaction.goldProduct.rawValue,
                    city: buyTransaction.goldProduct.city,
                    lang: "vi",
                    branch: buyTransaction.goldProduct.branch
                )
                let response = try await DashboardService.shared.fetchGoldPrice(request: request)

                if let data = response.data {
                    await MainActor.run {
                        suggestedPrice = ApiDecryptor.decrypt(data.buyDisplay).replacingOccurrences(of: ",", with: "")
                        isLoadingPrice = false
                    }
                } else {
                    await MainActor.run {
                        isLoadingPrice = false
                    }
                }
            } catch {
                print("Error fetching suggested price: \(error)")
                await MainActor.run {
                    isLoadingPrice = false
                }
            }
        }
    }

    private func saveSellTransaction() {
        // Validation
        guard let qty = Double(quantityToSell), qty > 0 else {
            alertMessage = "Vui lòng nhập số lượng hợp lệ"
            showAlert = true
            return
        }

        guard qty <= buyTransaction.remainingQuantity else {
            alertMessage = "Số lượng bán vượt quá số lượng còn lại (\(formatNumber(buyTransaction.remainingQuantity)) chỉ)"
            showAlert = true
            return
        }

        guard let price = Double(unitPrice), price > 0 else {
            alertMessage = "Vui lòng nhập giá bán hợp lệ"
            showAlert = true
            return
        }

        // Save transaction
        let success = walletManager.addSellTransaction(
            buyTransaction: buyTransaction,
            quantityToSell: qty,
            unitPrice: price,
            transactionDate: transactionDate,
            notes: notes.isEmpty ? nil : notes
        )

        if success {
            dismiss()
        } else {
            alertMessage = "Không thể lưu giao dịch bán"
            showAlert = true
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + " VNĐ"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

#Preview {
    AddSellTransactionView(
        buyTransaction: GoldTransactionModel(
            id: UUID(),
            transactionType: .buy,
            goldProduct: .VangMiengSJC,
            quantity: 10,
            quantitySold: 0,
            unitPrice: 75000000,
            totalAmount: 750000000,
            transactionDate: Date(),
            createdAt: Date(),
            notes: nil,
            relatedBuyTransactionId: nil
        )
    )
}
