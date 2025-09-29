//
//  HistoryViewModel.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 24.09.2025.
//

import Foundation
import GRDB
import FactoryKit
import OSLog

enum SortOption: Equatable {
    case dateNewest
    case dateOldest
    case alphabeticalAZ
    case alphabeticalZA
    case byMood(Mood)
    
    func isMood(_ mood: Mood) -> Bool {
        if case .byMood(let selectedMood) = self {
            return selectedMood == mood
        }
        return false
    }
}

struct EntryGroup: Identifiable {
    let id: String
    let title: String
    let entries: [JournalEntry]
}

@Observable
class HistoryViewModel {
    // MARK: - Dependencies
    @ObservationIgnored
    @Injected(\.dbPool) private var dbPool
    
    @ObservationIgnored
    @Injected(\.journalService) private var journalService
    
    private let logger = Logger(subsystem: "Quoteful", category: "HistoryViewModel")
    
    // MARK: - States
    private var allEntries: [JournalEntry] = []
    private(set) var groupedEntries: [EntryGroup] = []
    private(set) var sortOption: SortOption = .dateNewest
    
    var showError = false
    private(set) var errorMessage = ""
    
    // MARK: - Live Updates
    func startTrackingEntries() async {
        guard let dbPool else { return }
        
        let observation = ValueObservation.tracking(JournalEntry.fetchAll)
        
        do {
            for try await entries in observation.values(in: dbPool) {
                self.allEntries = entries
                applyCurrentSorting()
            }
        } catch {
            logger.error("Failed to observe entries: \(error.localizedDescription)")
            showError(error.localizedDescription)
        }
    }
    
    func updateSorting(_ option: SortOption) {
        sortOption = option
        applyCurrentSorting()
    }
    
    // MARK: - Deletion
    @MainActor
    func deleteEntries(groupId: String, at offsets: IndexSet) {
        guard let group = groupedEntries.first(where: { $0.id == groupId }) else {
            logger.warning("Group not found: \(groupId)")
            return
        }
        
        let entriesToDelete = offsets.map { group.entries[$0] }
        
        Task {
            await deleteEntriesAsync(entriesToDelete)
        }
    }
    
    private func deleteEntriesAsync(_ entries: [JournalEntry]) async {
        for entry in entries {
            do {
                _ = try await journalService.deleteEntry(entry)
                logger.info("Deleted entry: \(entry.id ?? -1)")
            } catch {
                logger.error("Failed to delete entry: \(error.localizedDescription)")
                showError("Failed to delete entry: \(error.localizedDescription)")
            }
        }
    }
    
    private func applyCurrentSorting() {
        groupedEntries = sortAndGroupEntries(allEntries, by: sortOption)
    }
    
    private func sortAndGroupEntries(_ entries: [JournalEntry], by option: SortOption) -> [EntryGroup] {
        switch option {
        case .dateNewest, .dateOldest:
            return groupEntriesByDate(entries, ascending: option == .dateOldest)
        case .alphabeticalAZ, .alphabeticalZA:
            return groupEntriesAlphabetically(entries, ascending: option == .alphabeticalAZ)
        case .byMood(let mood):
            return groupEntriesByMood(entries, targetMood: mood)
        }
    }
    
    private func groupEntriesByDate(_ entries: [JournalEntry], ascending: Bool) -> [EntryGroup] {
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
        
        let sortedDates = grouped.keys.sorted(by: ascending ? (<) : (>))
        
        return sortedDates.map { date in
            let dayEntries = grouped[date]!.sorted {
                ascending
                ? $0.timestamp < $1.timestamp
                : $0.timestamp > $1.timestamp
            }
            
            return EntryGroup(
                id: date.ISO8601Format(),
                title: formatDate(date),
                entries: dayEntries
            )
        }
    }
    
    private func groupEntriesAlphabetically(_ entries: [JournalEntry], ascending: Bool) -> [EntryGroup] {
        let grouped = Dictionary(grouping: entries) { entry in
            String(entry.text.prefix(1).uppercased())
        }
        
        let sortedKeys = grouped.keys.sorted(by: ascending ? (<) : (>))
        
        return sortedKeys.map { letter in
            let letterEntries = grouped[letter]!.sorted {
                ascending
                ? $0.text < $1.text
                : $0.text > $1.text
            }
            
            return EntryGroup(
                id: letter,
                title: letter,
                entries: letterEntries
            )
        }
    }
    
    private func groupEntriesByMood(_ entries: [JournalEntry], targetMood: Mood) -> [EntryGroup] {
        let moodEntries = entries.filter { $0.mood == targetMood }
        
        return groupEntriesByDate(moodEntries, ascending: false)
    }
    
    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return String(localized: "Today")
        } else if Calendar.current.isDateInYesterday(date) {
            return String(localized: "Yesterday")
        } else {
            return date.formatted(.dateTime.year().month().day().weekday())
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
}

extension Container {
    var historyViewModel: Factory<HistoryViewModel> {
        self {
            HistoryViewModel()
        }
        .singleton
    }
}
