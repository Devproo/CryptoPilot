//
//  MarketViewModelTests.swift
//  CryptoPilotTests
//
//  Created by ipeerless on 17/10/2026.
//

import XCTest
@testable import CryptoPilot

@MainActor
final class MarketViewModelTests: XCTestCase {
    func testLoadPricesPublishesRequestedPrices() async {
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
        
        let viewModel = MarketViewModel(
            marketDataService: service
        )
        
        await viewModel.loadPrices(for: ["bitcoin"])
        
        XCTAssertEqual(viewModel.prices.count, 1)
        XCTAssertEqual(viewModel.prices.first?.assetID, "bitcoin")
        XCTAssertEqual(viewModel.prices.first?.priceUSD, Decimal(65000))
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadPricesWithEmptyRequestReturnsNoPrices() async {
        let service = MockMarketDataService(prices: [])
        let viewModel = MarketViewModel(marketDataService: service)
        
        await viewModel.loadPrices(for: [])
        
        XCTAssertTrue(viewModel.prices.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    func testPartialResultsShowAvailablePricesAndWarning() async {
        let service = MockMarketDataService(
            prices: [
                MarketPrice(
                    assetID: "bitcoin",
                    priceUSD: 65000
                )
            ]
        )
        
        let viewModel = MarketViewModel(marketDataService: service)
        
        await viewModel.loadPrices(
            for: ["bitcoin", "ethereum"]
        )
        
        XCTAssertEqual(viewModel.prices.count, 1)
        XCTAssertEqual(viewModel.prices.first?.assetID, "bitcoin")
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testEmptyResponseDoesNotErasePreviouslyLoadedPrices() async {
        let service = MockMarketDataService(
            prices: [
                MarketPrice(
                    assetID: "bitcoin",
                    priceUSD: 65000
                )
            ]
        )
        
        let viewModel = MarketViewModel(marketDataService: service)
        
        await viewModel.loadPrices(for: ["bitcoin"])
        XCTAssertEqual(viewModel.prices.count, 1)
        
        await viewModel.loadPrices(for: ["ethereum"])
        
        XCTAssertEqual(viewModel.prices.count, 1)
        XCTAssertEqual(viewModel.prices.first?.assetID, "bitcoin")
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    
    func testInitialLoadFailureShowsError() async {
        let service = FailingMarketDataService()
        let viewModel = MarketViewModel(marketDataService: service)

        await viewModel.loadPrices(for: ["bitcoin"])

        XCTAssertTrue(viewModel.prices.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    
    func testFailedRefreshPreservesPreviouslyLoadedPrices() async {
        let service = FailAfterFirstFetchMarketDataService()
        let viewModel = MarketViewModel(marketDataService: service)

        await viewModel.loadPrices(for: ["bitcoin"])

        XCTAssertEqual(viewModel.prices.count, 1)

        await viewModel.loadPrices(for: ["bitcoin"])

        XCTAssertEqual(viewModel.prices.count, 1)
        XCTAssertEqual(viewModel.prices.first?.assetID, "bitcoin")
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

}


private struct FailingMarketDataService: MarketDataService {
    func fetchPrices(
        for assetIDs: [String]
    ) async throws -> [MarketPrice] {
        throw URLError(.notConnectedToInternet)
    }
}


private final class FetchCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    func next() -> Int {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }
}

private struct FailAfterFirstFetchMarketDataService: MarketDataService {
    let counter = FetchCounter()

    func fetchPrices(
        for assetIDs: [String]
    ) async throws -> [MarketPrice] {
        guard counter.next() == 1 else {
            throw URLError(.notConnectedToInternet)
        }

        return [
            MarketPrice(
                assetID: "bitcoin",
                priceUSD: 65000
            )
        ].filter { assetIDs.contains($0.assetID) }
    }
}
