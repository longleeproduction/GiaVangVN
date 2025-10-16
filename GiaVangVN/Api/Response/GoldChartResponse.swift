//
//  GoldChartResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldChartResponse: Codable {
    let success: Bool
    let data: GoldChartData?

    struct GoldChartData: Codable {
        let title: String
        let subTitle: String
        let list: [GoldChartItem]

        enum CodingKeys: String, CodingKey {
            case title
            case subTitle = "sub_title"
            case list
        }
    }

    struct GoldChartItem: Codable, Identifiable {
        var id: String { dateUpdate }

        let dateUpdate: String
        let buyDisplay: String
        let buy: String
        let sellDisplay: String
        let sell: String

        enum CodingKeys: String, CodingKey {
            case dateUpdate = "date_update"
            case buyDisplay = "buy_display"
            case buy
            case sellDisplay = "sell_display"
            case sell
        }
    }
}
