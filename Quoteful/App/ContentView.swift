//
//  ContentView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import SwiftUI
import FactoryKit

struct ContentView: View {
    @Injected(\.quoteClient) private var quoteClient
    
    @State private var quote: ZenQuote? = nil
    
    var body: some View {
        VStack {
            Text(quote?.quote ?? "No quote provided")
                .font(.custom("Cochin-BoldItalic", size: 32))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("© " + (quote?.author ?? "Unknown author"))
                .font(.custom("Cochin-Italic", size: 24))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .task {
            quote = try? await quoteClient.fetchTodayQuote()
        }
    }
}

#Preview {
    ContentView()
}
