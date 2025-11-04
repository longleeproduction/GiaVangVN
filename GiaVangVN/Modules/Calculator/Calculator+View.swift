//
//  Calculator+View.swift
//  GiaVangVN
//
//  Created by ORL on 22/10/25.
//

import SwiftUI

struct ConversionCard: View {
    let value: String
    let unit: String
    let unitName: String
    let color: Color
    let isFrom: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            if isFrom {
                Text("FROM")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(color)
                    .cornerRadius(6)
            }
            
            Image(systemName: "scalemass")
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(color)
            
            Text(unitName)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(width: 140, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFrom ? color : Color.clear, lineWidth: 2)
                )
        )
    }
}

struct WeightUnitRow: View {
    let unit: WeightUnit
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: unit.icon)
                    .font(.title2)
                    .foregroundColor(unit.color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(unit.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(unit.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(unit.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            }
            .padding()
            .background(isSelected ? unit.color.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

