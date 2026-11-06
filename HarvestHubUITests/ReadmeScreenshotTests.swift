import XCTest

// Walks through the app with a demo account and saves README screenshots.
// Run with TEST_RUNNER_SCREENSHOT_DIR set to the repository's screenshots folder.
final class ReadmeScreenshotTests: XCTestCase {

    private let email = "demo@harvesthub.app"
    private let password = "harvest2026"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureReadmeScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        signOutIfNeeded(app)
        save("login")

        signIn(app)

        let loadSamples = app.buttons["Load sample farmers"]
        if loadSamples.waitForExistence(timeout: 5) {
            loadSamples.tap()
        }
        XCTAssertTrue(app.staticTexts["Mukamana A."].waitForExistence(timeout: 20))
        sleep(2)
        save("list")

        app.staticTexts["Mukamana A."].tap()
        XCTAssertTrue(app.staticTexts["Harvest history"].waitForExistence(timeout: 10)
                      || app.staticTexts["HARVEST HISTORY"].waitForExistence(timeout: 2))
        sleep(1)
        save("detail")

        app.buttons["Record a harvest"].tap()
        let kilos = app.textFields["Kilos"]
        XCTAssertTrue(kilos.waitForExistence(timeout: 5))
        type("400", into: kilos)
        sleep(1)
        save("record")

        app.buttons["Cancel"].tap()
    }

    @MainActor
    private func signIn(_ app: XCUIApplication) {
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))
        type(email, into: emailField)
        type(password, into: app.secureTextFields["Password (at least 6 characters)"])

        app.buttons["Create an account"].tap()

        // The demo account may already exist from an earlier run: fall back to signing in.
        let account = app.buttons["Account"]
        if !account.waitForExistence(timeout: 10) {
            app.buttons["Sign In"].tap()
            XCTAssertTrue(account.waitForExistence(timeout: 15))
        }
    }

    @MainActor
    private func signOutIfNeeded(_ app: XCUIApplication) {
        let account = app.buttons["Account"]
        guard account.waitForExistence(timeout: 5) else { return }
        account.tap()
        app.buttons["Sign out"].tap()
        XCTAssertTrue(app.textFields["Email"].waitForExistence(timeout: 10))
    }

    @MainActor
    private func type(_ text: String, into field: XCUIElement) {
        for _ in 0..<5 {
            field.tap()
            if field.waitForHasFocus(timeout: 2) { break }
        }
        field.typeText(text)
    }

    private func save(_ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation

        let attachment = XCTAttachment(data: png, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        guard let dir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] else { return }
        try? png.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
    }
}

private extension XCUIElement {
    func waitForHasFocus(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "hasKeyboardFocus == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
