//
//  HomeViewModel.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import Foundation
import FactoryKit

enum HomeQuoteState {
    case loading
    case failure(error: Error)
    case success(quote: ZenQuote)
}

@MainActor
@Observable
final class HomeViewModel {
    @ObservationIgnored
    @Injected(\.quoteClient) private var quoteClient
    
    @ObservationIgnored
    @Injected(\.networkMonitor) private var networkMonitor
    
    var quoteState: HomeQuoteState = .loading
    
    func fetchQuote() async {
        guard await networkMonitor.isConnected else {
            self.quoteState = .failure(error: NetworkError.noInternetConnection)
            return
        }
        
        self.quoteState = .loading
        
        do {
            let zenQuote = try await quoteClient.fetchTodayQuote()
            self.quoteState = .success(quote: zenQuote)
        } catch {
            self.quoteState = .failure(error: error)
        }
    }
}

