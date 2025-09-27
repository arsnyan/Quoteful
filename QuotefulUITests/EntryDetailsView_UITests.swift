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
        app.launchArguments.append("mock_ui")
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
        
        app.keys["H"].firstMatch.tap()
        app.keys["e"].firstMatch.tap()
        app.keys["l"].firstMatch.tap()
        app.keys["l"].firstMatch.tap()
        app.keys["o"].firstMatch.tap()
        
        
        let saveButton = app.buttons["SaveButton"].firstMatch
        saveButton.tap()
        
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
        let app = XCUIApplication()
        app.launch()
        app.activate()
        app.buttons["FakeSheetClickableArea"].firstMatch.tap()
        app.textViews["EntryTextEditor"].firstMatch.tap()
        
        let error = app.staticTexts["ContextualErrorMsg"].firstMatch
        XCTAssertFalse(error.exists)
        
        app.buttons["SaveButton"].firstMatch.tap()
        
        XCTAssertTrue(error.exists)
    }
    
    func test_EditsExistingEntry_IfTextAndEmojiAreChanged() throws {
        let app = XCUIApplication()
        
        app.launchArguments.append("mock_empty_db")
        app.launchArguments.append("mock_ui")
        app.launch()
        app.activate()
        
        app.staticTexts["Write down your thoughts"].firstMatch.tap()
        
        let textView = app.textViews["EntryTextEditor"].firstMatch
        textView.tap()
        textView.typeText("Hello")
        
        app.buttons["SaveButton"].firstMatch.tap()
        
        app.images["clock.fill"].firstMatch.tap() // history tab
        app.staticTexts["Hello"].firstMatch.tap() // our row
        
        app.buttons["EditButton"].firstMatch.tap()
        app.buttons["emoji0"].firstMatch.tap()
        
        textView.doubleTap()
        textView.typeText("Angry face")
        
        app.buttons["SaveButton"].firstMatch.tap()
        
        let detailText = app.staticTexts["Angry face"].firstMatch
        let detailEmoji = app.staticTexts["😠"].firstMatch
        XCTAssertTrue(detailText.exists)
        XCTAssertTrue(detailEmoji.exists)
        
        let backButton = app.buttons["BackButton"].firstMatch
        backButton.tap()
        
        let rowText = app.buttons["Item1"].staticTexts["😠"].firstMatch
        let rowEmoji = app.buttons["Item1"].staticTexts["Angry face"].firstMatch
        XCTAssertTrue(rowText.exists)
        XCTAssertTrue(rowEmoji.exists)
    }
    
    func test_ShowsConfirmation_IfChangesAreUnsaved() throws {
        let app = XCUIApplication()
        
        app.launchArguments.append("mock_empty_db")
        app.launchArguments.append("mock_ui")
        app.launch()
        app.activate()
        
        app.staticTexts["Write down your thoughts"].firstMatch.tap()
        
        let textView = app.textViews["EntryTextEditor"].firstMatch
        textView.tap()
        textView.typeText("Hello")
        
        app.buttons["SaveButton"].firstMatch.tap()
        
        app.images["clock.fill"].firstMatch.tap() // history tab
        app.staticTexts["Hello"].firstMatch.tap() // our row
        
        app.buttons["EditButton"].firstMatch.tap()
        app.buttons["emoji0"].firstMatch.tap()
        
        textView.doubleTap()
        textView.typeText("Angry face")
        
        let backButton = app.buttons["BackButton"].firstMatch
        backButton.tap()
        
        // For some reason dialogs are not recognized in any possible way
        // and so are the accessibilityIdentifiers for elements inside, like buttons
        let confirmationAlert = app.staticTexts["Discard Changes?"].firstMatch
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["Discard"].exists)
        if #unavailable(iOS 26.0) {
            XCTAssertTrue(app.buttons["Cancel"].exists)
        }
    }
    
    func test_DoesntUpdateEntry_IfTextIsEmpty() throws {
        let app = XCUIApplication()
        
        app.launchArguments.append("mock_empty_db")
        app.launchArguments.append("mock_ui")
        app.launch()
        
        let fakeSheet = app.buttons["FakeSheetClickableArea"].firstMatch
        XCTAssertTrue(fakeSheet.exists)
        fakeSheet.tap()
        
        // 😞
        let emojiSad = app.buttons["emoji1"].firstMatch
        XCTAssertTrue(emojiSad.exists)
        emojiSad.tap()
        
        let textEditor = app.textViews["EntryTextEditor"].firstMatch
        textEditor.tap()
        
        usleep(20000)
        
        app.keys["H"].firstMatch.tap()
        app.keys["e"].firstMatch.tap()
        app.keys["l"].firstMatch.tap()
        app.keys["l"].firstMatch.tap()
        app.keys["o"].firstMatch.tap()
        
        usleep(20000)
        
        let saveButton = app.buttons["SaveButton"].firstMatch
        saveButton.tap()
        usleep(20000)
        
        app.images["clock.fill"].firstMatch.tap()
        
        let ourRow = app.staticTexts["Hello"].firstMatch
        ourRow.tap()
        
        app.buttons["EditButton"].firstMatch.tap()
        usleep(20000)
        let editor = app.textViews["EntryTextEditor"].firstMatch
        editor.tap()
        editor.doubleTap()
        app.keys["delete"].tap()
        
        let saveButton2 = app.buttons["SaveButton"].firstMatch
        saveButton.tap()
        
        let error = app.staticTexts["ContextualErrorMsg"].firstMatch
        XCTAssertTrue(error.exists)
        XCTAssertTrue(saveButton2.exists)
    }
    
    func test_DoesntUpdateEntry_IfChangesDiscarded() throws {
        let app = XCUIApplication()
        
        app.launchArguments.append("mock_empty_db")
        app.launchArguments.append("mock_ui")
        app.launch()
        app.activate()
        
        app.staticTexts["Write down your thoughts"].firstMatch.tap()
        
        let textView = app.textViews["EntryTextEditor"].firstMatch
        textView.tap()
        textView.typeText("Hello")
        
        app.buttons["SaveButton"].firstMatch.tap()
        
        app.images["clock.fill"].firstMatch.tap() // history tab
        app.staticTexts["Hello"].firstMatch.tap() // our row
        
        app.buttons["EditButton"].firstMatch.tap()
        app.buttons["emoji0"].firstMatch.tap()
        
        let backButton = app.buttons["BackButton"].firstMatch
        backButton.tap()
        
        // For some reason dialogs are not recognized in any possible way
        // and so are the accessibilityIdentifiers for elements inside, like buttons
        let confirmationAlert = app.staticTexts["Discard Changes?"].firstMatch
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 1))
        let discardButton = app.buttons["Discard"]
        XCTAssertTrue(discardButton.exists)
        app.buttons["Discard"].tap()
        
        // Detail view should be immediately dismissed
        let detailTitle = app.staticTexts["Details"].firstMatch
        XCTAssertFalse(detailTitle.exists)
        
        // Row
        let rowText = app.buttons["Item1"].staticTexts["😐"].firstMatch
        let rowEmoji = app.buttons["Item1"].staticTexts["Hello"].firstMatch
        XCTAssertTrue(rowText.exists)
        XCTAssertTrue(rowEmoji.exists)
    }
    
    func test_DetailsResetsState_WhenEditedWithError_AndThenDismissed() throws {
        let app = XCUIApplication()
        
        app.launchArguments.append("mock_empty_db")
        app.launchArguments.append("mock_ui")
        app.launch()
        app.activate()
        
        app.staticTexts["Write down your thoughts"].firstMatch.tap()
        
        let textView = app.textViews["EntryTextEditor"].firstMatch
        textView.tap()
        textView.typeText("Hello")
        
        app.buttons["SaveButton"].firstMatch.tap()
        
        app.images["clock.fill"].firstMatch.tap() // history tab
        app.staticTexts["Hello"].firstMatch.tap() // our row
        
        app.buttons["EditButton"].firstMatch.tap()
        textView.tap()
        textView.doubleTap()
        app.staticTexts["Cut"].tap()
        
        app.buttons["SaveButton"].firstMatch.tap()
        
        // To know that the deletion process happened in the test
        let error = app.staticTexts["ContextualErrorMsg"].firstMatch
        XCTAssertTrue(error.exists)
        
        let backButton = app.buttons["BackButton"].firstMatch
        backButton.tap()
        
        // Detail view should be immediately dismissed
        let detailTitle = app.staticTexts["Details"].firstMatch
        XCTAssertFalse(detailTitle.exists)
        
        // Row
        let rowText = app.buttons["Item1"].staticTexts["😐"].firstMatch
        let rowEmoji = app.buttons["Item1"].staticTexts["Hello"].firstMatch
        XCTAssertTrue(rowText.exists)
        XCTAssertTrue(rowEmoji.exists)
    }
}
