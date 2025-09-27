//
//  EntryDetailsViewModel_Tests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 25.09.2025.
//

import Testing
import Foundation
@testable import Quoteful
import FactoryKit
import FactoryTesting
import GRDB

@Suite
@MainActor
struct EntryDetailsViewModel_Tests {
    init() {
        Container.shared.dbPool.reset()
        Container.shared.dbPool.onTest { try? appDatabase(testEnvironment: true) }
    }
    
    @Test(
        arguments: [
            nil,
            JournalEntry(timestamp: .distantPast, mood: .confused, text: "Test"),
            JournalEntry(timestamp: .distantPast, mood: .confused, text: "Test")
        ],
        [
            true,
            false,
            true
        ]
    ) func `hasUnsavedChanges returns true when conditions are met`(entry: JournalEntry?, isEditing: Bool) async throws {
        switch (entry, isEditing) {
        case (.none, true):
            let model = EntryDetailsViewModel(entry: entry, isEditing: isEditing)
            switch model.state {
            case .editing:
                #expect(!model.hasUnsavedChanges)
            case .viewing:
                #expect(Bool(false), "ViewModel shouldn't be in viewing mode as it has no entry")
            }
        case (.some(let entry), false):
            let model = EntryDetailsViewModel(entry: entry, isEditing: isEditing)
            switch model.state {
            case .editing:
                #expect(Bool(false), "ViewModel shouldn't be in editing mode")
            case .viewing:
                #expect(!model.hasUnsavedChanges)
            }
        case (.some(let entry), true):
            let model = EntryDetailsViewModel(entry: entry, isEditing: isEditing)
            switch model.state {
            case .editing(let data):
                #expect(!model.hasUnsavedChanges)
                
                data.textInput = "Test changed"
                #expect(model.hasUnsavedChanges)
                
                data.textInput = "   "
                #expect(!model.hasUnsavedChanges)
                
                data.textInput = ""
                #expect(!model.hasUnsavedChanges)
                
                data.textInput = "Test changed again"
                #expect(model.hasUnsavedChanges)
                
                data.textInput = "Test"
                #expect(!model.hasUnsavedChanges)
            case .viewing:
                #expect(Bool(false), "The purpose of this test is to test VM in editing state")
            }
        default:
            break
        }
    }
    
    @Test(
        arguments: [
            nil, JournalEntry(timestamp: .distantPast, mood: .angry, text: "Test"),
        ], [
            true, true
        ]
    ) func `resetToViewingState sets state to viewing when editing existing one`(entry: JournalEntry?, isEditing: Bool) async throws {
        // Given
        let viewModel = EntryDetailsViewModel(entry: entry, isEditing: isEditing)
        
        switch viewModel.state {
        case .editing:
            #expect(true)
        case .viewing:
            #expect(Bool(false), "Such condition should be unreachable: \(viewModel.state)")
        }
        
        // When
        viewModel.resetToViewingState()
        
        // Then
        if viewModel.entry != nil {
            switch viewModel.state {
            case .editing:
                #expect(Bool(false), "Condition hasn't been met: \(viewModel)")
            case .viewing:
                #expect(true)
            }
        } else {
            switch viewModel.state {
            case .editing:
                #expect(true)
            case .viewing:
                #expect(Bool(false), "State shouldn't be .viewing for a screen without a provided initial entry")
            }
        }
    }
    
    @Test(
        arguments: [
            nil,
            JournalEntry(
                timestamp: .distantPast,
                mood: .angry,
                text: "Meh"
            ),
            JournalEntry(timestamp: .distantPast, mood: .angry, text: "Meh")
        ], [
            true, false, true
        ]
    )
    func `toggleEditMode with a state`(entry: JournalEntry?, isEditing: Bool) async throws {
        switch (entry, isEditing) {
        case (.none, true):
            // Given
            let model = EntryDetailsViewModel(entry: entry, isEditing: isEditing)
            
            // When
            model.toggleEditMode()
            
            // Then
            switch model.state {
            case .editing:
                #expect(true)
            case .viewing:
                #expect(Bool(false), "ViewModel shouldn't be able to be in viewing mode as it has no entry")
            }
        case (.some(let entry), false):
            // Given
            let model = EntryDetailsViewModel(entry: entry, isEditing: isEditing)
            
            // When
            model.toggleEditMode()
            
            // Then
            switch model.state {
            case .editing:
                #expect(true)
            case .viewing:
                #expect(Bool(false), "When viewing an entry and toggling to edit mode, we should be in edit mode")
            }
        case (.some(let entry), true):
            // Given
            let model = EntryDetailsViewModel(entry: entry, isEditing: isEditing)
            
            // When
            model.toggleEditMode()
            
            // Then
            switch model.state {
            case .editing:
                #expect(Bool(false), "When editing an existing entry and toggling to viewing mode, we should be in viewing mode")
            case .viewing:
                #expect(true)
            }
        default:
            break
        }
    }
    
    @Test
    func `saveEntry sets textEmptyError true if validation failed with it`() async throws {
        // Given
        let viewModel = EntryDetailsViewModel()
        
        // When
        await viewModel.saveEntry {}
        
        // Then
        switch viewModel.state {
        case .editing(let data):
            #expect(data.textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(data.textEmptyError)
            #expect(viewModel.entry == nil)
            #expect(!data.savingError)
            #expect(!data.alertDateIsInFuture)
        case .viewing:
            #expect(Bool(false), "saveEntry shouldn't change state if it fails")
        }
    }
    
    @Test(.container)
    func `saveEntry sets savingError true if storage service failed`() async throws {
        // Given
        Container.shared.journalService.reset()
        Container.shared.journalService.register {
            JournalStorageService(
                saveEntry: { entry in
                    throw URLError(.badURL)
                },
                fetchEntryById: { id in fatalError() },
                deleteEntry: { entry in fatalError() }
            )
        }
        
        let viewModel = EntryDetailsViewModel(entry: JournalEntry(timestamp: .distantPast, mood: .angry, text: "Test"), isEditing: true)
        
        let initialEntry = viewModel.entry
        
        switch viewModel.state {
        case .editing(let data):
            data.textInput = "Something else"
            data.selectedMood = .happy
        case .viewing:
            #expect(Bool(false), "Test should be done in viewing mode")
        }
        
        // When
        await viewModel.saveEntry {}
        
        // Then
        switch viewModel.state {
        case .editing(let data):
            #expect(data.savingError)
            #expect(viewModel.entry == initialEntry)
            #expect(!data.alertDateIsInFuture)
        case .viewing:
            #expect(Bool(false), "saveEntry shouldn't change state if it fails")
        }
    }
    
    @Test(.container)
    func `saveEntry makes a new entry in the db and doesn't change state if creating new entry`() async throws {
        @Injected(\.dbPool) var db
        
        let initialDbFetch = try await db!.read(JournalEntry.fetchAll)
        
        let viewModel = EntryDetailsViewModel()
        
        let textInput = "Something new"
        let selectedMood: Mood = .happy
        
        switch viewModel.state {
        case .editing(let data):
            data.textInput = textInput
            data.selectedMood = selectedMood
        case .viewing:
            #expect(Bool(false), "Test should be done in viewing mode")
        }
        
        // When
        await viewModel.saveEntry {}
        
        let newDbFetch = try await db!.read(JournalEntry.fetchAll)
        
        // Then
        switch viewModel.state {
        case .editing(let data):
            #expect(!data.savingError)
            #expect(!data.textEmptyError)
            #expect(!data.alertDateIsInFuture)
            #expect(!data.shakeTextEmpty)
            
            #expect(viewModel.entry == nil)
            
            #expect(newDbFetch.count > initialDbFetch.count)
            #expect(newDbFetch.last!.text == textInput)
            #expect(newDbFetch.last!.mood == selectedMood)
            try? await Task.sleep(for: .seconds(1))
            #expect(newDbFetch.last!.timestamp < Date())
        case .viewing:
            #expect(Bool(false), "saveEntry shouldn't change state if it makes a new entry instead of editing existing one")
        }
    }
    
    @Test(.container)
    func `saveEntry updates existing entry in the db and changes state if updating an entry`() async throws {
        @Injected(\.dbPool) var db
        
        let savedEntry = try await db!.write { db in
            try JournalEntry(timestamp: .distantPast, mood: .happy, text: "Test").saveAndFetch(db)
        }
        
        let initialDbFetch = try await db!.read(JournalEntry.fetchAll)
        
        try #require(initialDbFetch.count == 1)
        
        let viewModel = EntryDetailsViewModel(entry: savedEntry, isEditing: true)
        
        let textInput = "Something new"
        
        switch viewModel.state {
        case .editing(let data):
            data.textInput = textInput
            data.selectedMood = savedEntry.mood
        case .viewing:
            #expect(Bool(false), "Test should be done in viewing mode")
        }
        
        // When
        await viewModel.saveEntry {}
        
        let newDbFetch = try await db!.read(JournalEntry.fetchAll)
        
        // Then
        switch viewModel.state {
        case .editing(let data):
            #expect(!data.savingError)
            #expect(!data.textEmptyError)
            #expect(!data.alertDateIsInFuture)
            #expect(!data.shakeTextEmpty)
            
            #expect(newDbFetch.count == initialDbFetch.count)
            #expect(newDbFetch.last!.text == textInput)
            #expect(newDbFetch.last!.mood == savedEntry.mood)
            #expect(newDbFetch.last!.timestamp == savedEntry.timestamp)
            
            #expect(viewModel.entry == newDbFetch.last!)
        case .viewing:
            #expect(Bool(false), "saveEntry shouldn't change state if it makes a new entry instead of editing existing one")
        }
    }
}
