//
//  EntryDetailsView_UITests.swift
//  QuotefulUITests
//
//  Created by Арсен Саруханян on 25.09.2025.
//

import XCTest

final class EntryDetailsView_UITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func test_SavesEntry_WhenCreatingOnHomeView_WithCorrectData() throws {
        let app = XCUIApplication()
        
        app.launchArguments.append("mock_empty_db")
        app.launch()
        app.activate()
        
        let fakeSheet = app.buttons["FakeSheetClickableArea"].firstMatch
        XCTAssertTrue(fakeSheet.exists)
        fakeSheet.tap()
        
        // 😞
        let emojiSad = app.buttons["emoji1"].firstMatch
        XCTAssertTrue(emojiSad.exists)
        emojiSad.tap()
        
        let textEditor = app.textViews["EntryTextEditor"].firstMatch
        textEditor.tap()
        
        sleep(1)
        
        app.keys["H"].firstMatch.tap()
        app.keys["e"].firstMatch.tap()
        app.keys["l"].firstMatch.tap()
        app.keys["l"].firstMatch.tap()
        app.keys["o"].firstMatch.tap()
        app.otherElements["“Hello”"].firstMatch.tap()
        app.keys["delete"].firstMatch.tap()
        
        sleep(1)
        
        let saveButton = app.buttons["SaveButton"].firstMatch
        saveButton.tap()
        sleep(1)
        
        XCTAssertFalse(saveButton.exists)
        XCTAssertFalse(textEditor.exists)
        XCTAssertFalse(emojiSad.exists)
        
        let historyTabItem = app.images["clock.fill"].firstMatch
        historyTabItem.tap()
        
        let historyNavBar = app.staticTexts["History"].firstMatch
        XCTAssertTrue(historyNavBar.exists)
        
        let ourRow = app.staticTexts["Hello"].firstMatch
        ourRow.tap()
        
        let detailsNavBar = app.staticTexts["Details"].firstMatch
        XCTAssertTrue(detailsNavBar.exists)
        
        let emojiStaticText = app.staticTexts["😞"].firstMatch
        XCTAssertTrue(emojiStaticText.exists)
        
        let text = app.staticTexts["Hello"].firstMatch
        XCTAssertTrue(text.exists)
    }
    
    func test_DoesntSaveEntry_IfTextIsEmpty() throws {
        
    }
    
    func test_EditsExistingEntry_IfTextAndEmojiAreChanged() throws {
        
    }
    
    func test_ShowsConfirmation_IfChangesAreUnsaved() throws {
        
    }
    
    func test_DoesntUpdateEntry_IfTextIsEmpty() throws {
        
    }
    
    func test_DoesntUpdateEntry_IfChangesDiscarded() throws {
        
    }
    
    func test_DetailsResetsState_WhenEditedWithError_AndThenDismissed() throws {
        
    }
    
    func test_DetailsDoesntUpdateEntry_IfTextOnlyHasSpaces_And_Whitelines() throws {
        
    }

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
