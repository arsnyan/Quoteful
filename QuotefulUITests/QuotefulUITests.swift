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
        app.activate()
        
        let sheetArea = app.otherElements["FakeSheetClickableArea"]
        sheetArea.tap()
        
        let openedSheet = app.navigationBars["Entry Details"]
        XCTAssert(openedSheet.exists)
    }
}
