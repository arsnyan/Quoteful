//
//  NetworkMonitor.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import Foundation
import Network
import FactoryKit

enum NetworkError: LocalizedError {
    case noInternetConnection
    
    var errorDescription: String? {
        String(localized: "noInternetConnection")
    }
}

protocol NetworkMonitorProtocol {
    var isConnected: Bool { get async }
}

actor NetworkMonitor: NetworkMonitorProtocol, Sendable {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor.Queue", qos: .background)
    
    private(set) var isConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.updateConnectionStatus(path.status == .satisfied)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func updateConnectionStatus(_ isConnected: Bool) {
        self.isConnected = isConnected
    }
}

extension Container {
    var networkMonitor: Factory<NetworkMonitorProtocol> {
        self {
            NetworkMonitor()
        }
        .singleton
    }
}

#if DEBUG
struct MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true
}
#endif
