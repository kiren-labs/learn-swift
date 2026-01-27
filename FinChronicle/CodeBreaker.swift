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
    var attempt: [Code] = [Code]()
    let pegChoices: [Peg] = [.red, .blue, .yellow, .green]
}

struct Code {
    var kind: Kind
    var pegs: [Peg] = [.green, .red, .blue, .yellow]
    
    enum Kind {
        case master
        case guess
        case attempt
        case unkown
    }
}

