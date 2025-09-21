//
//  HomeViewModel_Tests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import Testing
@testable import Quoteful
import FactoryKit
import FactoryTesting
import Foundation

@Suite(.container)
@MainActor
struct HomeViewModel_Tests {
    init() {
        Container.shared.networkMonitor.reset()
        Container.shared.quoteClient.reset()
    }
    
    @Test
    func `fetchQuote sets state to failure when no internet`() async throws {
        // Given
        Container.shared.networkMonitor.register {
            MockNetworkMonitor(isConnected: false)
        }
        let viewModel = HomeViewModel()
        
        // When
        await viewModel.fetchQuote()
        
        // Then
        switch viewModel.quoteState {
        case .failure:
            #expect(true)
        default:
            #expect(Bool(false), "State hasn't changed: \(viewModel.quoteState)")
        }
    }
    
    @Test
    func `Initial state is always .loading`() {
        // Given
        let viewModel = HomeViewModel()
        
        // Then
        if case .loading = viewModel.quoteState {
            #expect(true)
        } else {
            #expect(Bool(false), "Initial state should always be .loading")
        }
    }
    
    @Test
    func `fetchQuote successes if quote is correct`() async throws {
        // Given
        let refQuote = ZenQuote(quote: "Test", author: "Test author")
        
        Container.shared.quoteClient.register {
            ZenQuoteClient(fetchTodayQuote: { refQuote })
        }
        let viewModel = HomeViewModel()
        
        if case .loading = viewModel.quoteState {
            try #require(true)
        } else {
            try #require(Bool(false))
        }
        
        // When
        await viewModel.fetchQuote()
        
        // Then
        if case let .success(quote) = viewModel.quoteState {
            #expect(quote.author == refQuote.author)
            #expect(quote.quote == refQuote.quote)
        } else {
            #expect(Bool(false), "The ViewModel's state hasn't changed")
        }
    }
}
