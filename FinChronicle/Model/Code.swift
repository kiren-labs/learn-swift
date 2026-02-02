//
//  Code.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 29/1/26.
//


import SwiftUI

/// Represents a code consisting of pegs and its type (master, guess, attempt).
struct Code {
    var kind: Kind
    var pegs: [Peg] = Array(repeating: Code.missingPeg, count: 4)
    static let missingPeg: Peg = Color.missing
    
    enum Kind: Equatable {
        case master(isHidden:Bool)
        case guess
        case attempt([Match])
        case unkown
    }
    mutating func randomize(from pegChoices: [Peg]) {
        for index in pegs.indices {
            pegs[index] = pegChoices.randomElement() ?? Code.missingPeg
        }
        print(self)
    }
    
    var isHidden: Bool {
        switch kind {
        case .master(let isHidden): return isHidden
            default : return false
        }
    }
    
    mutating func reset() {
        pegs = Array(repeating: Code.missingPeg, count: 4)
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
        let backwordExactMatches = pegs.indices.reversed().map { index in
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
