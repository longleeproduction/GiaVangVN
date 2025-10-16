//
//  GoldPriceRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldPriceRequest: Codable {
    let product: String
    let city: String
    let lang: String
    let branch: String

    init(product: String = "Vàng nhẫn 9999",
         city: String = "Hồ Chí Minh",
         lang: String = "vi",
         branch: String = "SJC") {
        self.product = product
        self.city = city
        self.lang = lang
        self.branch = branch
    }
}
