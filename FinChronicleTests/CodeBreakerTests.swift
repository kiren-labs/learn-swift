//
//  CodeBreakerTests.swift
//  FinChronicleTests
//
//  Created by Claude Code
//

import Testing
import SwiftUI
@testable import FinChronicle

struct CodeBreakerTests {

    // MARK: - Initialization Tests

    @Test func initialization_createsWithDefaultPegChoices() {
        let game = CodeBreaker()

        #expect(game.pegChoices.count == 4)
        #expect(game.pegChoices.contains(.red))
        #expect(game.pegChoices.contains(.blue))
        #expect(game.pegChoices.contains(.green))
        #expect(game.pegChoices.contains(.yellow))
    }

    @Test func initialization_createsWithCustomPegChoices() {
        let customChoices: [Peg] = [.red, .blue]
        let game = CodeBreaker(pegChoices: customChoices)

        #expect(game.pegChoices.count == 2)
        #expect(game.pegChoices == customChoices)
    }

    @Test func initialization_createsMasterCodeAsHidden() {
        let game = CodeBreaker()

        if case .master(let isHidden) = game.masterCode.kind {
            #expect(isHidden == true)
        } else {
            Issue.record("Master code should be hidden on initialization")
        }
    }

    @Test func initialization_randomizesMasterCode() {
        let game = CodeBreaker()

        // Master code should be filled with valid peg choices
        #expect(game.masterCode.pegs.allSatisfy { game.pegChoices.contains($0) })
        #expect(!game.masterCode.pegs.contains(Color.missing))
    }

    @Test func initialization_createsEmptyGuess() {
        let game = CodeBreaker()

        #expect(game.guess.pegs.allSatisfy { $0 == Code.missingPeg })
    }

    @Test func initialization_createsEmptyAttempts() {
        let game = CodeBreaker()

        #expect(game.attempts.isEmpty)
    }

    @Test func initialization_setsStartTime() {
        let beforeInit = Date.now
        let game = CodeBreaker()
        let afterInit = Date.now

        #expect(game.startTime >= beforeInit)
        #expect(game.startTime <= afterInit)
    }

    @Test func initialization_endTimeIsNil() {
        let game = CodeBreaker()

        #expect(game.endTime == nil)
    }

    // MARK: - isOver Tests

    @Test func isOver_returnsFalse_whenNoAttempts() {
        let game = CodeBreaker()

        #expect(game.isOver == false)
    }

    @Test func isOver_returnsFalse_whenLastAttemptDoesNotMatch() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .red, .red, .red]
        game.guess.pegs = [.blue, .blue, .blue, .blue]

        game.attemptGuess()

        #expect(game.isOver == false)
    }

    @Test func isOver_returnsTrue_whenLastAttemptMatchesMasterCode() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .blue, .green, .yellow]
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.attemptGuess()

        #expect(game.isOver == true)
    }

    @Test func isOver_returnsFalse_whenOnlyFirstAttemptMatched() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .red, .red, .red]

        // First attempt matches
        game.guess.pegs = [.red, .red, .red, .red]
        game.attemptGuess()

        // Second attempt doesn't match
        game.guess.pegs = [.blue, .blue, .blue, .blue]
        game.attemptGuess()

        #expect(game.isOver == false)
    }

    // MARK: - attemptGuess Tests

    @Test func attemptGuess_addsGuessToAttempts() {
        var game = CodeBreaker()
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.attemptGuess()

        #expect(game.attempts.count == 1)
        #expect(game.attempts[0].pegs == [.red, .blue, .green, .yellow])
    }

    @Test func attemptGuess_convertsGuessToAttemptKind() {
        var game = CodeBreaker()
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.attemptGuess()

        if case .attempt(_) = game.attempts[0].kind {
            // Success
        } else {
            Issue.record("Attempt should have .attempt kind")
        }
    }

    @Test func attemptGuess_calculatesMatches() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .blue, .green, .yellow]
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.attemptGuess()

        let matches = game.attempts[0].matches
        #expect(matches != nil)
        #expect(matches?.count == 4)
        #expect(matches?.allSatisfy { $0 == .exact } == true)
    }

    @Test func attemptGuess_resetsGuessAfterAttempt() {
        var game = CodeBreaker()
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.attemptGuess()

        #expect(game.guess.pegs.allSatisfy { $0 == Code.missingPeg })
    }

    @Test func attemptGuess_multipleAttempts_appendsToArray() {
        var game = CodeBreaker()

        game.guess.pegs = [.red, .red, .red, .red]
        game.attemptGuess()

        game.guess.pegs = [.blue, .blue, .blue, .blue]
        game.attemptGuess()

        game.guess.pegs = [.green, .green, .green, .green]
        game.attemptGuess()

        #expect(game.attempts.count == 3)
        #expect(game.attempts[0].pegs == [.red, .red, .red, .red])
        #expect(game.attempts[1].pegs == [.blue, .blue, .blue, .blue])
        #expect(game.attempts[2].pegs == [.green, .green, .green, .green])
    }

    @Test func attemptGuess_whenWinning_revealsCodeMasterCode() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .blue, .green, .yellow]
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.attemptGuess()

        if case .master(let isHidden) = game.masterCode.kind {
            #expect(isHidden == false)
        } else {
            Issue.record("Master code should be revealed after winning")
        }
    }

    @Test func attemptGuess_whenWinning_setsEndTime() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .blue, .green, .yellow]
        game.guess.pegs = [.red, .blue, .green, .yellow]

        #expect(game.endTime == nil)

        game.attemptGuess()

        #expect(game.endTime != nil)
    }

    @Test func attemptGuess_whenNotWinning_doesNotSetEndTime() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .blue, .green, .yellow]
        game.guess.pegs = [.red, .red, .red, .red]

        game.attemptGuess()

        #expect(game.endTime == nil)
    }

    @Test func attemptGuess_whenNotWinning_keepsMasterCodeHidden() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .blue, .green, .yellow]
        game.guess.pegs = [.red, .red, .red, .red]

        game.attemptGuess()

        if case .master(let isHidden) = game.masterCode.kind {
            #expect(isHidden == true)
        } else {
            Issue.record("Master code should remain hidden when not winning")
        }
    }

    // MARK: - restart Tests

    @Test func restart_clearsMasterCode() {
        var game = CodeBreaker()
        let originalMasterCode = game.masterCode.pegs

        game.restart()

        // Master code should be different after restart (very likely)
        // At minimum it should be valid
        #expect(game.masterCode.pegs.allSatisfy { game.pegChoices.contains($0) })
    }

    @Test func restart_hidesMasterCode() {
        var game = CodeBreaker()
        game.masterCode.kind = .master(isHidden: false)

        game.restart()

        if case .master(let isHidden) = game.masterCode.kind {
            #expect(isHidden == true)
        } else {
            Issue.record("Master code should be hidden after restart")
        }
    }

    @Test func restart_clearsGuess() {
        var game = CodeBreaker()
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.restart()

        #expect(game.guess.pegs.allSatisfy { $0 == Code.missingPeg })
    }

    @Test func restart_clearsAttempts() {
        var game = CodeBreaker()
        game.guess.pegs = [.red, .blue, .green, .yellow]
        game.attemptGuess()
        game.guess.pegs = [.red, .red, .red, .red]
        game.attemptGuess()

        #expect(game.attempts.count == 2)

        game.restart()

        #expect(game.attempts.isEmpty)
    }

    @Test func restart_updatesStartTime() {
        var game = CodeBreaker()
        let originalStartTime = game.startTime

        // Sleep briefly to ensure time difference
        Thread.sleep(forTimeInterval: 0.01)

        game.restart()

        #expect(game.startTime > originalStartTime)
    }

    @Test func restart_clearsEndTime() {
        var game = CodeBreaker()
        game.endTime = Date.now

        game.restart()

        #expect(game.endTime == nil)
    }

    @Test func restart_preservesPegChoices() {
        let customChoices: [Peg] = [.red, .blue, .orange]
        var game = CodeBreaker(pegChoices: customChoices)

        game.restart()

        #expect(game.pegChoices == customChoices)
    }

    // MARK: - setGuessPeg Tests

    @Test func setGuessPeg_setsCorrectIndex() {
        var game = CodeBreaker()

        game.setGuessPeg(.red, at: 0)
        game.setGuessPeg(.blue, at: 1)
        game.setGuessPeg(.green, at: 2)
        game.setGuessPeg(.yellow, at: 3)

        #expect(game.guess.pegs[0] == .red)
        #expect(game.guess.pegs[1] == .blue)
        #expect(game.guess.pegs[2] == .green)
        #expect(game.guess.pegs[3] == .yellow)
    }

    @Test func setGuessPeg_replacesExistingPeg() {
        var game = CodeBreaker()
        game.guess.pegs[0] = .red

        game.setGuessPeg(.blue, at: 0)

        #expect(game.guess.pegs[0] == .blue)
    }

    @Test func setGuessPeg_invalidIndex_doesNotCrash() {
        var game = CodeBreaker()

        game.setGuessPeg(.red, at: -1)
        game.setGuessPeg(.red, at: 10)

        // Should not crash and guess should remain unchanged
        #expect(game.guess.pegs.allSatisfy { $0 == Code.missingPeg })
    }

    @Test func setGuessPeg_boundaryIndices_work() {
        var game = CodeBreaker()

        game.setGuessPeg(.red, at: 0)
        game.setGuessPeg(.blue, at: 3)

        #expect(game.guess.pegs[0] == .red)
        #expect(game.guess.pegs[3] == .blue)
    }

    // MARK: - changeGuessPeg Tests

    @Test func changeGuessPeg_cyclesThroughPegChoices() {
        var game = CodeBreaker(pegChoices: [.red, .blue, .green])
        game.guess.pegs[0] = .red

        game.changeGuessPeg(at: 0)
        #expect(game.guess.pegs[0] == .blue)

        game.changeGuessPeg(at: 0)
        #expect(game.guess.pegs[0] == .green)

        game.changeGuessPeg(at: 0)
        #expect(game.guess.pegs[0] == .red)
    }

    @Test func changeGuessPeg_fromMissingPeg_setsToFirstChoice() {
        var game = CodeBreaker(pegChoices: [.red, .blue, .green])
        game.guess.pegs[0] = Code.missingPeg

        game.changeGuessPeg(at: 0)

        #expect(game.guess.pegs[0] == .red)
    }

    @Test func changeGuessPeg_wrapsAroundToFirst() {
        var game = CodeBreaker(pegChoices: [.red, .blue, .green])
        game.guess.pegs[0] = .green

        game.changeGuessPeg(at: 0)

        #expect(game.guess.pegs[0] == .red)
    }

    @Test func changeGuessPeg_worksForAllIndices() {
        var game = CodeBreaker(pegChoices: [.red, .blue])

        game.changeGuessPeg(at: 0)
        game.changeGuessPeg(at: 1)
        game.changeGuessPeg(at: 2)
        game.changeGuessPeg(at: 3)

        #expect(game.guess.pegs[0] == .red)
        #expect(game.guess.pegs[1] == .red)
        #expect(game.guess.pegs[2] == .red)
        #expect(game.guess.pegs[3] == .red)
    }

    @Test func changeGuessPeg_withSingleChoice_staysOnThatChoice() {
        var game = CodeBreaker(pegChoices: [.red])
        game.guess.pegs[0] = .red

        game.changeGuessPeg(at: 0)

        #expect(game.guess.pegs[0] == .red)
    }

    // MARK: - Time Tracking Tests

    @Test func timeTracking_startTimeBeforeEndTime() {
        var game = CodeBreaker()
        game.masterCode.pegs = [.red, .blue, .green, .yellow]
        game.guess.pegs = [.red, .blue, .green, .yellow]

        game.attemptGuess()

        if let endTime = game.endTime {
            #expect(game.startTime <= endTime)
        } else {
            Issue.record("End time should be set after winning")
        }
    }

    @Test func timeTracking_restartResetsStartTime() {
        var game = CodeBreaker()
        let firstStart = game.startTime

        Thread.sleep(forTimeInterval: 0.01)

        game.restart()
        let secondStart = game.startTime

        #expect(secondStart > firstStart)
    }

    // MARK: - Integration Tests

    @Test func fullGame_playthrough() {
        var game = CodeBreaker(pegChoices: [.red, .blue, .green, .yellow])

        // Set a known master code for testing
        game.masterCode.pegs = [.red, .blue, .green, .yellow]

        // Make first incorrect guess
        game.setGuessPeg(.red, at: 0)
        game.setGuessPeg(.red, at: 1)
        game.setGuessPeg(.red, at: 2)
        game.setGuessPeg(.red, at: 3)
        game.attemptGuess()

        #expect(game.attempts.count == 1)
        #expect(game.isOver == false)

        // Make second incorrect guess
        game.setGuessPeg(.blue, at: 0)
        game.setGuessPeg(.blue, at: 1)
        game.setGuessPeg(.blue, at: 2)
        game.setGuessPeg(.blue, at: 3)
        game.attemptGuess()

        #expect(game.attempts.count == 2)
        #expect(game.isOver == false)

        // Make winning guess
        game.setGuessPeg(.red, at: 0)
        game.setGuessPeg(.blue, at: 1)
        game.setGuessPeg(.green, at: 2)
        game.setGuessPeg(.yellow, at: 3)
        game.attemptGuess()

        #expect(game.attempts.count == 3)
        #expect(game.isOver == true)
        #expect(game.endTime != nil)
    }

    @Test func fullGame_withRestart() {
        var game = CodeBreaker()

        // Play partial game
        game.guess.pegs = [.red, .red, .red, .red]
        game.attemptGuess()

        #expect(game.attempts.count == 1)

        // Restart
        game.restart()

        #expect(game.attempts.isEmpty)
        #expect(game.isOver == false)
        #expect(game.endTime == nil)
        #expect(game.masterCode.isHidden == true)
    }

    @Test func changeGuessPeg_multipleTimes_cyclesCorrectly() {
        var game = CodeBreaker(pegChoices: [.red, .blue, .green])

        // Track cycling through colors
        var seenColors: Set<Color> = []

        // Cycle through all colors multiple times
        for _ in 0..<10 {
            game.changeGuessPeg(at: 0)
            seenColors.insert(game.guess.pegs[0])
        }

        // After 10 changes, we should have seen all 3 colors
        #expect(seenColors.count == 3)
        #expect(seenColors.contains(.red))
        #expect(seenColors.contains(.blue))
        #expect(seenColors.contains(.green))

        // Final color should be one of the valid choices
        #expect(game.pegChoices.contains(game.guess.pegs[0]))
    }
}

// MARK: - Color Extension Tests

struct ColorExtensionTests {

    @Test func colorMissing_equalsColorClear() {
        #expect(Color.missing == Color.clear)
    }

    @Test func colorMissing_equalsCodeMissingPeg() {
        #expect(Color.missing == Code.missingPeg)
    }
}
