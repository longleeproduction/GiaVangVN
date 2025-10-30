//
//  Api.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import Foundation

let apiBaseURL = "https://giavang.pro/services/v1"

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

enum ListRange: Int, CaseIterable {
    case Range7d = 7
    case Range30d = 30
    case Range60d = 60
    case Range180d = 180
    case Range365d = 365
    
    var title: String {
        switch self {
        case .Range7d: return "7 ngày"
        case .Range30d: return "30 ngày"
        case .Range60d: return "60 ngày"
        case .Range180d: return "180 ngày"
        case .Range365d: return "1 năm"
        }
    }
}

func createApiSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = [
        "Host": "giavang.pro",
        "accept": "*/*",
        "Content-Type": "application/json",
        "User-Agent": "GiaVang/78 CFNetwork/3826.500.131 Darwin/24.5.0",
        "Accept-Language": "vi-VN,vi;q=0.9"
    ]
    return URLSession(configuration: configuration)
}
