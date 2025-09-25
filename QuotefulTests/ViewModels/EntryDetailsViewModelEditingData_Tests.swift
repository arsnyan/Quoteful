//
//  EntryDetailsViewModelEditingData_Tests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 25.09.2025.
//

import Testing
@testable import Quoteful
import Foundation

@Suite
struct EntryDetailsViewModelEditingData_Tests {
    @Test
    func `shakeTextEmpty doesn't toggle when saving with empty text initially`() async throws {
        // Given
        let viewModel = EntryDetailsViewModelEditingData()
        
        // When
        viewModel.textEmptyError = true
        viewModel.textEmptyError = false
        viewModel.textEmptyError = true
        
        // Then
        #expect(!viewModel.shakeTextEmpty)
    }
    
    @Test
    func `shakeTextEmpty toggles when saving with empty text repeatedly`() async throws {
        // Given
        let viewModel = EntryDetailsViewModelEditingData()
        
        // When
        viewModel.textEmptyError = true
        viewModel.textEmptyError = false
        viewModel.textEmptyError = true
        viewModel.textEmptyError = true
        
        try await Task.sleep(for: .seconds(0.5))
        
        // Then
        #expect(viewModel.shakeTextEmpty)
    }
    
    @Test
    func `textEmptyError toggles when text is no longer empty`() async throws {
        // Given
        let viewModel = EntryDetailsViewModelEditingData()
        
        // When
        viewModel.textInput = ""
        viewModel.textEmptyError = true
        viewModel.textInput = "Something"
        
        // Then
        #expect(!viewModel.textEmptyError)
    }
    
    @Test(arguments: [nil, "1", ""])
    func `isViewDismissible is equal text being empty or not`(text: String? = nil) async throws {
        let text = text ?? ""
        // Given
        let viewModel = EntryDetailsViewModelEditingData()
        
        // When
        viewModel.textInput = text
        
        // Then
        #expect(viewModel.isViewDismissable == text.isEmpty)
    }
    
    @Test
    func `View Model loads data from entry if it is passed`() {
        // Given
        let entry = JournalEntry(
            timestamp: .now,
            mood: .happy,
            text: "Happy"
        )
        
        // When
        let viewModel = EntryDetailsViewModelEditingData(withEntry: entry)
        
        // Then
        #expect(viewModel.textInput == entry.text)
        #expect(viewModel.selectedMood == entry.mood)
    }
}
