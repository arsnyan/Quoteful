//
//  HistoryViewModel_Tests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 30.09.2025.
//

import Testing
import Foundation
@testable import Quoteful
import FactoryKit
import FactoryTesting

@Suite(.container)
struct HistoryViewModel_Tests {
    init() {
        Container.shared.dbPool.reset()
        Container.shared.dbPool.onTest { try? appDatabase(testEnvironment: true) }
    }
    
    @MainActor
    @Test func `ViewModel tracks entries and changes state if added or deleted entry`() async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        let entryToSave = JournalEntry(id: 1, timestamp: .distantPast, mood: .angry, text: "Test")
        
        _ = try await service.saveEntry(entryToSave)
        
        try #require(viewModel.allEntries.isEmpty)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.allEntries.count == 1)
        #expect(viewModel.allEntries.first! == entryToSave)
        
        _ = try await service.saveEntry(entryToSave)
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.allEntries.count == 1)
        #expect(viewModel.allEntries.first! == entryToSave)
        
        _ = try await service.saveEntry(JournalEntry(timestamp: .init(timeIntervalSince1970: 231245), mood: .happy, text: "Test 2"))
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.allEntries.count == 2)
        
        _ = try await service.deleteEntry(entryToSave)
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.allEntries.count == 1)
        
        trackingTask.cancel()
    }
    
    // MARK: - Date Sorting Tests
    
    @MainActor
    @Test func `Sort by dateNewest shows most recent entries first`() async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        // Create entries with different timestamps
        let oldEntry = JournalEntry(
            id: 1,
            timestamp: Date(timeIntervalSince1970: 1000000000), // Sep 2001
            mood: .neutral,
            text: "Old entry"
        )
        let middleEntry = JournalEntry(
            id: 2,
            timestamp: Date(timeIntervalSince1970: 1500000000), // Jul 2017
            mood: .happy,
            text: "Middle entry"
        )
        let recentEntry = JournalEntry(
            id: 3,
            timestamp: Date(timeIntervalSince1970: 1700000000), // Nov 2023
            mood: .sad,
            text: "Recent entry"
        )
        
        _ = try await service.saveEntry(oldEntry)
        _ = try await service.saveEntry(middleEntry)
        _ = try await service.saveEntry(recentEntry)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        viewModel.updateSorting(.dateNewest)
        
        try await Task.sleep(for: .milliseconds(50))
        
        #expect(viewModel.groupedEntries.count >= 1)
        
        // Verify that entries are sorted newest to oldest
        let allEntriesInOrder = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntriesInOrder.first?.id == recentEntry.id)
        #expect(allEntriesInOrder.last?.id == oldEntry.id)
        
        // Verify timestamps are in descending order
        for i in 0..<(allEntriesInOrder.count - 1) {
            #expect(allEntriesInOrder[i].timestamp >= allEntriesInOrder[i + 1].timestamp)
        }
        
        trackingTask.cancel()
    }
    
    @MainActor
    @Test func `Sort by dateOldest shows oldest entries first`() async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        let oldEntry = JournalEntry(
            id: 1,
            timestamp: Date(timeIntervalSince1970: 1000000000),
            mood: .neutral,
            text: "Old entry"
        )
        let middleEntry = JournalEntry(
            id: 2,
            timestamp: Date(timeIntervalSince1970: 1500000000),
            mood: .happy,
            text: "Middle entry"
        )
        let recentEntry = JournalEntry(
            id: 3,
            timestamp: Date(timeIntervalSince1970: 1700000000),
            mood: .sad,
            text: "Recent entry"
        )
        
        _ = try await service.saveEntry(oldEntry)
        _ = try await service.saveEntry(middleEntry)
        _ = try await service.saveEntry(recentEntry)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        viewModel.updateSorting(.dateOldest)
        
        try await Task.sleep(for: .milliseconds(50))
        
        #expect(viewModel.groupedEntries.count >= 1)
        
        // Verify that entries are sorted oldest to newest
        let allEntriesInOrder = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntriesInOrder.first?.id == oldEntry.id)
        #expect(allEntriesInOrder.last?.id == recentEntry.id)
        
        // Verify timestamps are in ascending order
        for i in 0..<(allEntriesInOrder.count - 1) {
            #expect(allEntriesInOrder[i].timestamp <= allEntriesInOrder[i + 1].timestamp)
        }
        
        trackingTask.cancel()
    }
    
    // MARK: - Alphabetical Sorting Tests
    
    @MainActor
    @Test func `Sort by alphabeticalAZ shows entries in A-Z order`() async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        let appleEntry = JournalEntry(
            id: 1,
            timestamp: Date(),
            mood: .happy,
            text: "Apple is great"
        )
        let bananaEntry = JournalEntry(
            id: 2,
            timestamp: Date(),
            mood: .neutral,
            text: "Banana bread"
        )
        let cherryEntry = JournalEntry(
            id: 3,
            timestamp: Date(),
            mood: .sad,
            text: "Cherry pie"
        )
        let zebraEntry = JournalEntry(
            id: 4,
            timestamp: Date(),
            mood: .confused,
            text: "Zebra crossing"
        )
        
        _ = try await service.saveEntry(zebraEntry)
        _ = try await service.saveEntry(bananaEntry)
        _ = try await service.saveEntry(appleEntry)
        _ = try await service.saveEntry(cherryEntry)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        viewModel.updateSorting(.alphabeticalAZ)
        
        try await Task.sleep(for: .milliseconds(50))
        
        #expect(viewModel.groupedEntries.count >= 1)
        
        // Verify groups are sorted alphabetically
        let groupTitles = viewModel.groupedEntries.map { $0.title }
        let sortedGroupTitles = groupTitles.sorted()
        #expect(groupTitles == sortedGroupTitles)
        
        // Verify entries within each group are sorted alphabetically
        for group in viewModel.groupedEntries {
            let texts = group.entries.map { $0.text }
            let sortedTexts = texts.sorted()
            #expect(texts == sortedTexts)
        }
        
        // Verify specific order
        let allEntriesInOrder = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntriesInOrder[0].text == "Apple is great")
        #expect(allEntriesInOrder[1].text == "Banana bread")
        #expect(allEntriesInOrder[2].text == "Cherry pie")
        #expect(allEntriesInOrder[3].text == "Zebra crossing")
        
        trackingTask.cancel()
    }
    
    @MainActor
    @Test func `Sort by alphabeticalZA shows entries in Z-A order`() async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        let appleEntry = JournalEntry(
            id: 1,
            timestamp: Date(),
            mood: .happy,
            text: "Apple is great"
        )
        let bananaEntry = JournalEntry(
            id: 2,
            timestamp: Date(),
            mood: .neutral,
            text: "Banana bread"
        )
        let cherryEntry = JournalEntry(
            id: 3,
            timestamp: Date(),
            mood: .sad,
            text: "Cherry pie"
        )
        let zebraEntry = JournalEntry(
            id: 4,
            timestamp: Date(),
            mood: .confused,
            text: "Zebra crossing"
        )
        
        _ = try await service.saveEntry(appleEntry)
        _ = try await service.saveEntry(bananaEntry)
        _ = try await service.saveEntry(cherryEntry)
        _ = try await service.saveEntry(zebraEntry)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        viewModel.updateSorting(.alphabeticalZA)
        
        try await Task.sleep(for: .milliseconds(50))
        
        #expect(viewModel.groupedEntries.count >= 1)
        
        // Verify groups are sorted reverse alphabetically
        let groupTitles = viewModel.groupedEntries.map { $0.title }
        let reverseSortedGroupTitles = groupTitles.sorted(by: >)
        #expect(groupTitles == reverseSortedGroupTitles)
        
        // Verify entries within each group are sorted reverse alphabetically
        for group in viewModel.groupedEntries {
            let texts = group.entries.map { $0.text }
            let reverseSortedTexts = texts.sorted(by: >)
            #expect(texts == reverseSortedTexts)
        }
        
        // Verify specific order
        let allEntriesInOrder = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntriesInOrder[0].text == "Zebra crossing")
        #expect(allEntriesInOrder[1].text == "Cherry pie")
        #expect(allEntriesInOrder[2].text == "Banana bread")
        #expect(allEntriesInOrder[3].text == "Apple is great")
        
        trackingTask.cancel()
    }
    
    // MARK: - Mood Sorting Tests
    
    @MainActor
    @Test func `Sort by mood angry filters and shows only angry entries`() async throws {
        try await testMoodSorting(mood: .angry)
    }
    
    @MainActor
    @Test func `Sort by mood sad filters and shows only sad entries`() async throws {
        try await testMoodSorting(mood: .sad)
    }
    
    @MainActor
    @Test func `Sort by mood confused filters and shows only confused entries`() async throws {
        try await testMoodSorting(mood: .confused)
    }
    
    @MainActor
    @Test func `Sort by mood neutral filters and shows only neutral entries`() async throws {
        try await testMoodSorting(mood: .neutral)
    }
    
    @MainActor
    @Test func `Sort by mood happy filters and shows only happy entries`() async throws {
        try await testMoodSorting(mood: .happy)
    }
    
    @MainActor
    private func testMoodSorting(mood: Mood) async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        // Create entries with all different moods
        let angryEntry = JournalEntry(
            id: 1,
            timestamp: Date(timeIntervalSince1970: 1700000000),
            mood: .angry,
            text: "Angry entry"
        )
        let sadEntry = JournalEntry(
            id: 2,
            timestamp: Date(timeIntervalSince1970: 1700000100),
            mood: .sad,
            text: "Sad entry"
        )
        let confusedEntry = JournalEntry(
            id: 3,
            timestamp: Date(timeIntervalSince1970: 1700000200),
            mood: .confused,
            text: "Confused entry"
        )
        let neutralEntry = JournalEntry(
            id: 4,
            timestamp: Date(timeIntervalSince1970: 1700000300),
            mood: .neutral,
            text: "Neutral entry"
        )
        let happyEntry = JournalEntry(
            id: 5,
            timestamp: Date(timeIntervalSince1970: 1700000400),
            mood: .happy,
            text: "Happy entry"
        )
        
        // Add a second entry for the target mood to verify filtering
        let secondTargetMoodEntry = JournalEntry(
            id: 6,
            timestamp: Date(timeIntervalSince1970: 1700000500),
            mood: mood,
            text: "Second \(mood) entry"
        )
        
        _ = try await service.saveEntry(angryEntry)
        _ = try await service.saveEntry(sadEntry)
        _ = try await service.saveEntry(confusedEntry)
        _ = try await service.saveEntry(neutralEntry)
        _ = try await service.saveEntry(happyEntry)
        _ = try await service.saveEntry(secondTargetMoodEntry)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        viewModel.updateSorting(.byMood(mood))
        
        try await Task.sleep(for: .milliseconds(50))
        
        // Verify only entries with the target mood are shown
        let allEntriesInGroups = viewModel.groupedEntries.flatMap { $0.entries }
        
        // Should have exactly 2 entries (the original and the second one)
        #expect(allEntriesInGroups.count == 2)
        
        // Verify all entries have the correct mood
        for entry in allEntriesInGroups {
            #expect(entry.mood == mood)
        }
        
        // Verify entries are sorted by date (newest first within mood)
        #expect(allEntriesInGroups.first?.id == secondTargetMoodEntry.id)
        
        // Verify timestamps are in descending order
        if allEntriesInGroups.count > 1 {
            for i in 0..<(allEntriesInGroups.count - 1) {
                #expect(allEntriesInGroups[i].timestamp >= allEntriesInGroups[i + 1].timestamp)
            }
        }
        
        trackingTask.cancel()
    }
    
    // MARK: - Edge Cases
    
    @MainActor
    @Test func `Sort by mood with no matching entries shows empty groups`() async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        // Create entries with moods other than happy
        let angryEntry = JournalEntry(
            id: 1,
            timestamp: Date(),
            mood: .angry,
            text: "Angry entry"
        )
        let sadEntry = JournalEntry(
            id: 2,
            timestamp: Date(),
            mood: .sad,
            text: "Sad entry"
        )
        
        _ = try await service.saveEntry(angryEntry)
        _ = try await service.saveEntry(sadEntry)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        viewModel.updateSorting(.byMood(.happy))
        
        try await Task.sleep(for: .milliseconds(50))
        
        // Verify no entries are shown
        let allEntriesInGroups = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntriesInGroups.isEmpty)
        
        trackingTask.cancel()
    }
    
    @MainActor
    @Test func `Sorting persists when switching between options`() async throws {
        let service = Container.shared.journalService.resolve()
        let viewModel = HistoryViewModel()
        
        let appleEntry = JournalEntry(
            id: 1,
            timestamp: Date(timeIntervalSince1970: 1000000000),
            mood: .happy,
            text: "Apple"
        )
        let zebraEntry = JournalEntry(
            id: 2,
            timestamp: Date(timeIntervalSince1970: 1700000000),
            mood: .sad,
            text: "Zebra"
        )
        
        _ = try await service.saveEntry(appleEntry)
        _ = try await service.saveEntry(zebraEntry)
        
        let trackingTask = Task {
            await viewModel.startTrackingEntries()
        }
        
        try await Task.sleep(for: .milliseconds(100))
        
        // Test dateNewest
        viewModel.updateSorting(.dateNewest)
        try await Task.sleep(for: .milliseconds(50))
        var allEntries = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntries.first?.id == zebraEntry.id)
        
        // Test alphabeticalAZ
        viewModel.updateSorting(.alphabeticalAZ)
        try await Task.sleep(for: .milliseconds(50))
        allEntries = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntries.first?.text == "Apple")
        
        // Test byMood
        viewModel.updateSorting(.byMood(.happy))
        try await Task.sleep(for: .milliseconds(50))
        allEntries = viewModel.groupedEntries.flatMap { $0.entries }
        #expect(allEntries.count == 1)
        #expect(allEntries.first?.mood == .happy)
        
        trackingTask.cancel()
    }
}
