//
//  PortfolioTransaction.swift
//  CryptoPilot
//
//  Created by ipeerless on 16/10/2026.
//



import Foundation

enum TransactionType: String, Codable {
    case buy
    case sell
    case transferIn
    case transferOut
}

struct PortfolioTransaction: Identifiable, Codable, Hashable {
    let id: UUID
    let assetID: String
    let type: TransactionType
    let quantity: Decimal
    let pricePerCoin: Decimal
    let fee: Decimal
    let date: Date
    let transferCostBasis: Decimal?

    init(
        id: UUID = UUID(),
        assetID: String,
        type: TransactionType,
        quantity: Decimal,
        pricePerCoin: Decimal,
        fee: Decimal = 0,
        date: Date = .now,
        transferCostBasis: Decimal? = nil
    ) {
        self.id = id
        self.assetID = assetID
        self.type = type
        self.quantity = quantity
        self.pricePerCoin = pricePerCoin
        self.fee = fee
        self.date = date
        self.transferCostBasis = transferCostBasis
    }

    var totalValue: Decimal {
        quantity * pricePerCoin
    }
}

