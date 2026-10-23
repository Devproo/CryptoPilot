//
//  MarketDataServiceTests.swift
//  CryptoPilotTests
//
//  Created by ipeerless on 17/10/2026.
//
import XCTest
@testable import CryptoPilot

@MainActor
final class MarketDataServiceTests: XCTestCase {
    func testMockReturnsOnlyRequestedPrices() async throws {
        let service = MockMarketDataService(
            prices: [
                MarketPrice(
                    assetID: "bitcoin",
                    priceUSD: 65000
                ),
                MarketPrice(
                    assetID: "ethereum",
                    priceUSD: 3000
                )
            ]
        )

        let result = try await service.fetchPrices(
            for: ["bitcoin"]
        )

        XCTAssertEqual(result.count, 1)

        let firstAssetID = result.first?.assetID
        let firstPrice = result.first?.priceUSD

        XCTAssertEqual(firstAssetID, "bitcoin")
        XCTAssertEqual(firstPrice, Decimal(65000))
    }

    func testMockReturnsEmptyArrayForNoRequestedAssets() async throws {
        let service = MockMarketDataService(prices: [])

        let result = try await service.fetchPrices(for: [])

        XCTAssertTrue(result.isEmpty)
    }
}
