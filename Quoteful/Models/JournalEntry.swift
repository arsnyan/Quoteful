//
//  JournalEntry.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 20.09.2025.
//

import Foundation
import GRDB

enum JournalEntryValidationError: LocalizedError {
    case emptyText
    case futureDate
    
    var errorDescription: String? {
        switch self {
        case .emptyText:
            "Text can't be empty."
        case .futureDate:
            "Date can't be in the future"
        }
    }
}

struct JournalEntry: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    let timestamp: Date
    var mood: Mood
    var text: String
}

enum Mood: String, Codable, PersistableRecord, FetchableRecord {
    case happy, sad, neutral, confused, angry
}

// For easier displaying of all cases if changed in the future
extension Mood: CaseIterable {}

extension JournalEntry {
    func validate() throws(JournalEntryValidationError) {
        if timestamp > Date() {
            throw .futureDate
        }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw .emptyText
        }
    }
}
