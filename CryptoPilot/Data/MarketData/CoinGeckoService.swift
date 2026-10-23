//
//  CoinGeckoService.swift
//  CryptoPilot
//
//  Created by ipeerless on 17/10/2026.
//

import Foundation

enum MarketDataError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
}

struct CoinGeckoService: MarketDataService {
    private let baseURL = "https://api.coingecko.com/api/v3"

    func fetchPrices(
        for assetIDs: [String]
    ) async throws -> [MarketPrice] {
        guard !assetIDs.isEmpty else {
            return []
        }

        var components = URLComponents(
            string: "\(baseURL)/simple/price"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "ids",
                value: assetIDs.joined(separator: ",")
            ),
            URLQueryItem(name: "vs_currencies", value: "usd")
        ]

        guard let url = components?.url else {
            throw MarketDataError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MarketDataError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw MarketDataError.requestFailed(
                statusCode: httpResponse.statusCode
            )
        }

        let decoded = try JSONDecoder().decode(
            [String: [String: Decimal]].self,
            from: data
        )

        let updatedAt = Date.now

        return decoded.compactMap { assetID, prices in
            guard let price = prices["usd"] else {
                return nil
            }

            return MarketPrice(
                assetID: assetID,
                priceUSD: price,
                lastUpdated: updatedAt
            )
        }
    }
}
