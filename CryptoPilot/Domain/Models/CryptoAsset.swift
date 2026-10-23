//
//  CryptoAsset.swift
//  CryptoPilot
//
//  Created by ipeerless on 16/10/2026.
//


import Foundation

struct CryptoAsset: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let symbol: String
    
    init(id: String, name: String, symbol: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
    }
}
