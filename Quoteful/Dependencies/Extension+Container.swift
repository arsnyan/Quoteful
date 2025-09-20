//
//  Extension+Container.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 20.09.2025.
//

import FactoryKit

extension Container: @retroactive AutoRegistering {
    public func autoRegister() {
        #if DEBUG
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
        #endif
    }
}
