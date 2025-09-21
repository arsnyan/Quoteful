//
//  JournalStorageService_Tests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 21.09.2025.
//

import Foundation
import Testing
@testable import Quoteful
import FactoryKit
import FactoryTesting
import GRDB

@Suite(.container)
struct JournalStorageService_Tests {
    @Test
    func `JournalEntry throws error when entry text is empty`() throws {
        // Given
        let entry = JournalEntry(
            id: nil,
            timestamp: Date.now,
            mood: .neutral,
            text: ""
        )
        
        // Then
        #expect(throws: JournalEntryValidationError.emptyText) {
            // When
            try entry.validate()
        }
    }
    
    @Test
    func `JournalEntry throws error when entry date is in future`() throws {
        // Given
        let entry = JournalEntry(
            id: nil,
            timestamp: Date.distantFuture,
            mood: .neutral,
            text: "This entry isn't correct"
        )
        
        // Then
        #expect(throws: JournalEntryValidationError.futureDate) {
            // When
            try entry.validate()
        }
    }
    
    @Test
    func `JournalEntry doesn't throws error when entry date is in past`() throws {
        // Given
        let entry = JournalEntry(
            id: nil,
            timestamp: Date.distantPast,
            mood: .neutral,
            text: "This entry is correct"
        )
        
        // When
        let validate: ()? = try? entry.validate()
        
        // Then
        #expect(validate != nil)
    }
    
    @Test
    func `JournalEntry doesn't throws error when entry date is in right now`() throws {
        // Given
        let entry = JournalEntry(
            id: nil,
            timestamp: Date.now,
            mood: .neutral,
            text: "This entry is correct"
        )
        
        // When
        let validate: ()? = try? entry.validate()
        
        // Then (race condition shouldn't happen)
        #expect(validate != nil)
    }
    
    struct IntegrationTests {
        @Injected(\.journalService) private var journalService
        
        @Test(.tags(.integration))
        func `journalService doesn't create entry if invalid`() async throws {
            await #expect(throws: JournalEntryValidationError.self) {
                try await journalService.createEntry(
                    JournalEntry(
                        id: nil,
                        timestamp: .distantFuture,
                        mood: .neutral,
                        text: "This entry is incorrect"
                    )
                )
            }
        }
        
        @Test(.tags(.integration))
        func `journalService creates and returns entry`() async throws {
            // Given
            let initialEntry = JournalEntry(
                id: nil,
                timestamp: .now,
                mood: .neutral,
                text: "This entry is correct"
            )
            
            // When
            let entry = try await journalService.createEntry(initialEntry)
            
            // Then
            #expect(abs(entry.timestamp.timeIntervalSince(initialEntry.timestamp)) < 0.001)
            #expect(entry.mood == initialEntry.mood)
            #expect(entry.text == initialEntry.text)
        }
        
        @Test(.tags(.integration))
        func `journalService update and returns same entry ID after change`() async throws {
            // Given
            let initialEntry = JournalEntry(
                id: nil,
                timestamp: .now,
                mood: .neutral,
                text: "This entry is correct"
            )
            
            // When
            var entry = try await journalService.createEntry(initialEntry)
            let preChange = entry
            entry.text = "This is a test change of the text"
            
            _ = try await journalService.updateEntry(entry)
            
            // Then
            #expect(entry.id == preChange.id)
            #expect(abs(entry.timestamp.timeIntervalSince(preChange.timestamp)) < 0.001)
            #expect(entry.mood == preChange.mood)
            #expect(entry.text != preChange.text)
        }
        
        @Test(.tags(.integration, .testIsolationCheck))
        func `journalService database is local for each test`() async throws {
            // Given
            @Injected(\.dbPool) var dbPool
            
            // When
            let entries = try await dbPool?.read(JournalEntry.fetchAll)
            try #require(entries != nil)
            
            // Then
            #expect(entries!.isEmpty)
        }
        
        @Test(.tags(.integration))
        func `journalService deletes entry`() async throws {
            // Given
            let initialEntry = JournalEntry(
                id: nil,
                timestamp: .now,
                mood: .neutral,
                text: "This entry is correct"
            )
            
            // When
            let entry = try await journalService.createEntry(initialEntry)
            let preDeletion = entry
            
            let isDeleted = try await journalService.deleteEntry(entry)
            
            // Then
            #expect(isDeleted)
            
            #expect(abs(entry.timestamp.timeIntervalSince(initialEntry.timestamp)) < 0.001)
            #expect(entry.mood == initialEntry.mood)
            #expect(entry.text == initialEntry.text)
            
            try #require(preDeletion.id != nil)
            
            await #expect(throws: Error.self) {
                _ = try await journalService.fetchEntryById(preDeletion.id!)
            }
        }
    }
}
