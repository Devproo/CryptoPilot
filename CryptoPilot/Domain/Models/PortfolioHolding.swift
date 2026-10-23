//
//  PortfolioHolding.swift
//  CryptoPilot
//
//  Created by ipeerless on 16/10/2026.
//

import Foundation

struct PortfolioHolding: Identifiable {
    let asset: CryptoAsset
    let quantity: Decimal
    let costBasis: Decimal
    let currentPrice: Decimal

    var id: String { asset.id }

    var currentValue: Decimal {
        quantity * currentPrice
    }

    var unrealizedProfitLoss: Decimal {
        currentValue - costBasis
    }

    var profitLossPercentage: Decimal {
        guard costBasis > 0 else { return 0 }
        return (unrealizedProfitLoss / costBasis) * 100
    }
}
