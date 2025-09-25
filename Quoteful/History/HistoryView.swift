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
            let entries = Dictionary(grouping: viewModel.entries, by: \.timestamp.startOfDay)
                .mapValues { entries in
                    entries.sorted { $0.timestamp > $1.timestamp }
                }
                .sorted(by: { $0.key > $1.key })
            
            List {
                ForEach(entries, id: \.key) { date, days in
                    Section {
                        ForEach(days) { entry in
                            RowItem(entry: entry)
                        }
                    } header: {
                        Text(date.formatted(.dateTime.year().month().day()))
                    }
                }
            }
            .navigationTitle("history")
        }
        .task {
            await viewModel.startTrackingEntries()
        }
    }
    
    @ViewBuilder func RowItem(entry: JournalEntry) -> some View {
        NavigationLink {
            EntryDetailsView(viewModel: EntryDetailsViewModel(entry: entry))
                .id(entry.id)
        } label: {
            HStack(alignment: .top) {
                Text(entry.mood.emojiRepresentation)
                VStack(alignment: .leading) {
                    Text(entry.text)
                        .lineLimit(2)
                    Text(entry.timestamp, style: .time)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityIdentifier("Item\(entry.id, default: "")")
        .id(entry.id)
    }
}

#Preview {
    HistoryView()
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
