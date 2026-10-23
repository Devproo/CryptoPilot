//
//  AddTransactionView.swift
//  CryptoPilot
//
//  Created by ipeerless on 18/10/2026.
//


import SwiftUI

struct AddTransactionView: View {
   
    let onSave: (PortfolioTransaction) -> Bool


    @Environment(\.dismiss) private var dismiss

    @State private var assetID = "bitcoin"
    @State private var type: TransactionType = .buy
    @State private var quantity = ""
    @State private var pricePerCoin = ""
    @State private var fee = "0"
    @State private var transferCostBasis = ""
    @State private var errorMessage: String?

    private var isTransferIn: Bool {
        type == .transferIn
    }

    var body: some View {
        Form {
            Section("Asset") {
                Picker("Cryptocurrency", selection: $assetID) {
                    Text("Bitcoin").tag("bitcoin")
                    Text("Ethereum").tag("ethereum")
                    Text("Solana").tag("solana")
                }

                Picker("Transaction type", selection: $type) {
                    Text("Buy").tag(TransactionType.buy)
                    Text("Sell").tag(TransactionType.sell)
                    Text("Transfer in").tag(TransactionType.transferIn)
                    Text("Transfer out").tag(TransactionType.transferOut)
                }
            }

            Section("Details") {
                TextField("Quantity", text: $quantity)
                    .keyboardType(.decimalPad)

                TextField("Price per coin (USD)", text: $pricePerCoin)
                    .keyboardType(.decimalPad)

                TextField("Fee (USD)", text: $fee)
                    .keyboardType(.decimalPad)

                if isTransferIn {
                    TextField(
                        "Total transferred cost basis (USD)",
                        text: $transferCostBasis
                    )
                    .keyboardType(.decimalPad)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Save Transaction", action: saveTransaction)
            }
        }
        .navigationTitle("Add Transaction")
        .navigationBarTitleDisplayMode(.inline)
        
    }

    private func saveTransaction() {
        guard
            let parsedQuantity = Decimal(string: quantity),
            parsedQuantity > 0,
            let parsedPrice = Decimal(string: pricePerCoin),
            parsedPrice >= 0,
            let parsedFee = Decimal(string: fee),
            parsedFee >= 0
        else {
            errorMessage = "Enter a valid positive quantity and non-negative price and fee."
            return
        }

        var parsedTransferCostBasis: Decimal?

        if isTransferIn {
            guard
                let basis = Decimal(string: transferCostBasis),
                basis >= 0
            else {
                errorMessage = "Enter a valid non-negative transfer cost basis."
                return
            }

            parsedTransferCostBasis = basis
        }

        let transaction = PortfolioTransaction(
            assetID: assetID,
            type: type,
            quantity: parsedQuantity,
            pricePerCoin: parsedPrice,
            fee: parsedFee,
            transferCostBasis: parsedTransferCostBasis
        )

       
        if onSave(transaction) {
            dismiss()
        } else {
            errorMessage = "Transaction could not be saved. Check your holdings and transaction details."
        }


    }
}
