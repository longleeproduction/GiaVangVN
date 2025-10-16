//
//  DashboardResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct DashboardResponse: Codable {
    let success: Bool
    let data: DashboardData?

    struct DashboardData: Codable {
        let list: [DashboardItem]
    }

    struct DashboardItem: Codable, Identifiable {
        let id: Int
        let title: String
        let subTitle: String
        let displayType: String
        let data: String

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case subTitle = "sub_title"
            case displayType = "display_type"
            case data
        }

        // Helper computed properties for decoded data
        var decodedData: [String: String]? {
            guard let decodedData = Data(base64Encoded: data),
                  let jsonObject = try? JSONSerialization.jsonObject(with: decodedData, options: []),
                  let dictionary = jsonObject as? [String: String] else {
                return nil
            }
            return dictionary
        }
    }
}

// Enum for display types
enum DashboardDisplayType: String {
    case gold = "gold"
    case news = "news"
    case currency = "currency"
    case unknown

    init(rawValue: String) {
        switch rawValue {
        case "gold": self = .gold
        case "news": self = .news
        case "currency": self = .currency
        default: self = .unknown
        }
    }
}
