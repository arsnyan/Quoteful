//
//  JournalEntry.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 20.09.2025.
//

import Foundation
import GRDB

struct JournalEntry: Codable, FetchableRecord, PersistableRecord, Identifiable {
    let id: Int
    let timestamp: Date
    let mood: Mood
    let text: String
}

enum Mood: String, Codable, PersistableRecord, FetchableRecord {
    case happy, sad, neutral, confused, angry
}
