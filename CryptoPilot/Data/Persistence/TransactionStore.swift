//
//  TransactionStore.swift
//  CryptoPilot
//
//  Created by ipeerless on 18/10/2026.
//


import Foundation
import SwiftData

@MainActor
final class TransactionStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ transaction: PortfolioTransaction) throws {
        let stored = StoredTransaction(transaction: transaction)
        context.insert(stored)
        try context.save()
    }

   
    func fetchAll() throws -> [PortfolioTransaction] {
        let storedTransactions = try context.fetch(
            FetchDescriptor<StoredTransaction>()
        )

        return storedTransactions.compactMap { stored in
            stored.toDomain()
        }
    }


    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<StoredTransaction>(
            predicate: #Predicate { $0.id == id }
        )

        let matches = try context.fetch(descriptor)

        for transaction in matches {
            context.delete(transaction)
        }

        try context.save()
    }
}

