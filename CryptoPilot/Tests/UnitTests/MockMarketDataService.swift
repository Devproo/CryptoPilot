//
//  MockMarketDataService.swift
//  CryptoPilotTests
//
//  Created by ipeerless on 17/10/2026.
//

import Foundation
@testable import CryptoPilot

struct MockMarketDataService: MarketDataService {
    let prices: [MarketPrice]

    func fetchPrices(
        for assetIDs: [String]
    ) async throws -> [MarketPrice] {
        prices.filter { assetIDs.contains($0.assetID) }
    }
}
