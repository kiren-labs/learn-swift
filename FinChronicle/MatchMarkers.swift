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
            Circle()
        }
    }
#Preview {
    MatchMarkers(matches:[.exact, .inexact, .nomatch])
}
