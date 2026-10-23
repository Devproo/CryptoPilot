//
//  MarketPrice.swift
//  CryptoPilot
//
//  Created by ipeerless on 17/10/2026.
//

import Foundation

struct MarketPrice: Identifiable, Codable, Hashable, Sendable {
    let assetID: String
    let priceUSD: Decimal
    let lastUpdated: Date

    var id: String { assetID }

    init(
        assetID: String,
        priceUSD: Decimal,
        lastUpdated: Date = .now
    ) {
        self.assetID = assetID
        self.priceUSD = priceUSD
        self.lastUpdated = lastUpdated
    }
}
