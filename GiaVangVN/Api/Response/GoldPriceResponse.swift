//
//  GoldPriceResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldPriceResponse: Codable {
    let success: Bool
    let data: GoldPriceData?

    struct GoldPriceData: Codable, Identifiable {
        let id: String
        let title: String
        let branch: String
        let city: String
        let product: String
        let dateUpdate: String
        let buyDisplay: String
        let buyDelta: String
        let buyPercent: String
        let sellDisplay: String
        let sellDelta: String
        let sellPercent: String

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case branch
            case city
            case product
            case dateUpdate = "date_update"
            case buyDisplay = "buy_display"
            case buyDelta = "buy_delta"
            case buyPercent = "buy_percent"
            case sellDisplay = "sell_display"
            case sellDelta = "sell_delta"
            case sellPercent = "sell_percent"
        }
    }
}
