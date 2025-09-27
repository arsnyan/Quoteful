//
//  Extension+Container.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 20.09.2025.
//

import Foundation
import FactoryKit

extension Container: @retroactive AutoRegistering {
    public func autoRegister() {
        #if DEBUG
        dbPool
            .onTest { try? appDatabase(testEnvironment: true) }
        
        dbPool
            .onArg("mock_empty_db") { try? appDatabase(testEnvironment: true) }
        
        quoteClient
            .onPreview {
                ZenQuoteClient(
                    fetchTodayQuote: {
                        ZenQuote(
                            quote: "This is a test quote for previews",
                            author: "Test Author"
                        )
                    }
                )
            }
        
        networkMonitor
            .onPreview {
                MockNetworkMonitor()
            }
            .onTest {
                MockNetworkMonitor()
            }
        #endif
    }
}
