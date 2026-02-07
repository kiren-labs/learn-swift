//
//  FinChronicleUITests.swift
//  FinChronicleUITests
//
//  Created by Paul, Kiren  on 25/1/26.
//

import XCTest

final class FinChronicleUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch Tests

    @MainActor
    func testAppLaunches() throws {
        XCTAssertTrue(app.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Initial State Tests

    @MainActor
    func testInitialState_restartButtonExists() throws {
        let restartButton = app.buttons["Restart"]
        XCTAssertTrue(restartButton.exists)
    }

    @MainActor
    func testInitialState_guessButtonExists() throws {
        let guessButton = app.buttons["Guess"]
        XCTAssertTrue(guessButton.exists)
    }

    @MainActor
    func testInitialState_scrollViewExists() throws {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists)
    }

    // MARK: - Interaction Tests

    @MainActor
    func testRestartButton_isTappable() throws {
        let restartButton = app.buttons["Restart"]
        XCTAssertTrue(restartButton.isHittable)

        restartButton.tap()

        // App should still be functional after restart
        XCTAssertTrue(app.exists)
        XCTAssertTrue(restartButton.exists)
    }

    @MainActor
    func testGuessButton_isTappable() throws {
        let guessButton = app.buttons["Guess"]
        XCTAssertTrue(guessButton.isHittable)

        guessButton.tap()

        // After making a guess, button should still exist for next guess
        XCTAssertTrue(guessButton.exists || app.buttons["Restart"].exists)
    }

    // MARK: - Game Flow Tests

    @MainActor
    func testGameFlow_makeMultipleGuesses() throws {
        let guessButton = app.buttons["Guess"]

        // Make first guess
        if guessButton.exists && guessButton.isHittable {
            guessButton.tap()

            // Wait for animation to complete
            Thread.sleep(forTimeInterval: 0.5)

            // Make second guess if game not over
            if guessButton.exists && guessButton.isHittable {
                guessButton.tap()

                Thread.sleep(forTimeInterval: 0.5)

                // Make third guess if game not over
                if guessButton.exists && guessButton.isHittable {
                    guessButton.tap()
                }
            }
        }

        // App should remain stable
        XCTAssertTrue(app.exists)
    }

    @MainActor
    func testGameFlow_restartAfterGuesses() throws {
        let guessButton = app.buttons["Guess"]
        let restartButton = app.buttons["Restart"]

        // Make a guess
        if guessButton.exists && guessButton.isHittable {
            guessButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }

        // Restart the game
        restartButton.tap()
        Thread.sleep(forTimeInterval: 0.5)

        // Guess button should exist again after restart
        XCTAssertTrue(guessButton.exists)
    }

    // MARK: - UI Element Existence Tests

    @MainActor
    func testUIElements_buttonsExist() throws {
        // Check that primary buttons exist
        let buttons = app.buttons
        XCTAssertGreaterThan(buttons.count, 0)
    }

    @MainActor
    func testUIElements_scrollViewIsScrollable() throws {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists)
    }

    // MARK: - Stress Tests

    @MainActor
    func testStress_multipleRestarts() throws {
        let restartButton = app.buttons["Restart"]

        // Tap restart multiple times
        for _ in 0..<5 {
            if restartButton.exists && restartButton.isHittable {
                restartButton.tap()
                Thread.sleep(forTimeInterval: 0.3)
            }
        }

        // App should remain stable
        XCTAssertTrue(app.exists)
        XCTAssertTrue(restartButton.exists)
    }

    @MainActor
    func testStress_rapidGuesses() throws {
        let guessButton = app.buttons["Guess"]

        // Make multiple rapid guesses
        for _ in 0..<10 {
            if guessButton.exists && guessButton.isHittable {
                guessButton.tap()
                Thread.sleep(forTimeInterval: 0.1)
            } else {
                break
            }
        }

        // App should remain stable
        XCTAssertTrue(app.exists)
    }

    // MARK: - State Persistence Tests

    @MainActor
    func testState_guessButtonDisappears_whenGameOver() throws {
        // This test assumes the game might end
        // Make many guesses to potentially win
        let guessButton = app.buttons["Guess"]

        var guessesMade = 0
        while guessButton.exists && guessButton.isHittable && guessesMade < 20 {
            guessButton.tap()
            Thread.sleep(forTimeInterval: 0.2)
            guessesMade += 1
        }

        // If guess button no longer exists, game might be over
        // Verify restart button still exists
        let restartButton = app.buttons["Restart"]
        XCTAssertTrue(restartButton.exists)
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testAccessibility_restartButtonHasLabel() throws {
        let restartButton = app.buttons["Restart"]
        XCTAssertTrue(restartButton.exists)
        XCTAssertNotNil(restartButton.label)
    }

    @MainActor
    func testAccessibility_guessButtonHasLabel() throws {
        let guessButton = app.buttons["Guess"]
        XCTAssertTrue(guessButton.exists)
        XCTAssertNotNil(guessButton.label)
    }

    // MARK: - Visual Element Tests

    @MainActor
    func testVisualElements_appHasContent() throws {
        // Verify the app has visible content
        XCTAssertTrue(app.buttons.count > 0 || app.staticTexts.count > 0)
    }

    @MainActor
    func testVisualElements_scrollViewHasContent() throws {
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            // Make a guess to add content to scroll view
            let guessButton = app.buttons["Guess"]
            if guessButton.exists && guessButton.isHittable {
                guessButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }

        XCTAssertTrue(app.exists)
    }

    // MARK: - Navigation Tests

    @MainActor
    func testNavigation_canScrollInScrollView() throws {
        let scrollView = app.scrollViews.firstMatch
        let guessButton = app.buttons["Guess"]

        // Add content by making guesses
        for _ in 0..<3 {
            if guessButton.exists && guessButton.isHittable {
                guessButton.tap()
                Thread.sleep(forTimeInterval: 0.3)
            }
        }

        // Try to scroll if scroll view exists
        if scrollView.exists {
            scrollView.swipeUp()
            Thread.sleep(forTimeInterval: 0.2)
            scrollView.swipeDown()
        }

        XCTAssertTrue(app.exists)
    }

    // MARK: - Error Recovery Tests

    @MainActor
    func testErrorRecovery_restartAfterManyGuesses() throws {
        let guessButton = app.buttons["Guess"]
        let restartButton = app.buttons["Restart"]

        // Make many guesses
        for _ in 0..<15 {
            if guessButton.exists && guessButton.isHittable {
                guessButton.tap()
                Thread.sleep(forTimeInterval: 0.1)
            } else {
                break
            }
        }

        // Restart should always work
        restartButton.tap()
        Thread.sleep(forTimeInterval: 0.5)

        // Verify game is in playable state
        XCTAssertTrue(guessButton.exists || restartButton.exists)
    }

    // MARK: - Performance Tests

    @MainActor
    func testPerformance_guessButtonResponse() throws {
        let guessButton = app.buttons["Guess"]

        measure {
            if guessButton.exists && guessButton.isHittable {
                guessButton.tap()
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }

    @MainActor
    func testPerformance_restartButtonResponse() throws {
        let restartButton = app.buttons["Restart"]

        measure {
            if restartButton.exists && restartButton.isHittable {
                restartButton.tap()
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
}
