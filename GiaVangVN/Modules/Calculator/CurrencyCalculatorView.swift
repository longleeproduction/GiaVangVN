//
//  CurrencyCalculatorView.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 22/10/25.
//

import SwiftUI

// MARK: - Main Currency Calculator View
struct CurrencyCalculatorView: View {
    @StateObject private var viewModel = CurrencyCalculatorViewModel()
    @State private var showingFromCurrencyPicker = false
    @State private var showingToCurrencyPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Currency Pair Selector
                currencyPairSelector

                // Amount Input Section
                amountInputSection

                // Quick Amount Buttons
                quickAmountButtons

                // Converted Amount Display
                convertedAmountDisplay

                // Exchange Rate Breakdown
                exchangeRateBreakdown

                // Popular Currency Pairs
                popularCurrencyPairs
            }
            .padding()
            .background(Color(UIColor.systemGray6))
        }
        .navigationTitle("Currency Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFromCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $viewModel.fromCurrency, onSelect: {
                showingFromCurrencyPicker = false
                viewModel.updateExchangeRate()
            })
        }
        .sheet(isPresented: $showingToCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $viewModel.toCurrency, onSelect: {
                showingToCurrencyPicker = false
                viewModel.updateExchangeRate()
            })
        }
    }

    var currencyPairSelector: some View {
        HStack(spacing: 12) {
            // From Currency
            Button(action: {
                showingFromCurrencyPicker = true
            }) {
                CurrencyButton(currency: viewModel.fromCurrency, label: "FROM")
            }

            // Swap Button
            Button(action: {
                withAnimation {
                    viewModel.swapCurrencies()
                }
            }) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }

            // To Currency
            Button(action: {
                showingToCurrencyPicker = true
            }) {
                CurrencyButton(currency: viewModel.toCurrency, label: "TO")
            }
        }
    }

    var amountInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                Text(viewModel.fromCurrency.symbol)
                    .font(.title)
                    .foregroundColor(.gray)
                    .frame(width: 40)

                TextField("1", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 32, weight: .medium))
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    var quickAmountButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Amounts")
                .font(.title3)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(viewModel.quickAmounts, id: \.self) { amount in
                    Button(action: {
                        viewModel.amount = String(amount)
                    }) {
                        VStack(spacing: 4) {
                            Text("\(amount)")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text(viewModel.fromCurrency.code)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }

    var convertedAmountDisplay: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Converted Amount")
                    .font(.headline)
                    .foregroundColor(.gray)

                Spacer()

                Text(viewModel.toCurrency.code)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(viewModel.toCurrency.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.green)

                Text(viewModel.formattedConvertedAmount)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }

            Text("\(viewModel.fromCurrency.flag) \(viewModel.formattedAmount) \(viewModel.fromCurrency.code) = \(viewModel.toCurrency.flag) \(viewModel.formattedConvertedAmount) \(viewModel.toCurrency.code)")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }

    var exchangeRateBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exchange Rate")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Text("1 \(viewModel.fromCurrency.code)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(viewModel.formattedExchangeRate) \(viewModel.toCurrency.code)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Divider()

                HStack {
                    Text("\(viewModel.formattedAmount) \(viewModel.fromCurrency.code)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(viewModel.formattedConvertedAmount) \(viewModel.toCurrency.code)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Exchange rate:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("1 \(viewModel.fromCurrency.code) = \(viewModel.formattedExchangeRate) \(viewModel.toCurrency.code)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    var popularCurrencyPairs: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Pairs")
                .font(.headline)

            VStack(spacing: 8) {
                CurrencyPairRow(from: .usd, to: .vnd) {
                    viewModel.fromCurrency = .usd
                    viewModel.toCurrency = .vnd
                    viewModel.updateExchangeRate()
                }

                CurrencyPairRow(from: .eur, to: .vnd) {
                    viewModel.fromCurrency = .eur
                    viewModel.toCurrency = .vnd
                    viewModel.updateExchangeRate()
                }

                CurrencyPairRow(from: .jpy, to: .vnd) {
                    viewModel.fromCurrency = .jpy
                    viewModel.toCurrency = .vnd
                    viewModel.updateExchangeRate()
                }

                CurrencyPairRow(from: .gbp, to: .vnd) {
                    viewModel.fromCurrency = .gbp
                    viewModel.toCurrency = .vnd
                    viewModel.updateExchangeRate()
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Currency Button Component
struct CurrencyButton: View {
    let currency: Currency
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)

            Text(currency.flag)
                .font(.system(size: 40))

            Text(currency.code)
                .font(.headline)
                .fontWeight(.semibold)

            Text(currency.name)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Currency Pair Row Component
struct CurrencyPairRow: View {
    let from: Currency
    let to: Currency
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(from.flag)
                    .font(.title2)

                Text(from.code)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(to.flag)
                    .font(.title2)

                Text(to.code)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Currency Picker View
struct CurrencyPickerView: View {
    @Binding var selectedCurrency: Currency
    let onSelect: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(Currency.allCurrencies) { currency in
                    Button(action: {
                        selectedCurrency = currency
                        onSelect()
                        dismiss()
                    }) {
                        HStack {
                            Text(currency.flag)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.code)
                                    .font(.headline)
                                Text(currency.name)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            if currency == selectedCurrency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CurrencyCalculatorView()
    }
}
