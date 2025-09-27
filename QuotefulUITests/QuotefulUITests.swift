//
//  QuotefulUITests.swift
//  QuotefulUITests
//
//  Created by Арсен Саруханян on 18.09.2025.
//

import XCTest

final class QuotefulUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSheetOpensOnHomePageWhenInputBoxIsClicked() throws {
        let app = XCUIApplication()
        app.launchArguments.append("mock_empty_db")
        app.launch()
        app.activate()
        
        let sheetArea = app.buttons["FakeSheetClickableArea"]
        sheetArea.tap()
        
        let openedSheet = app.navigationBars["Write down your thoughts"]
        XCTAssert(openedSheet.exists)
    }
}
