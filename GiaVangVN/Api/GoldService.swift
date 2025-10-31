//
//  GoldService.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import Foundation

class GoldService {
    static let shared = GoldService()

    private let baseURL = apiBaseURL
    private let session: URLSession

    private init() {
        self.session = createApiSession()
    }

    #if DEBUG
    /// Debug helper to print request details
    private func debugPrintRequest(_ request: URLRequest, body: Data?) {
        print("\n🟢 [GoldService] ========== REQUEST ==========")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Method: \(request.httpMethod ?? "N/A")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers:")
            headers.forEach { print("  \($0.key): \($0.value)") }
        }

        if let body = body, !body.isEmpty {
            if let jsonString = String(data: body, encoding: .utf8) {
                print("Body: \(jsonString)")
            } else {
                print("Body: \(body.count) bytes")
            }
        }
        print("==========================================\n")
    }

    /// Debug helper to print response details
    private func debugPrintResponse(_ response: HTTPURLResponse, data: Data, decodedObject: Any? = nil) {
        return;
        print("\n🔵 [GoldService] ========== RESPONSE ==========")
        print("URL: \(response.url?.absoluteString ?? "N/A")")
        print("Status Code: \(response.statusCode)")

        if !response.allHeaderFields.isEmpty {
            print("Headers:")
            response.allHeaderFields.forEach { print("  \($0.key): \($0.value)") }
        }

        print("Data Size: \(data.count) bytes")

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw Data: \(jsonString)")
        }

        if let decodedObject = decodedObject {
            print("Decoded Object: \(decodedObject)")
        }
        print("==========================================\n")
    }
    #endif

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

        #if DEBUG
        debugPrintRequest(urlRequest, body: urlRequest.httpBody)
        #endif

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

            #if DEBUG
            debugPrintResponse(httpResponse, data: data, decodedObject: goldResponse)
            #endif

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

        #if DEBUG
        debugPrintRequest(urlRequest, body: urlRequest.httpBody)
        #endif

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

            #if DEBUG
            debugPrintResponse(httpResponse, data: data, decodedObject: goldPriceResponse)
            #endif

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

        #if DEBUG
        debugPrintRequest(urlRequest, body: urlRequest.httpBody)
        #endif

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

            #if DEBUG
            debugPrintResponse(httpResponse, data: data, decodedObject: goldDailyResponse)
            #endif

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

        #if DEBUG
        debugPrintRequest(urlRequest, body: urlRequest.httpBody)
        #endif

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

            #if DEBUG
            debugPrintResponse(httpResponse, data: data, decodedObject: goldListResponse)
            #endif

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
