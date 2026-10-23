//
//  TransactionStoreTests.swift
//  CryptoPilotTests
//
//  Created by ipeerless on 18/10/2026.
//


import XCTest
import SwiftData
@testable import CryptoPilot

@MainActor
final class TransactionStoreTests: XCTestCase {
    func testSaveAndFetchTransaction() throws {
        let schema = Schema([StoredTransaction.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        let store = TransactionStore(
            context: container.mainContext
        )

        let transaction = PortfolioTransaction(
            assetID: "bitcoin",
            type: .buy,
            quantity: 0.5,
            pricePerCoin: 60000,
            fee: 10
        )

        try store.save(transaction)

        let savedTransactions = try store.fetchAll()

        XCTAssertEqual(savedTransactions.count, 1)
        XCTAssertEqual(savedTransactions.first?.id, transaction.id)
        XCTAssertEqual(savedTransactions.first?.assetID, "bitcoin")
        XCTAssertEqual(savedTransactions.first?.quantity, Decimal(string: "0.5"))
        XCTAssertEqual(savedTransactions.first?.fee, Decimal(10))
    }
    
    func testDeleteRemovesSavedTransaction() throws {
        let schema = Schema([StoredTransaction.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        let store = TransactionStore(
            context: container.mainContext
        )

        let transaction = PortfolioTransaction(
            assetID: "bitcoin",
            type: .buy,
            quantity: 1,
            pricePerCoin: 60000
        )

        try store.save(transaction)
        try store.delete(id: transaction.id)

        XCTAssertTrue(try store.fetchAll().isEmpty)
    }

    func testFetchPreservesTransactionTypeAndTransferCostBasis() throws {
        let schema = Schema([StoredTransaction.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        let store = TransactionStore(
            context: container.mainContext
        )

        let transaction = PortfolioTransaction(
            assetID: "ethereum",
            type: .transferIn,
            quantity: 2,
            pricePerCoin: 0,
            transferCostBasis: 4000
        )

        try store.save(transaction)

        let fetched = try store.fetchAll().first

        XCTAssertEqual(fetched?.type, .transferIn)
        XCTAssertEqual(
            fetched?.transferCostBasis,
            Decimal(4000)
        )
    }

}
