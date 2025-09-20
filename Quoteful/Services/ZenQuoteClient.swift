//
//  ZenQuoteClient.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 19.09.2025.
//

import Foundation
import FactoryKit

enum QuoteError: LocalizedError {
    case emptyResponse
    
    var localizedDescription: String {
        switch self {
        case .emptyResponse:
            "The Zen Quote API returned a response without a single quote but not an error which should not be possible to happen. Check URL in the API enum or the latest API documentation"
        }
    }
}

struct ZenQuoteClient {
    var fetchTodayQuote: () async throws -> ZenQuote
}

extension Container {
    var quoteClient: Factory<ZenQuoteClient> {
        self {
            ZenQuoteClient(
                fetchTodayQuote: {
                    guard let url = URL(string: API.today.rawValue) else {
                        throw URLError(.unsupportedURL)
                    }
                    
                    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                    let (data, _) = try await URLSession.shared.data(for: request)
                    let decoded = try JSONDecoder().decode([ZenQuote].self, from: data)
                    
                    guard let quote = decoded.first else {
                        throw QuoteError.emptyResponse
                    }
                    
                    return quote
                }
            )
        }
    }
}

enum API: String {
    case today = "https://zenquotes.io/api/today"
}

#if DEBUG
import SwiftUI
import Playgrounds

#Playground {
    @Injected(\.quoteClient) var quoteClient
    
    _ = try await quoteClient.fetchTodayQuote()
}
#endif
