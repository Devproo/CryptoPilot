//
//  AppDependencies.swift
//  CryptoPilot
//
//  Created by ipeerless on 16/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppDependencies {
    
    var transactionStore: TransactionStore?

    let marketDataService: any MarketDataService

    init(
        marketDataService: (any MarketDataService)? = nil
    ) {
        self.marketDataService = marketDataService ?? CoinGeckoService()
    }

    func makeMarketViewModel() -> MarketViewModel {
        MarketViewModel(
            marketDataService: marketDataService
        )
    }
}
