//
//  CurrencyDailyRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct CurrencyDailyRequest: Codable {
    let branch: String
    let lang: String

    init(branch: String = "vcb",
         lang: String = "vi") {
        self.branch = branch
        self.lang = lang
    }
}
