//
//  QuotefulApp.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import SwiftUI
import SQLiteData

@main
struct QuotefulApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
