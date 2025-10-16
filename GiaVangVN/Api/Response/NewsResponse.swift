//
//  NewsResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct NewsResponse: Codable {
    let success: Bool
    let data: NewsData?

    struct NewsData: Codable {
        let list: [NewsItem]
        let totalPages: Int
        let currentPage: Int

        enum CodingKeys: String, CodingKey {
            case list
            case totalPages = "total_pages"
            case currentPage = "current_page"
        }
    }

    struct NewsItem: Codable, Identifiable {
        var id: String { url }

        let title: String
        let desc: String
        let imgUrl: String
        let url: String
        let date: String
        let source: String

        enum CodingKeys: String, CodingKey {
            case title
            case desc
            case imgUrl = "img_url"
            case url
            case date
            case source
        }
    }
}
