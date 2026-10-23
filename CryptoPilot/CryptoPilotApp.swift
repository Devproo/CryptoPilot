//
//  CryptoPilotApp.swift
//  CryptoPilot
//
//  Created by ipeerless on 16/10/2026.
//

import SwiftUI
import SwiftData

@main
@MainActor
struct CryptoPilotApp: App {
    private let dependencies = AppDependencies()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            StoredTransaction.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
        }
        .modelContainer(sharedModelContainer)
    }
}
