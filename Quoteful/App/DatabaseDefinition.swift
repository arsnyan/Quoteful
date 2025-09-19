//
//  DatabaseDefinition.swift
//  Quoteful
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import OSLog
import SQLiteData

nonisolated private let logger = Logger(subsystem: "Quoteful", category: "Database")

// TODO: - Finish making a table definition here
func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    var configuration = Configuration()
    
    #if DEBUG
    configuration.prepareDatabase { db in
        db.trace(options: .profile) {
            if context == .preview {
                print("\($0.expandedDescription)")
            } else {
                logger.debug("\($0.expandedDescription)")
            }
        }
    }
    #endif
    
    let database = try defaultDatabase(configuration: configuration)
    logger.info("open \(database.path)")
    
    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create tables") { db in
        /* Configure later
        try #sql("""
            CREATE TABLE "name"(
                "id" INT NOT NULL PRIMARY KEY AUTOINCREMENT
            ) STRICT
            """)
        .execute(db)
         */
    }
    try migrator.migrate(database)
    
    return database
}
