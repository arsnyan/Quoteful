//
//  ZenQuoteClient_Tests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 19.09.2025.
//

import Dependencies
import Testing
@testable import Quoteful

struct ZenQuoteClient_Tests {
    @Test func `fetchTodayQuote returns when connected to internet`() async throws {
        let quote = try await withDependencies {
            $0.quoteClient = ZenQuoteClient(
                fetchTodayQuote: {
                    ZenQuote(
                        quote: "Test quote",
                        author: "Test author"
                    )
                }
            )
        } operation: {
            @Dependency(\.quoteClient) var client
            return try await client.fetchTodayQuote()
        }
        
        #expect(!quote.quote.isEmpty && !quote.author.isEmpty)
    }
}
