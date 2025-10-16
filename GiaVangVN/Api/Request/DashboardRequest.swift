//
//  DashboardRequest.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct DashboardRequest: Codable {
    let token: String

    init(token: String = "") {
        self.token = token
    }
}
