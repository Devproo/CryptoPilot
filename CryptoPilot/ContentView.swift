//
//  ContentView.swift
//  CryptoPilot
//
//  Created by ipeerless on 16/10/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: MarketViewModel?
    @Environment(\.modelContext) private var modelContext
    @State private var transactionStore: TransactionStore?
    @State private var portfolioViewModel: PortfolioViewModel?
    
    
    
    
    var body: some View {
        
        NavigationStack {
            Group {
                if let viewModel {
                    marketContent(viewModel)
                } else {
                    ProgressView("Preparing markets…")
                }
            }
            .navigationTitle("CryptoPilot")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel?.loadPrices()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel?.isLoading ?? true)
                    .accessibilityLabel("Refresh prices")
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        PortfolioView()
                    } label: {
                        Label("Portfolio", systemImage: "chart.pie")
                    }
                }

            }
            .task {
                if transactionStore == nil {
                    transactionStore = TransactionStore(context: modelContext)
                }
                
                if portfolioViewModel == nil,
                   let transactionStore {
                    let portfolio = PortfolioViewModel(
                        transactionStore: transactionStore
                    )
                    portfolio.loadTransactions()
                    portfolioViewModel = portfolio
                }

                guard viewModel == nil else { return }
                
                let model = dependencies.makeMarketViewModel()
                viewModel = model
                await model.loadPrices()
            }
        }
    }
    
    @ViewBuilder
    private func marketContent(
        _ viewModel: MarketViewModel
    ) -> some View {
        if viewModel.isLoading && viewModel.prices.isEmpty {
            ProgressView("Loading cryptocurrency prices…")
        } else if let errorMessage = viewModel.errorMessage,
                  viewModel.prices.isEmpty {
            ContentUnavailableView {
                Label("Markets unavailable", systemImage: "wifi.exclamationmark")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Try Again") {
                    Task {
                        await viewModel.loadPrices()
                    }
                }
            }
        } else {
            List(viewModel.prices) { marketPrice in
                VStack(alignment: .leading, spacing: 6) {
                    Text(marketPrice.assetID.capitalized)
                        .font(.headline)
                    
                    Text(
                        marketPrice.priceUSD,
                        format: .currency(code: "USD")
                    )
                    .font(.title3)
                    .monospacedDigit()
                    
                    Text(
                        "Updated \(marketPrice.lastUpdated.formatted(date: .omitted, time: .shortened))"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            .safeAreaInset(edge: .top) {
                if let errorMessage = viewModel.errorMessage,
                   !viewModel.prices.isEmpty {
                    Label(
                        errorMessage,
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial)
                }
            }
            
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        
    }
}
