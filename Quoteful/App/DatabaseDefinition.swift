//
//  DatabaseDefinition.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import OSLog
import GRDB
import FactoryKit

private let logger = Logger(subsystem: "Quoteful", category: "Database")

func prepareDatabaseURL() throws -> URL {
    let fileManager = FileManager.default
    let applicationSupportURL = try fileManager.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    let directoryURL = applicationSupportURL.appending(
        path: "QuotefulDatabase",
        directoryHint: .isDirectory
    )
    try fileManager.createDirectory(
        at: directoryURL,
        withIntermediateDirectories: true
    )
    logger.info("Created database directory")
    
    return directoryURL.appending(
        path: "db.sqlite"
    )
}

func appDatabase() throws -> DatabaseWriter {
    let databaseURL = try prepareDatabaseURL()
    
    var config = Configuration()
    config.prepareDatabase { db in
        db.trace { logger.trace("SQL> \($0)") }
    }
    #if DEBUG
    config.publicStatementArguments = true
    #endif
    
    var migrator = DatabaseMigrator()
    migrator.registerMigration("Create journalEntries") { db in
        try db.create(table: "journalEntry") { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("date", .datetime)
            table.column("mood", .text)
            table.column("text", .text)
        }
    }
    
    let db = try DatabasePool(
        path: databaseURL.path(percentEncoded: false),
        configuration: config
    )
    try migrator.migrate(db)
    
    return db
}

extension Container {
    var dbPool: Factory<DatabaseWriter?> {
        self {
            return try! appDatabase()
        }
        .shared
    }
}
