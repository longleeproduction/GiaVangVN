//
//  CurrencyPriceRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct CurrencyPriceRequest: Codable {
    let code: String
    let lang: String
    let branch: String

    init(code: String = "USD",
         lang: String = "vi",
         branch: String = "VCB") {
        self.code = code
        self.lang = lang
        self.branch = branch
    }
}
