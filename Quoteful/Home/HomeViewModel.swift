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
    
    var quoteState: HomeQuoteState = .loading {
        didSet {
            switch quoteState {
            case .failure:
                feedbackWarning.toggle()
            case .success:
                feedbackSuccess.toggle()
            default:
                break
            }
        }
    }
    
    var translationVisible = false
    
    var sheetPresented = false
    
    var feedbackWarning = false
    var feedbackSuccess = false
    
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
        
        self.quoteState = .loading
        
        do {
            let zenQuote = try await quoteClient.fetchTodayQuote()
            self.quoteState = .success(quote: zenQuote)
        } catch {
            self.quoteState = .failure(error: error.localizedDescription)
        }
    }
    
    func sheetTapped() {
        sheetPresented.toggle()
    }
}

extension Container {
    var homeViewModel: Factory<HomeViewModel> {
        self {
            HomeViewModel()
        }
    }
}
