//
//  StoredTransaction.swift
//  CryptoPilot
//
//  Created by ipeerless on 18/10/2026.
//


import Foundation
import SwiftData

@Model
final class StoredTransaction {
    @Attribute(.unique) var id: UUID

    var assetID: String
    var type: String
    var quantity: Decimal
    var pricePerCoin: Decimal
    var fee: Decimal
    var date: Date
    var transferCostBasis: Decimal?

    init(
        id: UUID = UUID(),
        assetID: String,
        type: String,
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
    
    convenience init(transaction: PortfolioTransaction) {
        self.init(
            id: transaction.id,
            assetID: transaction.assetID,
            type: transaction.type.rawValue,
            quantity: transaction.quantity,
            pricePerCoin: transaction.pricePerCoin,
            fee: transaction.fee,
            date: transaction.date,
            transferCostBasis: transaction.transferCostBasis
        )
    }

    func toDomain() -> PortfolioTransaction? {
        guard let transactionType = TransactionType(rawValue: type) else {
            return nil
        }

        return PortfolioTransaction(
            id: id,
            assetID: assetID,
            type: transactionType,
            quantity: quantity,
            pricePerCoin: pricePerCoin,
            fee: fee,
            date: date,
            transferCostBasis: transferCostBasis
        )
    }

    
}

