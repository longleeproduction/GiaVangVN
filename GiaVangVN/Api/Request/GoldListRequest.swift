//
//  GoldListRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldListRequest: Codable {
    let lang: String
    let city: String
    let product: String
    let branch: String
    let range: Int

    init(lang: String = "vi",
         city: String = "Toàn quốc",
         product: String = "Vàng miếng SJC",
         branch: String = "sjc",
         range: Int = 7) {
        self.lang = lang
        self.city = city
        self.product = product
        self.branch = branch
        self.range = range
    }
}
