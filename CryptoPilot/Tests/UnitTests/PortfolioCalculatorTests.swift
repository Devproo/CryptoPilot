//
//  PortfolioCalculatorTests.swift
//  CryptoPilot
//
//  Created by ipeerless on 17/10/2026.
//


import XCTest
@testable import CryptoPilot

final class PortfolioCalculatorTests: XCTestCase {
    private let bitcoin = CryptoAsset(
        id: "bitcoin",
        name: "Bitcoin",
        symbol: "BTC"
    )

    func testBuyCalculatesQuantityAndCostBasisIncludingFee() throws {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .buy,
                quantity: 2,
                pricePerCoin: 100,
                fee: 10
            )
        ]

        let result = try PortfolioCalculator.calculate(
            asset: bitcoin,
            transactions: transactions,
            currentPrice: 120
        )

        XCTAssertEqual(result.holding.quantity, 2)
        XCTAssertEqual(result.holding.costBasis, 210)
        XCTAssertEqual(result.holding.currentValue, 240)
        XCTAssertEqual(result.holding.unrealizedProfitLoss, 30)
        XCTAssertEqual(result.realizedProfitLoss, 0)
    }

    func testSellCalculatesRealizedProfitAfterFee() throws {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .buy,
                quantity: 2,
                pricePerCoin: 100
            ),
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .sell,
                quantity: 1,
                pricePerCoin: 150,
                fee: 5
            )
        ]

        let result = try PortfolioCalculator.calculate(
            asset: bitcoin,
            transactions: transactions,
            currentPrice: 150
        )

        XCTAssertEqual(result.holding.quantity, 1)
        XCTAssertEqual(result.holding.costBasis, 100)
        XCTAssertEqual(result.holding.currentValue, 150)
        XCTAssertEqual(result.holding.unrealizedProfitLoss, 50)
        XCTAssertEqual(result.realizedProfitLoss, 45)
    }

    func testRejectsSaleExceedingHoldings() {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .sell,
                quantity: 1,
                pricePerCoin: 100
            )
        ]

        XCTAssertThrowsError(
            try PortfolioCalculator.calculate(
                asset: bitcoin,
                transactions: transactions,
                currentPrice: 100
            )
        ) { error in
            XCTAssertEqual(
                error as? PortfolioCalculationError,
                .insufficientHoldings
            )
        }
    }
    
    
    func testTransferInPreservesProvidedCostBasis() throws {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .transferIn,
                quantity: 2,
                pricePerCoin: 120,
                transferCostBasis: 200
            )
        ]

        let result = try PortfolioCalculator.calculate(
            asset: bitcoin,
            transactions: transactions,
            currentPrice: 120
        )

        XCTAssertEqual(result.holding.quantity, 2)
        XCTAssertEqual(result.holding.costBasis, 200)
        XCTAssertEqual(result.realizedProfitLoss, 0)
    }

    func testTransferOutReducesQuantityWithoutRealizingProfit() throws {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .buy,
                quantity: 2,
                pricePerCoin: 100
            ),
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .transferOut,
                quantity: 1,
                pricePerCoin: 150
            )
        ]

        let result = try PortfolioCalculator.calculate(
            asset: bitcoin,
            transactions: transactions,
            currentPrice: 150
        )

        XCTAssertEqual(result.holding.quantity, 1)
        XCTAssertEqual(result.holding.costBasis, 100)
        XCTAssertEqual(result.realizedProfitLoss, 0)
    }

    func testWeightedAverageCostBasisAcrossMultipleBuys() throws {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .buy,
                quantity: 1,
                pricePerCoin: 100
            ),
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .buy,
                quantity: 1,
                pricePerCoin: 200
            )
        ]

        let result = try PortfolioCalculator.calculate(
            asset: bitcoin,
            transactions: transactions,
            currentPrice: 200
        )

        XCTAssertEqual(result.holding.quantity, 2)
        XCTAssertEqual(result.holding.costBasis, 300)
        XCTAssertEqual(result.holding.currentValue, 400)
        XCTAssertEqual(result.holding.unrealizedProfitLoss, 100)
    }
    func testRejectsZeroQuantity() {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .buy,
                quantity: 0,
                pricePerCoin: 100
            )
        ]

        XCTAssertThrowsError(
            try PortfolioCalculator.calculate(
                asset: bitcoin,
                transactions: transactions,
                currentPrice: 100
            )
        ) { error in
            XCTAssertEqual(
                error as? PortfolioCalculationError,
                .invalidQuantity
            )
        }
    }

    func testRejectsNegativeFee() {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .buy,
                quantity: 1,
                pricePerCoin: 100,
                fee: -5
            )
        ]

        XCTAssertThrowsError(
            try PortfolioCalculator.calculate(
                asset: bitcoin,
                transactions: transactions,
                currentPrice: 100
            )
        ) { error in
            XCTAssertEqual(
                error as? PortfolioCalculationError,
                .invalidFee
            )
        }
    }

    func testTransferInRequiresCostBasis() {
        let transactions = [
            PortfolioTransaction(
                assetID: "bitcoin",
                type: .transferIn,
                quantity: 1,
                pricePerCoin: 100
            )
        ]

        XCTAssertThrowsError(
            try PortfolioCalculator.calculate(
                asset: bitcoin,
                transactions: transactions,
                currentPrice: 100
            )
        ) { error in
            XCTAssertEqual(
                error as? PortfolioCalculationError,
                .missingTransferCostBasis
            )
        }
    }

}
