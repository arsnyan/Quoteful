//
//  HomeViewModel.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import Foundation
import FactoryKit
import SwiftUI

enum HomeQuoteState {
    case loading
    case failure(error: String)
    case success(quote: ZenQuote)
}

extension HomeQuoteState: Equatable {}

@Observable
final class HomeViewModel {
    @ObservationIgnored
    @Injected(\.quoteClient) private var quoteClient
    
    @ObservationIgnored
    @Injected(\.networkMonitor) private var networkMonitor
    
    var quoteState: HomeQuoteState = .loading
    
    func fetchQuote() async {
        if case .success = quoteState {
            return
        }
        
        guard await networkMonitor.isConnected else {
            self.quoteState = .failure(
                error: NetworkError.noInternetConnection.localizedDescription
            )
            return
        }
        
        withAnimation(.spring(duration: 0.15, bounce: 0.1)) {
            self.quoteState = .loading
        }
        
        do {
            let zenQuote = try await quoteClient.fetchTodayQuote()
            withAnimation(.spring(duration: 0.2, bounce: 0.1)) {
                self.quoteState = .success(quote: zenQuote)
            }
        } catch {
            withAnimation(.spring(duration: 0.15, bounce: 0.1)) {
                self.quoteState = .failure(error: error.localizedDescription)
            }
        }
    }
}

extension Container {
    var homeViewModel: Factory<HomeViewModel> {
        self {
            HomeViewModel()
        }
    }
}
