//
//  PortfolioViewModel.swift
//  CryptoPilot
//
//  Created by ipeerless on 18/10/2026.
//


import Foundation
import Observation

@MainActor
@Observable
final class PortfolioViewModel {
    private let transactionStore: TransactionStore

    private(set) var transactions: [PortfolioTransaction] = []
    private(set) var errorMessage: String?

    init(transactionStore: TransactionStore) {
        self.transactionStore = transactionStore
    }

    func loadTransactions() {
        do {
            transactions = try transactionStore.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = "Unable to load portfolio transactions."
        }
    }

    
    
    func addTransaction(_ transaction: PortfolioTransaction) -> Bool {
        do {
            let existingTransactions = try transactionStore.fetchAll()
            let candidateTransactions = existingTransactions + [transaction]

            let asset = CryptoAsset(
                id: transaction.assetID,
                name: transaction.assetID.capitalized,
                symbol: transaction.assetID
            )

            _ = try PortfolioCalculator.calculate(
                asset: asset,
                transactions: candidateTransactions,
                currentPrice: 0
            )

            try transactionStore.save(transaction)
            loadTransactions()

            return true
        } catch PortfolioCalculationError.insufficientHoldings {
            errorMessage = "Insufficient holdings for this transaction."
        } catch PortfolioCalculationError.invalidQuantity {
            errorMessage = "Quantity must be greater than zero."
        } catch PortfolioCalculationError.invalidPrice {
            errorMessage = "Price cannot be negative."
        } catch PortfolioCalculationError.invalidFee {
            errorMessage = "Fee cannot be negative."
        } catch PortfolioCalculationError.missingTransferCostBasis {
            errorMessage = "Transfer-in requires a cost basis."
        } catch {
            errorMessage = "Unable to validate or save the transaction."
        }

        return false
    }


    func deleteTransaction(id: UUID) {
        do {
            try transactionStore.delete(id: id)
            loadTransactions()
        } catch {
            errorMessage = "Unable to delete the transaction."
        }
    }

    func holding(
        for asset: CryptoAsset,
        currentPrice: Decimal
    ) -> PortfolioHolding? {
        do {
            return try PortfolioCalculator.calculate(
                asset: asset,
                transactions: transactions,
                currentPrice: currentPrice
            ).holding
        } catch {
            errorMessage = "Unable to calculate this holding."
            return nil
        }
    }
}

