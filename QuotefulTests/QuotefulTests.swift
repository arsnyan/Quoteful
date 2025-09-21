//
//  QuotefulTests.swift
//  QuotefulTests
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import Testing
@testable import Quoteful
import FactoryKit
import FactoryTesting
import GRDB

extension Tag {
    @Tag static var integration: Self
    @Tag static var requiresNetwork: Self
    @Tag static var testIsolationCheck: Self
}

struct QuotefulTests {
    @Test func `Database is available on load`() async throws {
        // Given
        @Injected(\.dbPool) var dbPool
        
        // When
        let entries = try? await dbPool?.read(JournalEntry.fetchAll)
        
        #expect(entries != nil)
    }
}
