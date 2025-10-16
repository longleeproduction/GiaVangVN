//
//  GoldDailyRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldDailyRequest: Codable {
    let lang: String
    let branch: String

    init(lang: String = "vi",
         branch: String = "sjc") {
        self.lang = lang
        self.branch = branch
    }
}
