//
//  GoldService.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 16/10/25.
//

import Foundation

class GoldService {
    static let shared = GoldService()

    private let baseURL = apiBaseURL
    private let session: URLSession

    private init() {
        self.session = createApiSession()
    }

    /// Fetch gold list (branches and display types) from the API
    /// - Returns: GoldResponse with list of gold branches and display configurations
    func fetchGold() async throws -> GoldResponse {
        guard let url = URL(string: "\(baseURL)/gold") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Empty request body
        urlRequest.httpBody = Data()

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            // Decode response
            let decoder = JSONDecoder()
            let goldResponse = try decoder.decode(GoldResponse.self, from: data)
            return goldResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Fetch gold price from the API
    /// - Parameter request: GoldPriceRequest containing product, city, lang, and branch
    /// - Returns: GoldPriceResponse with price data
    func fetchGoldPrice(request: GoldPriceRequest) async throws -> GoldPriceResponse {
        guard let url = URL(string: "\(baseURL)/dashboard/gold-price") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode request body
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            // Decode response
            let decoder = JSONDecoder()
            let goldPriceResponse = try decoder.decode(GoldPriceResponse.self, from: data)
            return goldPriceResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Fetch gold daily prices by branch from the API
    /// - Parameter request: GoldDailyRequest containing lang and branch
    /// - Returns: GoldDailyResponse with daily prices by city
    func fetchGoldDaily(request: GoldDailyRequest) async throws -> GoldDailyResponse {
        guard let url = URL(string: "\(baseURL)/gold/daily") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode request body
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            // Decode response
            let decoder = JSONDecoder()
            let goldDailyResponse = try decoder.decode(GoldDailyResponse.self, from: data)
            return goldDailyResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Fetch gold list by range from the API
    /// - Parameter request: GoldListRequest containing lang, city, product, branch, and range
    /// - Returns: GoldListResponse with historical price data for specified range
    func fetchGoldListByRange(request: GoldListRequest) async throws -> GoldListResponse {
        guard let url = URL(string: "\(baseURL)/gold/list") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode request body
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            // Decode response
            let decoder = JSONDecoder()
            let goldListResponse = try decoder.decode(GoldListResponse.self, from: data)
            return goldListResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

}
