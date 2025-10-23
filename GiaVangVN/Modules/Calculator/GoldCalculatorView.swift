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
    @State private var showingWeightConversion = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gold Type Selector
                goldTypeSelector
                
                // Weight Input Section
                weightInputSection
                
                // Quick Weight Buttons
                quickWeightButtons
                
                // Total Price Display
                totalPriceDisplay
                
                // Price Breakdown
                priceBreakdownSection
                
                // Conversion
                WeightConversionView(viewModel: viewModel)
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Gold Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingWeightConversion) {
                WeightConversionView(viewModel: viewModel)
            }
        }
    }
    
    var goldTypeSelector: some View {
        HStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.selectedGoldType.name)
                    .font(.headline)
                Text("\(viewModel.selectedGoldType.karat) • \(viewModel.selectedGoldType.purity) pure")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding()
    }
    
    var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                TextField("1", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
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
            Text("Quick Weights")
                .font(.title3)
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
                Text("Total Price")
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
            
            Text(viewModel.formattedPrice)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.orange)
            
            Text("\(viewModel.selectedGoldType.name) • \(String(format: "%.2f", viewModel.weightInGrams)) g")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("≈ \(String(format: "%.2f", viewModel.weightInGrams))g")
                .font(.caption)
                .foregroundColor(.gray)
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
            Text("Price Breakdown")
                .font(.headline)
                .padding(.horizontal)
            HStack {
                Text("Price pergam:")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                Spacer()
                Text("đ2,888,3234")
                    .font(.caption)
            }
            
            HStack {
                Text("Weight in grams:")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                Spacer()
                Text("31,104g")
                    .font(.caption)
            }
            
            Divider()
            
            HStack {
                Text("Total:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    
                Spacer()
                Text("đ122,888,3234")
                    .font(.caption)
            }
        }.padding()
    }
}

#Preview {
    GoldCalculatorView()
}
