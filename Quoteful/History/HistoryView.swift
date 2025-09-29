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
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("history")
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage)
                }
                .toolbar { toolbarContent }
        }
        .task {
            await viewModel.startTrackingEntries()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.groupedEntries.isEmpty {
            ContentUnavailableView(
                "No journal entries",
                systemImage: "book.closed",
                description: Text("Your journal entries will appear here")
            )
        } else {
            List {
                ForEach(viewModel.groupedEntries) { group in
                    Section {
                        ForEach(group.entries) { entry in
                            EntryRowItem(entry: entry)
                        }
                        .onDelete { indexSet in
                            viewModel.deleteEntries(groupId: group.id, at: indexSet)
                        }
                    } header: {
                        Text(group.title)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.sortOption)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem {
            Menu {
                sortingMenuContent
            } label: {
                Label("Sort", systemImage: "line.horizontal.3.decrease")
            }
        }
        
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed)
        }
        
        ToolbarItem {
            EditButton()
        }
    }
    
    @ViewBuilder
    private var sortingMenuContent: some View {
        Section("Date & Time") {
            Button(action: { viewModel.updateSorting(.dateNewest) }) {
                CheckmarkedLabel("Newest First", sortOption: .dateNewest)
            }
            
            Button(action: { viewModel.updateSorting(.dateOldest) }) {
                CheckmarkedLabel("Oldest First", sortOption: .dateOldest)
            }
        }
        
        Section("Alphabetical") {
            Button(action: { viewModel.updateSorting(.alphabeticalAZ) }) {
                CheckmarkedLabel("A-Z", sortOption: .alphabeticalAZ)
            }
            
            Button(action: { viewModel.updateSorting(.alphabeticalZA) }) {
                CheckmarkedLabel("Z-A", sortOption: .alphabeticalZA)
            }
        }
        
        Section("Mood") {
            ForEach(Mood.allCases, id: \.self) { mood in
                Button(action: { viewModel.updateSorting(.byMood(mood)) }) {
                    let buttonText = "\(mood.emojiRepresentation) \(mood.rawValue.capitalized)"
                    if viewModel.sortOption.isMood(mood) {
                        Label(
                            buttonText,
                            systemImage: "checkmark"
                        )
                    } else {
                        Text(buttonText)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func CheckmarkedLabel(_ text: any StringProtocol, sortOption: SortOption) -> some View {
        if viewModel.sortOption == sortOption {
            Label(text, systemImage: "checkmark")
        } else {
            Text(text)
        }
    }
}

struct EntryRowItem: View {
    let entry: JournalEntry
    
    var body: some View {
        NavigationLink {
            EntryDetailsView(viewModel: EntryDetailsViewModel(entry: entry))
                .id(entry.id)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Text(entry.mood.emojiRepresentation)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.text)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                    
                    Text(entry.timestamp, style: .time)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(.rect)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.mood.emojiRepresentation), \(entry.text)")
        .accessibilityHint("Tap to view details")
        .accessibilityIdentifier("Item\(entry.id, default: "")")
        .id(entry.id)
    }
}

#Preview {
    HistoryView()
}
