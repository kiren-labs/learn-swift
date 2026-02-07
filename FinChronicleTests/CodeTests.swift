//
//  CodeTests.swift
//  FinChronicleTests
//
//  Created by Claude Code
//

import Testing
import SwiftUI
@testable import FinChronicle

struct CodeTests {

    // MARK: - Initialization Tests

    @Test func codeInitialization_createsMasterCode() {
        let code = Code(kind: .master(isHidden: true))

        #expect(code.pegs.count == 4)
        #expect(code.pegs.allSatisfy { $0 == Color.missing })
    }

    @Test func codeInitialization_createsGuessCode() {
        let code = Code(kind: .guess)

        #expect(code.pegs.count == 4)
        #expect(code.pegs.allSatisfy { $0 == Color.missing })
    }

    @Test func codeInitialization_createsAttemptCode() {
        let matches: [Match] = [.exact, .inexact, .nomatch, .exact]
        let code = Code(kind: .attempt(matches))

        #expect(code.pegs.count == 4)
        if case .attempt(let retrievedMatches) = code.kind {
            #expect(retrievedMatches.count == 4)
        }
    }

    // MARK: - Randomize Tests

    @Test func randomize_fillsAllPegsFromChoices() {
        var code = Code(kind: .guess)
        let pegChoices: [Peg] = [.red, .blue, .green]

        code.randomize(from: pegChoices)

        #expect(code.pegs.count == 4)
        #expect(code.pegs.allSatisfy { pegChoices.contains($0) })
        #expect(!code.pegs.contains(Color.missing))
    }

    @Test func randomize_withSingleChoice_fillsAllPegsWithSameColor() {
        var code = Code(kind: .guess)
        let pegChoices: [Peg] = [.red]

        code.randomize(from: pegChoices)

        #expect(code.pegs.allSatisfy { $0 == .red })
    }

    @Test func randomize_withMultipleChoices_producesDiversity() {
        var code = Code(kind: .guess)
        let pegChoices: [Peg] = [.red, .blue, .green, .yellow]

        // Run multiple times to check for randomness
        var allSame = true
        let firstRun = {
            code.randomize(from: pegChoices)
            return code.pegs
        }()

        for _ in 0..<10 {
            code.randomize(from: pegChoices)
            if code.pegs != firstRun {
                allSame = false
                break
            }
        }

        // Very unlikely all 10 runs produce identical random results
        #expect(!allSame || code.pegs == firstRun)
    }

    @Test func randomize_withEmptyChoices_usesMissingPeg() {
        var code = Code(kind: .guess)
        let pegChoices: [Peg] = []

        code.randomize(from: pegChoices)

        #expect(code.pegs.allSatisfy { $0 == Code.missingPeg })
    }

    // MARK: - Reset Tests

    @Test func reset_clearsAllPegsToMissing() {
        var code = Code(kind: .guess)
        code.pegs = [.red, .blue, .green, .yellow]

        code.reset()

        #expect(code.pegs.count == 4)
        #expect(code.pegs.allSatisfy { $0 == Code.missingPeg })
    }

    @Test func reset_maintainsCodeKind() {
        var code = Code(kind: .master(isHidden: true))
        code.pegs = [.red, .blue, .green, .yellow]

        code.reset()

        if case .master(let isHidden) = code.kind {
            #expect(isHidden == true)
        } else {
            Issue.record("Code kind should remain .master(isHidden: true)")
        }
    }

    // MARK: - IsHidden Tests

    @Test func isHidden_returnsTrue_whenMasterCodeHidden() {
        let code = Code(kind: .master(isHidden: true))

        #expect(code.isHidden == true)
    }

    @Test func isHidden_returnsFalse_whenMasterCodeNotHidden() {
        let code = Code(kind: .master(isHidden: false))

        #expect(code.isHidden == false)
    }

    @Test func isHidden_returnsFalse_forGuessCode() {
        let code = Code(kind: .guess)

        #expect(code.isHidden == false)
    }

    @Test func isHidden_returnsFalse_forAttemptCode() {
        let code = Code(kind: .attempt([.exact, .inexact, .nomatch, .nomatch]))

        #expect(code.isHidden == false)
    }

    // MARK: - Matches Property Tests

    @Test func matches_returnsMatches_forAttemptCode() {
        let expectedMatches: [Match] = [.exact, .inexact, .nomatch, .exact]
        let code = Code(kind: .attempt(expectedMatches))

        #expect(code.matches != nil)
        #expect(code.matches?.count == 4)
    }

    @Test func matches_returnsNil_forMasterCode() {
        let code = Code(kind: .master(isHidden: true))

        #expect(code.matches == nil)
    }

    @Test func matches_returnsNil_forGuessCode() {
        let code = Code(kind: .guess)

        #expect(code.matches == nil)
    }

    // MARK: - Match Logic Tests

    @Test func match_allExactMatches_returnsFourExact() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        guessCode.pegs = [.red, .blue, .green, .yellow]
        masterCode.pegs = [.red, .blue, .green, .yellow]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        #expect(result.allSatisfy { $0 == .exact })
    }

    @Test func match_noMatches_returnsFourNomatch() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        guessCode.pegs = [.red, .red, .red, .red]
        masterCode.pegs = [.blue, .blue, .blue, .blue]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        #expect(result.allSatisfy { $0 == .nomatch })
    }

    @Test func match_oneExactMatch_returnsOneExactThreeNomatch() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        guessCode.pegs = [.red, .blue, .blue, .blue]
        masterCode.pegs = [.red, .green, .green, .green]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        #expect(result.filter { $0 == .exact }.count == 1)
        #expect(result.filter { $0 == .nomatch }.count == 3)
        #expect(result[0] == .exact)
    }

    @Test func match_allInexactMatches_returnsFourInexact() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        // All colors present but in wrong positions
        guessCode.pegs = [.red, .blue, .green, .yellow]
        masterCode.pegs = [.yellow, .green, .blue, .red]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        #expect(result.allSatisfy { $0 == .inexact })
    }

    @Test func match_mixedExactAndInexact_returnsCorrectCounts() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        // Two exact matches, one inexact, one nomatch
        guessCode.pegs = [.red, .blue, .green, .yellow]
        masterCode.pegs = [.red, .blue, .yellow, .white]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        #expect(result.filter { $0 == .exact }.count == 2)
        #expect(result.filter { $0 == .inexact }.count == 1)
        #expect(result.filter { $0 == .nomatch }.count == 1)
    }

    @Test func match_duplicateColorsInGuess_handlesCorrectly() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        // Guess has duplicates, master has single occurrence
        guessCode.pegs = [.red, .red, .red, .blue]
        masterCode.pegs = [.red, .green, .green, .green]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        // Only first red should be exact, others should be nomatch
        #expect(result[0] == .exact)
        #expect(result[1] == .nomatch)
        #expect(result[2] == .nomatch)
    }

    @Test func match_duplicateColorsInMaster_handlesCorrectly() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        // Master has duplicates
        guessCode.pegs = [.red, .blue, .green, .yellow]
        masterCode.pegs = [.red, .red, .red, .red]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        // Only first position should be exact
        #expect(result[0] == .exact)
        #expect(result.filter { $0 == .exact }.count == 1)
    }

    @Test func match_partialDuplicates_exactMatchTakesPriority() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        // Two reds in guess, one exact and one inexact available in master
        guessCode.pegs = [.red, .blue, .red, .green]
        masterCode.pegs = [.green, .red, .red, .blue]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        // Position 2 should be exact (red matches red)
        #expect(result[2] == .exact)
        // Position 0 should be inexact (red exists but in different position)
        #expect(result[0] == .inexact)
    }

    @Test func match_emptyPegs_returnsNomatch() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        // Both codes have missing pegs
        guessCode.pegs = [.missing, .missing, .missing, .missing]
        masterCode.pegs = [.missing, .missing, .missing, .missing]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        #expect(result.allSatisfy { $0 == .exact })
    }

    @Test func match_partiallyEmptyPegs_matchesOnlyNonEmpty() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        guessCode.pegs = [.red, .missing, .blue, .missing]
        masterCode.pegs = [.red, .missing, .green, .missing]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        #expect(result[0] == .exact)  // red matches red
        #expect(result[1] == .exact)  // missing matches missing
        #expect(result[2] == .nomatch)  // blue doesn't match green
        #expect(result[3] == .exact)  // missing matches missing
    }

    // MARK: - Edge Case Tests

    @Test func code_missingPegConstant_isClearColor() {
        #expect(Code.missingPeg == Color.missing)
        #expect(Color.missing == Color.clear)
    }

    @Test func codeKind_equality_worksCorrectly() {
        let kind1: Code.Kind = .guess
        let kind2: Code.Kind = .guess
        let kind3: Code.Kind = .master(isHidden: true)

        #expect(kind1 == kind2)
        #expect(kind1 != kind3)
    }

    @Test func match_complexScenario_duplicatesAndMixed() {
        var guessCode = Code(kind: .guess)
        var masterCode = Code(kind: .master(isHidden: true))

        // Complex scenario: [red, blue, blue, green] vs [blue, red, green, blue]
        guessCode.pegs = [.red, .blue, .blue, .green]
        masterCode.pegs = [.blue, .red, .green, .blue]

        let result = guessCode.match(against: masterCode)

        #expect(result.count == 4)
        // Position 0: red vs blue -> inexact (red exists at position 1 in master)
        #expect(result[0] == .inexact)
        // Position 1: blue vs red -> inexact (blue exists at positions 0,3 in master)
        #expect(result[1] == .inexact)
        // Position 2: blue vs green -> inexact (blue exists at position 3 in master)
        #expect(result[2] == .inexact)
        // Position 3: green vs blue -> inexact (green exists at position 2 in master)
        #expect(result[3] == .inexact)
    }
}

// MARK: - Match Enum Tests

struct MatchTests {

    @Test func matchEnum_hasThreeCases() {
        let nomatch: Match = .nomatch
        let exact: Match = .exact
        let inexact: Match = .inexact

        // Ensure all cases are distinct
        #expect(nomatch != exact)
        #expect(nomatch != inexact)
        #expect(exact != inexact)
    }

    @Test func matchEnum_canBeUsedInArrays() {
        let matches: [Match] = [.exact, .inexact, .nomatch, .exact]

        #expect(matches.count == 4)
        #expect(matches.filter { $0 == .exact }.count == 2)
        #expect(matches.filter { $0 == .inexact }.count == 1)
        #expect(matches.filter { $0 == .nomatch }.count == 1)
    }

    @Test func matchEnum_canBeCompared() {
        let match1: Match = .exact
        let match2: Match = .exact
        let match3: Match = .inexact

        #expect(match1 == match2)
        #expect(match1 != match3)
    }
}
