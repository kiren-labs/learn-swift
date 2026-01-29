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



