//
//  WeightConversionView.swift
//  GiaVangVN
//
//  Created by ORL on 22/10/25.
//



import SwiftUI

// MARK: - Weight Conversion View
struct WeightConversionView: View {
    
    @ObservedObject var viewModel: GoldCalculatorViewModel
    
    @State private var fromValue: Double = 1.0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Conversion Cards
            conversionCards
            
            // Popular Weight Units List
            popularWeightUnits
        }
    }
    
    var conversionCards: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Chuyển đổi trọng lượng")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Chọn đơn vị chuyển đổi")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // From Card
                    ConversionCard(
                        value: String(format: "%.2f", fromValue),
                        unit: viewModel.selectedUnit.rawValue,
                        unitName: viewModel.selectedUnit.displayName,
                        color: viewModel.selectedUnit.color,
                        isFrom: true
                    )
                    
                    // To Cards
                    ForEach(WeightUnit.allCases.filter { $0 != viewModel.selectedUnit }, id: \.self) { unit in
                        let convertedValue = unit.fromGrams(viewModel.selectedUnit.toGrams(fromValue))
                        ConversionCard(
                            value: String(format: "%.3f", convertedValue),
                            unit: unit.rawValue,
                            unitName: unit.displayName,
                            color: unit.color,
                            isFrom: false
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    var popularWeightUnits: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Đơn vị trọng lượng phổ biến")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    WeightUnitRow(
                        unit: unit,
                        isSelected: viewModel.selectedUnit == unit,
                        onTap: {
                            viewModel.selectedUnit = unit
                            // Convert the current value to the new unit
                            let grams = viewModel.selectedUnit.toGrams(Double(viewModel.weight) ?? 1)
                            fromValue = unit.fromGrams(grams)
                        }
                    )
                }
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}
