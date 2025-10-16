//
//  DashboardService.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

class DashboardService {
    static let shared = DashboardService()

    private let baseURL = apiBaseURL
    private let session: URLSession

    private init() {
        self.session = createApiSession()
    }
    
    
    /// Fetch dashboard data from the API
    /// - Parameter request: DashboardRequest containing optional token
    /// - Returns: DashboardResponse with list of dashboard items (gold, news, etc.)
    func fetchDashboard(request: DashboardRequest? = nil) async throws -> DashboardResponse {
        let dashboardRequest = request ?? DashboardRequest()
        guard let url = URL(string: "\(baseURL)/dashboard") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode request body
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(dashboardRequest)

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
            let dashboardResponse = try decoder.decode(DashboardResponse.self, from: data)
            return dashboardResponse

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

    /// Fetch gold price list (5 days history) from the API
    /// - Parameter request: GoldPriceRequest containing product, city, lang, and branch
    /// - Returns: GoldListResponse with list of historical price data
    func fetchGoldList(request: GoldPriceRequest) async throws -> GoldListResponse {
        guard let url = URL(string: "\(baseURL)/dashboard/gold-list") else {
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

    /// Fetch gold chart data (30 days history) from the API
    /// - Parameter request: GoldPriceRequest containing product, city, lang, and branch
    /// - Returns: GoldChartResponse with 30 days of historical price data
    func fetchGoldChart(request: GoldPriceRequest) async throws -> GoldChartResponse {
        guard let url = URL(string: "\(baseURL)/dashboard/gold-chart") else {
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
            let goldChartResponse = try decoder.decode(GoldChartResponse.self, from: data)
            return goldChartResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Fetch news from the API
    /// - Parameter request: NewsRequest containing lang, page, and product
    /// - Returns: NewsResponse with paginated list of news items
    func fetchNews(request: NewsRequest) async throws -> NewsResponse {
        guard let url = URL(string: "\(baseURL)/news") else {
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
            let newsResponse = try decoder.decode(NewsResponse.self, from: data)
            return newsResponse

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

}
