//
//  Item.swift
//  CryptoPilot
//
//  Created by ipeerless on 16/10/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
