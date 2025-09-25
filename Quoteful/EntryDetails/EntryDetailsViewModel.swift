//
//  EntryDetailsViewModel.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 23.09.2025.
//

import Foundation
import FactoryKit

@Observable
final class EntryDetailsViewModelEditingData {
    // MARK: - UI Properties
    var textInput = "" {
        didSet {
            if !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               textEmptyError {
                textEmptyError.toggle()
            }
        }
    }
    var selectedMood: Mood = .confused
    
    // MARK: - Navigation Properties
    var isViewDismissable: Bool {
        return textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Error UI Properties
    var savingError = false // for both alert, wiggle and feedback
    var textEmptyError = false {
        willSet {
            if textEmptyError, newValue == textEmptyError {
                shakeTextEmpty = true
            }
        }
    }
    var shakeTextEmpty = false
    
    // MARK: - Alert Properties
    var alertDateIsInFuture = false
    
    init(withEntry entry: JournalEntry? = nil) {
        if let entry {
            textInput = entry.text
            selectedMood = entry.mood
        }
    }
}

enum EntryState {
    case editing(data: EntryDetailsViewModelEditingData)
    case viewing(entry: JournalEntry)
}

extension EntryState: Equatable {
    static func == (lhs: EntryState, rhs: EntryState) -> Bool {
        switch (lhs, rhs) {
        case (.editing(let lData), .editing(let rData)):
            return lData.textInput == rData.textInput && lData.selectedMood == rData.selectedMood
        case (.viewing(let lEntry), .viewing(let rEntry)):
            return lEntry == rEntry
        default:
            return false
        }
    }
}

@MainActor
@Observable
class EntryDetailsViewModel {
    @ObservationIgnored
    @Injected(\.journalService) private var journalService
    
    private(set) var entry: JournalEntry? = nil
    
    var state: EntryState
    
    var isDismissable: Bool {
        switch state {
        case .editing(let data):
            return data.isViewDismissable
        case .viewing:
            return true
        }
    }
    
    var navigationTitle: String {
        switch state {
        case .editing:
            String(localized: "writeThoughtsPlaceholder")
        case .viewing:
            String(localized: "details")
        }
    }
    
    var hasUnsavedChanges: Bool {
        guard case .editing(let data) = state,
              !data.textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let entry else { return false }
        return data.textInput != entry.text || data.selectedMood != entry.mood
    }
    
    var showDiscardDialog = false
    
    init(entry: JournalEntry?, isEditing: Bool) {
        if entry == nil, !isEditing {
            fatalError("Entry should not be nil without being in edit mode")
        }
        
        self.entry = entry
        
        if isEditing {
            state = .editing(data: EntryDetailsViewModelEditingData())
        } else {
            state = .viewing(entry: entry!)
        }
    }
    
    convenience init() {
        self.init(entry: nil, isEditing: true)
    }
    
    convenience init(entry: JournalEntry) {
        self.init(entry: entry, isEditing: false)
    }
    
    // That's a bit different from toggleEditMode as it changes
    // to .viewing no matter the current state
    func resetToViewingState() {
        guard let entry else { return }
        state = .viewing(entry: entry)
    }
    
    func toggleEditMode() {
        guard let entry else { return }
        switch state {
        case .editing:
            state = .viewing(entry: entry)
        case .viewing(let entry):
            state = .editing(data: EntryDetailsViewModelEditingData(withEntry: entry))
        }
    }
    
    func saveEntry(completion: () -> Void, animatableHandler: (() -> Void)? = nil) async {
        let initialEntry = entry
        
        if case .editing(let data) = state {
            do {
                if var editedEntry = self.entry {
                    editedEntry.text = data.textInput
                    editedEntry.mood = data.selectedMood
                    
                    try editedEntry.validate()
                    self.entry = try await journalService.saveEntry(editedEntry)
                    animatableHandler?()
                } else {
                    let newEntry = JournalEntry(
                        timestamp: .now,
                        mood: data.selectedMood,
                        text: data.textInput
                    )
                    
                    try newEntry.validate()
                    _ = try await journalService.saveEntry(newEntry)
                    completion()
                }
            } catch let error as JournalEntryValidationError {
                switch error {
                case .emptyText:
                    data.textEmptyError = true
                case .futureDate:
                    data.alertDateIsInFuture = true
                }
                
                entry = initialEntry
            } catch {
                data.savingError.toggle()
                entry = initialEntry
            }
        }
    }
}

