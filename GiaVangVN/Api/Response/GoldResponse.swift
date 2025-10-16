//
//  GoldResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldResponse: Codable {
    let success: Bool
    let data: GoldData?

    struct GoldData: Codable {
        let list: [GoldItem]
    }

    struct GoldItem: Codable, Identifiable {
        let id: Int
        let title: String
        let displayType: String
        let data: String

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case displayType = "display_type"
            case data
        }

        // Helper computed properties for decoded data
        var decodedData: [String: Any]? {
            guard let decodedData = Data(base64Encoded: data),
                  let jsonObject = try? JSONSerialization.jsonObject(with: decodedData, options: []),
                  let dictionary = jsonObject as? [String: Any] else {
                return nil
            }
            return dictionary
        }
    }
}

// Enum for gold display types
enum GoldDisplayType: String {
    case list = "list"
    case table = "table"
    case box = "box"
    case unknown

    init(rawValue: String) {
        switch rawValue {
        case "list": self = .list
        case "table": self = .table
        case "box": self = .box
        default: self = .unknown
        }
    }
}
