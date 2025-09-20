//
//  ZenQuoteClient_Tests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 19.09.2025.
//

import Testing
import Foundation
@testable import Quoteful
import FactoryKit
import FactoryTesting

struct ZenQuoteClient_Tests {
    // MARK: - Integration Tests
    
    @Test(.container, .tags(.integration, .requiresNetwork))
    func `fetchTodayQuote returns valid quote from real API`() async throws {
        // Given
        let client = Container.shared.quoteClient()
        
        // When
        let dayQuote = try await client.fetchTodayQuote()
        
        // Then
        #expect(!dayQuote.quote.isEmpty)
        #expect(!dayQuote.author.isEmpty)
        #expect(dayQuote.quote.count > 0)
        #expect(dayQuote.author.count > 0)
    }
    
    @Test(.container, .tags(.integration, .requiresNetwork))
    func `fetchTodayQuote handles API response structure`() async throws {
        // Given
        let client = Container.shared.quoteClient()
        
        // When
        let dayQuote = try await client.fetchTodayQuote()
        
        // Then
        #expect(dayQuote.quote.count < 1000, "Quote should be reasonable length")
        #expect(!dayQuote.author.contains("[["), "Author shouldn't contain wiki markup")
    }
    
    // MARK: - Unit Tests with Stubs
    
    @Test(.container)
    func `fetchTodayQuote returns when connected to internet`() async throws {
        // Given
        Container.shared.quoteClient.register {
            ZenQuoteClient(
                fetchTodayQuote: {
                    ZenQuote(
                        quote: "Test quote",
                        author: "Test author"
                    )
                }
            )
        }
        let client = Container.shared.quoteClient()
        
        // When
        let dayQuote = try await client.fetchTodayQuote()
        
        // Then
        #expect(!dayQuote.quote.isEmpty && !dayQuote.author.isEmpty)
    }
    
    @Test(.container)
    func `fetchTodayQuote doesn't return when disconnected from internet`() async throws {
        // Given
        Container.shared.quoteClient.register {
            ZenQuoteClient(
                fetchTodayQuote: {
                    throw URLError(.notConnectedToInternet)
                }
            )
        }
        let client = Container.shared.quoteClient()
        
        // Then
        await #expect(throws: URLError(.notConnectedToInternet).self) {
            // When
            try await client.fetchTodayQuote()
        }
    }
}
