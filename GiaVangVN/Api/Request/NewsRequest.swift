//
//  NewsRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct NewsRequest: Codable {
    let lang: String
    let page: Int
    let product: String

    init(lang: String = "vi",
         page: Int = 1,
         product: String = "cafef") {
        self.lang = lang
        self.page = page
        self.product = product
    }
}
