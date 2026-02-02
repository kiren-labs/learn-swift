//
//  PegChooser.swift
//  FinChronicle
//
//  Created by Paul, Kiren on 2/2/26.
//

import SwiftUI

struct PegChooser: View {

    let choices: [Peg]
    let onChoose: (Peg) -> Void
    
    var body: some View {
        HStack{
            ForEach(choices, id: \.self) {peg in
                Button{
                   onChoose(peg)
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
