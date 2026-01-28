//
//  CodeBreaker.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 27/1/26.
//
import SwiftUI

/// Represents the type of match between pegs.
typealias Peg = Color

/// Represents the result of comparing two pegs.
struct CodeBreaker {
    var masterCode: Code = Code(kind: .master)
    var guess: Code = Code(kind: .guess)
    var attempts: [Code] = []
    let pegChoices: [Peg]
    
    init(pegChoices: [Peg] = [.red,.blue,.green,.yellow]) {
        self.pegChoices = pegChoices
        masterCode.randomize(from: pegChoices)
        print(masterCode)
    }
    
   mutating func attemptGuess() {
        var attempt =  guess
       attempt.kind = .attempt(guess.match(against: masterCode))
        attempts.append(attempt)
    }
    
    mutating func changeGuessPeg(at index:Int) {
        let existingPeg = guess.pegs[index]
        if let indexOfExistingPegChoices = pegChoices.firstIndex(of: existingPeg) {
            let newPeg = pegChoices[(indexOfExistingPegChoices + 1) % pegChoices.count]
            guess.pegs[index] = newPeg
            
        } else {
            guess.pegs[index] = pegChoices.first ?? Code.missingPeg
        }
        
    }
}

extension Color {
    static let missing = Color.clear
}

/// Represents a code consisting of pegs and its type (master, guess, attempt).
struct Code {
    var kind: Kind
    var pegs: [Peg] = Array(repeating: Code.missingPeg, count: 4)
    static let missingPeg: Peg = Color.missing
    
    enum Kind: Equatable {
        case master
        case guess
        case attempt([Match])
        case unkown
    }
    mutating func randomize(from pegChoices: [Peg]) {
        for index in pegChoices.indices {
            pegs[index] = pegChoices.randomElement() ?? Code.missingPeg
        }
    }
    var matches: [Match]? {
        switch kind {
        case .attempt(let matches):
            return matches
        default: return nil
        }
    }
    
    /// Returns an array of Matches when comparing this code against another code
    /// Compares or evaluates another code against the current instance.
    /// - Parameter otherCode: The code to compare or validate against this instance.

    func match(against otherCode: Code) -> [Match] {
        var pegsToMatch: [Peg] = otherCode.pegs
        var backwordExactMatches = pegs.indices.reversed().map { index in
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                pegsToMatch.remove(at: index)
                return Match.exact
            } else {
                return .nomatch
            }
        }
        let exactMatches = Array(backwordExactMatches.reversed())
        return pegs.indices.map { index in
            if exactMatches[index] != .exact, let matchIndex = pegsToMatch.firstIndex(of: pegs[index]) {
                pegsToMatch.remove(at: matchIndex)
                return .inexact
            } else {
                return exactMatches[index]
            }
        }
    }
}

