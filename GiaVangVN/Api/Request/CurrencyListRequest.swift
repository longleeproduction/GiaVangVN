//
//  CurrencyListRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct CurrencyListRequest: Codable {
    let code: String
    let branch: String
    let range: Int
    let lang: String

    init(code: String = "USD",
         branch: String = "vcb",
         range: Int = 7,
         lang: String = "vi") {
        self.code = code
        self.branch = branch
        self.range = range
        self.lang = lang
    }
}
