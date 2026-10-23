//
//  PortfolioView.swift
//  CryptoPilot
//
//  Created by ipeerless on 18/10/2026.
//


import SwiftUI

struct PortfolioView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddTransaction = false

    @State private var viewModel: PortfolioViewModel?
    @State private var prices: [String: Decimal] = [
        "bitcoin": 0,
        "ethereum": 0,
        "solana": 0
    ]

    var body: some View {
        Group {
            if let viewModel {
                List {
                    Section("Holdings") {
                        ForEach(
                            ["bitcoin", "ethereum", "solana"],
                            id: \.self
                        ) { assetID in
                            let asset = CryptoAsset(
                                id: assetID,
                                name: assetID.capitalized,
                                symbol: assetID
                            )

                            if let holding = viewModel.holding(
                                for: asset,
                                currentPrice: prices[assetID] ?? 0
                            ), holding.quantity > 0 {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(asset.name)
                                        .font(.headline)

                                    Text(
                                        holding.currentValue,
                                        format: .currency(code: "USD")
                                    )

                                    Text(
                                        "P/L: \(holding.unrealizedProfitLoss.formatted(.currency(code: "USD")))"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        holding.unrealizedProfitLoss >= 0
                                            ? .green : .red
                                    )
                                }
                            }
                        }
                    }

                    Section("Transactions") {
                        if viewModel.transactions.isEmpty {
                            ContentUnavailableView(
                                "No Transactions",
                                systemImage: "arrow.left.arrow.right",
                                description: Text(
                                    "Your saved transactions will appear here."
                                )
                            )
                        } else {
                            ForEach(viewModel.transactions) { transaction in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(
                                        "\(transaction.type.rawValue.capitalized) \(transaction.assetID.capitalized)"
                                    )
                                    .font(.headline)

                                    Text(transaction.quantity.description + " coins")

                                    Text(
                                        transaction.pricePerCoin,
                                        format: .currency(code: "USD")
                                    )

                                    .font(.caption)
                                }
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    let transaction = viewModel.transactions[index]
                                    viewModel.deleteTransaction(id: transaction.id)
                                }
                            }
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }
                }
            } else {
                ProgressView("Loading portfolio…")
            }
        }
        .navigationTitle("Portfolio")
        .task {
            guard viewModel == nil else { return }

            let store = TransactionStore(context: modelContext)
            let portfolio = PortfolioViewModel(transactionStore: store)
            portfolio.loadTransactions()
            viewModel = portfolio

            let marketViewModel = dependencies.makeMarketViewModel()
            await marketViewModel.loadPrices()

            prices = Dictionary(
                uniqueKeysWithValues: marketViewModel.prices.map {
                    ($0.assetID, $0.priceUSD)
                }
            )
        }
    }
}
