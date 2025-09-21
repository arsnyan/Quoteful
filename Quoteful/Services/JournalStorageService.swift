//
//  JournalStorageService.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 20.09.2025.
//

import Foundation
import FactoryKit
import GRDB

struct JournalStorageService {
    var createEntry: (_ entry: JournalEntry) async throws -> JournalEntry
    var fetchEntryById: (_ id: Int64) async throws -> JournalEntry
    var updateEntry: (_ entry: JournalEntry) async throws -> JournalEntry
    var deleteEntry: (_ entry: JournalEntry) async throws -> Bool
}

extension Container {
    var journalService: Factory<JournalStorageService> {
        self {
            @Injected(\.dbPool) var dbPool
            
            return JournalStorageService(
                createEntry: { entry -> JournalEntry in
                    guard let dbPool else { throw DatabaseError(resultCode: .SQLITE_ABORT) }
                    
                    try entry.validate()
                    
                    return try await dbPool.write { db in
                        try entry.saveAndFetch(db)
                    }
                },
                
                fetchEntryById: { id -> JournalEntry in
                    return try await dbPool?.read { db in
                        guard let entry = try JournalEntry.fetchOne(db, id: id) else {
                            throw DatabaseError(resultCode: .SQLITE_NOTFOUND)
                        }
                        
                        return entry
                    } ?? { throw DatabaseError(resultCode: .SQLITE_ABORT) }()
                },
                
                updateEntry: { entry -> JournalEntry in
                    try entry.validate()
                    
                    try await dbPool?.write { db in
                        try entry.save(db, onConflict: .replace)
                    }
                    
                    return entry
                },
                
                deleteEntry: { entry -> Bool in
                    return try await dbPool?.write(entry.delete) ?? false
                }
            )
        }
    }
}
