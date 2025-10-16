//
//  CurrencyListResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct CurrencyListResponse: Codable {
    let success: Bool
    let data: CurrencyListData?

    struct CurrencyListData: Codable {
        let title: String
        let subTitle: String
        let list: [CurrencyListItem]

        enum CodingKeys: String, CodingKey {
            case title
            case subTitle = "sub_title"
            case list
        }
    }

    struct CurrencyListItem: Codable, Identifiable {
        let id: String
        let dateUpdate: String
        let buyDisplay: String
        let buy: String
        let buyDelta: String
        let buyPercent: String
        let sellDisplay: String
        let sell: String
        let sellDelta: String
        let sellPercent: String
        let transferDisplay: String
        let transfer: String
        let transferDelta: String
        let transferPercent: String

        enum CodingKeys: String, CodingKey {
            case id
            case dateUpdate = "date_update"
            case buyDisplay = "buy_display"
            case buy
            case buyDelta = "buy_delta"
            case buyPercent = "buy_percent"
            case sellDisplay = "sell_display"
            case sell
            case sellDelta = "sell_delta"
            case sellPercent = "sell_percent"
            case transferDisplay = "transfer_display"
            case transfer
            case transferDelta = "transfer_delta"
            case transferPercent = "transfer_percent"
        }
    }
}
