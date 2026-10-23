//
//  PortfolioViewModelTests.swift
//  CryptoPilotTests
//
//  Created by ipeerless on 18/10/2026.
//



import XCTest
import SwiftData
@testable import CryptoPilot

@MainActor
final class PortfolioViewModelTests: XCTestCase {

    private func makeViewModel() throws -> PortfolioViewModel {
        let schema = Schema([StoredTransaction.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        let store = TransactionStore(context: container.mainContext)
        return PortfolioViewModel(transactionStore: store)
    }

    func testAddTransactionLoadsSavedTransaction() throws {
        let viewModel = try makeViewModel()

        let transaction = PortfolioTransaction(
            assetID: "bitcoin",
            type: .buy,
            quantity: 1,
            pricePerCoin: 60000
        )

        XCTAssertTrue(viewModel.addTransaction(transaction))
        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertEqual(viewModel.transactions.first?.id, transaction.id)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDeleteTransactionRemovesItFromViewModel() throws {
        let viewModel = try makeViewModel()

        let transaction = PortfolioTransaction(
            assetID: "bitcoin",
            type: .buy,
            quantity: 1,
            pricePerCoin: 60000
        )

        XCTAssertTrue(viewModel.addTransaction(transaction))

        viewModel.deleteTransaction(id: transaction.id)

        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testHoldingUsesPortfolioCalculator() throws {
        let viewModel = try makeViewModel()

        let asset = CryptoAsset(
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC"
        )

        let transaction = PortfolioTransaction(
            assetID: "bitcoin",
            type: .buy,
            quantity: 2,
            pricePerCoin: 100
        )

        XCTAssertTrue(viewModel.addTransaction(transaction))

        let holding = viewModel.holding(
            for: asset,
            currentPrice: 150
        )

        XCTAssertEqual(holding?.quantity, Decimal(2))
        XCTAssertEqual(holding?.costBasis, Decimal(200))
        XCTAssertEqual(holding?.currentValue, Decimal(300))
        XCTAssertEqual(holding?.unrealizedProfitLoss, Decimal(100))
    }

    func testSaleWithInsufficientHoldingsIsRejected() throws {
        let viewModel = try makeViewModel()

        let sale = PortfolioTransaction(
            assetID: "bitcoin",
            type: .sell,
            quantity: 1,
            pricePerCoin: 60000
        )

        XCTAssertFalse(viewModel.addTransaction(sale))
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertEqual(
            viewModel.errorMessage,
            "Insufficient holdings for this transaction."
        )
    }
}
