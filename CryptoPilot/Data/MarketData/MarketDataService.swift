//
//  MarketDataService.swift
//  CryptoPilot
//
//  Created by ipeerless on 17/10/2026.
//

import Foundation

protocol MarketDataService {
    func fetchPrices(
        for assetIDs: [String]
    ) async throws -> [MarketPrice]
}
