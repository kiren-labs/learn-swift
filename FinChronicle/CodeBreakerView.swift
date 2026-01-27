//
//  ContentView.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 25/1/26.
//

import SwiftUI

struct CodeBreakerView: View {
    @State var game: CodeBreaker = CodeBreaker()
    
    var body: some View {
        
        VStack {
            view(for: game.masterCode)
            view(for: game.guess)
//            pegs(colors: game.attempt[0])
//            pegs(colors: [.red,.blue,.red,.yellow])
             
        }.padding()
      
    }
    func view(for code : Code) -> some View {

        HStack {
            ForEach(code.pegs.indices, id: \.self) {
                index in
//                Circle().foregroundStyle(colors[index])
                RoundedRectangle(cornerRadius: 10)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(code.pegs[index])
                    .onTapGesture {
                        if code.kind == .guess {
                            game.changeGuessPeg(at: index)
                        }
                    }
            }
            MatchMarkers(matches: [.exact,.inexact,.nomatch,.exact])
        }
    }

}

#Preview {
    CodeBreakerView()
}
