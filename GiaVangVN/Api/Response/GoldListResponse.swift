//
//  GoldListResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldListResponse: Codable {
    let success: Bool
    let data: GoldListData?
}

struct GoldListData: Codable {
    let title: String
    let subTitle: String
    let list: [GoldListItem]

    enum CodingKeys: String, CodingKey {
        case title
        case subTitle = "sub_title"
        case list
    }
}

struct GoldListItem: Codable, Identifiable {
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
    }
}
