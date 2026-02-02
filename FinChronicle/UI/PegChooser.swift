//
//  PegChooser.swift
//  FinChronicle
//
//  Created by Paul, Kiren on 2/2/26.
//

import SwiftUI

struct PegChooser: View {
    @Binding var game: CodeBreaker
    @Binding var selection: Int
    var body: some View {
        HStack{
            ForEach(game.pegChoices, id: \.self) {peg in
                Button{
                    game.setGuessPeg(peg, at: selection)
                    selection = (selection +  1) % game.masterCode.pegs.count
                } label: {
                    PegsView(peg:peg)
                }
                
            }
        }
    }
}

//#Preview {
//    PegChooser()
//}
