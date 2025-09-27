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
    
    init() {
        setTabBarItemColor(selected: .beigeTab, unselected: .gray)
    }
    
    var body: some Scene {
        WindowGroup {
            if dbPool != nil {
                QuotefulRootView()
                    .environment(\.isUITesting, ProcessInfo.processInfo.arguments.contains("mock_ui"))
            } else {
                VStack {
                    Text("dbInitFailed")
                    Text("contactDevs")
                }
            }
        }
    }
}

private struct IsUITestingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isUITesting: Bool {
        get { self[IsUITestingKey.self] }
        set { self[IsUITestingKey.self] = newValue }
    }
}

// MARK: - Previewing localization values
#Preview {
    VStack {
        Text("dbInitFailed")
        Text("contactDevs")
    }
}
