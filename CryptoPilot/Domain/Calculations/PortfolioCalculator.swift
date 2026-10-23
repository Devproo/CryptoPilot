import Foundation

enum PortfolioCalculationError: Error, Equatable {
    case invalidQuantity
    case invalidPrice
    case invalidFee
    case insufficientHoldings
    case missingTransferCostBasis
}

struct PortfolioCalculationResult {
    let holding: PortfolioHolding
    let realizedProfitLoss: Decimal
}

enum PortfolioCalculator {
    static func calculate(
        asset: CryptoAsset,
        transactions: [PortfolioTransaction],
        currentPrice: Decimal
    ) throws -> PortfolioCalculationResult {
        guard currentPrice >= 0 else {
            throw PortfolioCalculationError.invalidPrice
        }

        var quantity: Decimal = 0
        var costBasis: Decimal = 0
        var realizedProfitLoss: Decimal = 0

        let relevantTransactions = transactions
            .enumerated()
            .filter { $0.element.assetID == asset.id }
            .sorted {
                if $0.element.date == $1.element.date {
                    return $0.offset < $1.offset
                }

                return $0.element.date < $1.element.date
            }
            .map(\.element)

        for transaction in relevantTransactions {
            try validate(transaction)

            switch transaction.type {
            case .buy:
                applyBuy(
                    transaction,
                    quantity: &quantity,
                    costBasis: &costBasis
                )

            case .sell:
                realizedProfitLoss += try applySell(
                    transaction,
                    quantity: &quantity,
                    costBasis: &costBasis
                )

            case .transferIn:
                applyTransferIn(
                    transaction,
                    quantity: &quantity,
                    costBasis: &costBasis
                )

            case .transferOut:
                try applyTransferOut(
                    transaction,
                    quantity: &quantity,
                    costBasis: &costBasis
                )
            }
        }

        let holding = PortfolioHolding(
            asset: asset,
            quantity: quantity,
            costBasis: costBasis,
            currentPrice: currentPrice
        )

        return PortfolioCalculationResult(
            holding: holding,
            realizedProfitLoss: realizedProfitLoss
        )
    }

    private static func validate(
        _ transaction: PortfolioTransaction
    ) throws {
        guard transaction.quantity > 0 else {
            throw PortfolioCalculationError.invalidQuantity
        }

        guard transaction.pricePerCoin >= 0 else {
            throw PortfolioCalculationError.invalidPrice
        }

        guard transaction.fee >= 0 else {
            throw PortfolioCalculationError.invalidFee
        }

        if transaction.type == .transferIn {
            guard let transferCostBasis = transaction.transferCostBasis,
                  transferCostBasis >= 0 else {
                throw PortfolioCalculationError.missingTransferCostBasis
            }
        }
    }

    private static func applyBuy(
        _ transaction: PortfolioTransaction,
        quantity: inout Decimal,
        costBasis: inout Decimal
    ) {
        quantity += transaction.quantity
        costBasis += transaction.totalValue + transaction.fee
    }

    private static func applySell(
        _ transaction: PortfolioTransaction,
        quantity: inout Decimal,
        costBasis: inout Decimal
    ) throws -> Decimal {
        guard quantity >= transaction.quantity else {
            throw PortfolioCalculationError.insufficientHoldings
        }

        let averageCost = costBasis / quantity
        let soldCostBasis = averageCost * transaction.quantity
        let netProceeds = transaction.totalValue - transaction.fee
        let realizedProfitLoss = netProceeds - soldCostBasis

        quantity -= transaction.quantity
        costBasis -= soldCostBasis

        if quantity == 0 {
            costBasis = 0
        }

        return realizedProfitLoss
    }

    private static func applyTransferIn(
        _ transaction: PortfolioTransaction,
        quantity: inout Decimal,
        costBasis: inout Decimal
    ) {
        // Transfer cost basis represents the total basis of
        // the incoming quantity, not a per-coin amount.
        quantity += transaction.quantity
        costBasis += transaction.transferCostBasis ?? 0
    }

    private static func applyTransferOut(
        _ transaction: PortfolioTransaction,
        quantity: inout Decimal,
        costBasis: inout Decimal
    ) throws {
        guard quantity >= transaction.quantity else {
            throw PortfolioCalculationError.insufficientHoldings
        }

        let averageCost = costBasis / quantity
        let removedCostBasis = averageCost * transaction.quantity

        quantity -= transaction.quantity
        costBasis -= removedCostBasis

        if quantity == 0 {
            costBasis = 0
        }
    }
}
