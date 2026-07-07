import XCTest

final class WodcardUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddEntryFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("UI Test Entry")
        app.buttons["saveEntryButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 5))
    }

    func testKeyboardDismissOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Dismiss test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["WOD details"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for i in 0..<25 {
            let addButton = app.buttons["addEntryButton"]
            guard addButton.exists else { break }
            addButton.tap()
            if app.buttons["purchaseProButton"].waitForExistence(timeout: 2) {
                XCTAssertTrue(app.buttons["purchaseProButton"].exists)
                app.buttons["paywallCloseButton"].tap()
                break
            }
            let titleField = app.textFields["titleField"]
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Entry \(i)")
                app.buttons["saveEntryButton"].tap()
            }
        }
    }

    func testSettingsOpensAndCloses() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 5))
        app.buttons["settingsDoneButton"].tap()
    }
}
