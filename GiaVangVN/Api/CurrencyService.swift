//
//  CurrencyService.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import Foundation

class CurrencyService {
    static let shared = CurrencyService()

    private let baseURL = apiBaseURL
    private let session: URLSession

    private init() {
        self.session = createApiSession()
    }

    /// Fetch currency list (banks and display types) from the API
    /// - Returns: CurrencyResponse with list of currency banks and display configurations
    func fetchCurrency() async throws -> CurrencyResponse {
        guard let url = URL(string: "\(baseURL)/currency") else {
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
            let currencyResponse = try decoder.decode(CurrencyResponse.self, from: data)
            return currencyResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Fetch currency exchange rate from the API
    /// - Parameter request: CurrencyPriceRequest containing code, lang, and branch
    /// - Returns: CurrencyPriceResponse with exchange rate data
    func fetchCurrencyPrice(request: CurrencyPriceRequest) async throws -> CurrencyPriceResponse {
        guard let url = URL(string: "\(baseURL)/dashboard/currency-price") else {
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
            let currencyPriceResponse = try decoder.decode(CurrencyPriceResponse.self, from: data)
            return currencyPriceResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Fetch currency daily rates by branch from the API
    /// - Parameter request: CurrencyDailyRequest containing branch and lang
    /// - Returns: CurrencyDailyResponse with daily exchange rates
    func fetchCurrencyDaily(request: CurrencyDailyRequest) async throws -> CurrencyDailyResponse {
        guard let url = URL(string: "\(baseURL)/currency/daily") else {
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
            let currencyDailyResponse = try decoder.decode(CurrencyDailyResponse.self, from: data)
            return currencyDailyResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Fetch currency list by range from the API
    /// - Parameter request: CurrencyListRequest containing code, branch, range, and lang
    /// - Returns: CurrencyListResponse with historical exchange rate data for specified range
    func fetchCurrencyList(request: CurrencyListRequest) async throws -> CurrencyListResponse {
        guard let url = URL(string: "\(baseURL)/currency/list") else {
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
            let currencyListResponse = try decoder.decode(CurrencyListResponse.self, from: data)
            return currencyListResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

}
