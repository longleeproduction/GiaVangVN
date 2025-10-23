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

    @State private var selectedProduct: GoldBuyerProduct = .VangMiengSJC
    @State private var quantity: String = ""
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
                    .onChange(of: selectedProduct) { _ in
                        fetchSuggestedPrice()
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
                    product: selectedProduct.rawValue,
                    city: selectedProduct.city,
                    lang: "vi",
                    branch: selectedProduct.branch
                )
                let response = try await DashboardService.shared.fetchGoldPrice(request: request)

                if let data = response.data {
                    await MainActor.run {
                        suggestedPrice = ApiDecryptor.decrypt(data.sellDisplay).replacingOccurrences(of: ",", with: "")
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
