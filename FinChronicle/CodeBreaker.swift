//
//  CodeBreaker.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 27/1/26.
//
import SwiftUI


typealias Peg = Color

struct CodeBreaker {
    var masterCode: Code = Code(kind: .master)
    var guess: Code = Code(kind: .guess)
    var attempts: [Code] = []
    let pegChoices: [Peg] = [.red, .blue, .yellow, .green]
    
   mutating func attemptGuess() {
        var attempt =  guess
        attempt.kind = .attempt
        attempts.append(attempt)
    }
    
    mutating func changeGuessPeg(at index:Int) {
        let existingPeg = guess.pegs[index]
        if let indexOfExistingPegChoices = pegChoices.firstIndex(of: existingPeg) {
            let newPeg = pegChoices[(indexOfExistingPegChoices + 1) % pegChoices.count]
            guess.pegs[index] = newPeg
            
        } else {
            guess.pegs[index] = pegChoices.first ?? Code.missing
        }
        
    }
}

struct Code {
    var kind: Kind
    var pegs: [Peg] = [.green, .red, .blue, .yellow]
    static var missing: Peg = .clear
    
    enum Kind {
        case master
        case guess
        case attempt
        case unkown
    }
    
    func match(against otherCode: Code) -> [Match] {
        var results: [Match] = Array(repeating: .nomatch, count: pegs.count)
        var pegsToMatch: [Peg] = otherCode.pegs
        for index in  pegs.indices {
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                results[index] = .exact
                pegsToMatch.remove(at: index)
            }
        }
        for index in pegs.indices {
            if results[index] != .exact {
                if let matchIndex = pegsToMatch.firstIndex(of: pegs[index]) {
                    results[index] = .inexact
                    pegsToMatch.remove(at: matchIndex)
                    }
                }
            }
        return results
    }
}

