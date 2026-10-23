//
//  MarketViewModel.swift
//  CryptoPilot
//
//  Created by ipeerless on 17/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MarketViewModel {
    private let marketDataService: any MarketDataService

    private(set) var prices: [MarketPrice] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var lastUpdated: Date?

    var hasPrices: Bool {
        !prices.isEmpty
    }

    var hasStalePrices: Bool {
        hasPrices && errorMessage != nil
    }

    init(marketDataService: any MarketDataService) {
        self.marketDataService = marketDataService
    }

    func loadPrices(
        for assetIDs: [String] = ["bitcoin", "ethereum", "solana"]
    ) async {
        guard !isLoading else { return }

        guard !assetIDs.isEmpty else {
            prices = []
            errorMessage = nil
            lastUpdated = nil
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let fetchedPrices = try await marketDataService.fetchPrices(
                for: assetIDs
            )

            // Keep only requested assets and avoid duplicate entries.
            var pricesByID: [String: MarketPrice] = [:]

            for price in fetchedPrices where assetIDs.contains(price.assetID) {
                pricesByID[price.assetID] = price
            }

            let updatedPrices = assetIDs.compactMap {
                pricesByID[$0]
            }

            guard !updatedPrices.isEmpty else {
                errorMessage = "No market prices are currently available."
                return
            }

            prices = updatedPrices
            lastUpdated = Date.now

            if updatedPrices.count < Set(assetIDs).count {
                errorMessage = "Some requested prices are currently unavailable."
            }
        } catch {
            errorMessage = hasPrices
                ? "Refresh failed. Showing previously loaded prices."
                : "Unable to load market prices. Please try again."
        }
    }
}
