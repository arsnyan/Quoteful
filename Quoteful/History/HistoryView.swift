//
//  HistoryView.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import SwiftUI
import FactoryKit

struct HistoryView: View {
    @InjectedObservable(\.historyViewModel) private var viewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.entries) { entry in
                NavigationLink {
                    EntryDetailsView(viewModel: EntryDetailsViewModel(entry: entry))
                        .id(entry.id)
                } label: {
                    Text(entry.mood.emojiRepresentation)
                }
            }
            .navigationTitle("history")
        }
        .task {
            await viewModel.startTrackingEntries()
        }
    }
}

#Preview {
    HistoryView()
}
