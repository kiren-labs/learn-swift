//
//  MatchMarkers.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 25/1/26.
//
import SwiftUI

enum Match {
    case nomatch
    case exact
    case inexact
}
    struct MatchMarkers: View {
        var matches : [Match]
        var body: some View {
            HStack {
                VStack {
                   matchMarker(peg: 0)
                   matchMarker(peg: 1)
                }
                VStack{
                    matchMarker(peg: 2)
                    matchMarker(peg: 3)
                }
            }
        }
        func matchMarker(peg:Int)-> some View {
            let exactCount: Int = matches.count{$0 == .exact } 
            let foundCount: Int = matches.count{ $0 != .nomatch }
            return Circle()
                .fill(exactCount > peg ? Color.primary: Color.clear)
                .strokeBorder(foundCount > peg ? Color.primary: Color.clear)
                .aspectRatio(1, contentMode: .fit)
        }
    }
#Preview {
    MatchMarkers(matches:[.exact, .inexact, .nomatch, .exact])
}
