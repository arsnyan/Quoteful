//
//  QuotefulApp.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import SwiftUI
import FactoryKit
import GRDB
import OSLog

@main
struct QuotefulApp: App {
    private let logger = Logger(subsystem: "Quoteful", category: "App Management")
    @Injected(\.dbPool) private var dbPool
    
    var body: some Scene {
        WindowGroup {
            if dbPool != nil {
                ContentView()
            } else {
                Text("Failed to initialize the database. Contact developer")
            }
        }
    }
}
