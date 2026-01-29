//
//  ContentView.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 25/1/26.
//

import SwiftUI

struct CodeBreakerView: View {
    
    //MARK
    @State private var game: CodeBreaker = CodeBreaker(pegChoices: [.blue, .green, .yellow, .orange])
    @State private var selection: Int = 0
    
    var body: some View {
        
        VStack {
            view(for: game.masterCode)
            ScrollView {
                view(for: game.guess)
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
                }
            }
            pegChooser
        }.padding()
    }
    
    var pegChooser: some View {
        HStack{
            ForEach(game.pegChoices, id: \.self) {peg in
                Button{
                    game.setGuessPeg(peg, at: selection)
                } label: {
                    PegsView(peg:peg)
                }
                 
            }
        }
    }
    var guessButton: some View {
        Button("Guess") {
            withAnimation {
                game.attemptGuess()
            }
        }
        .font(.system(size: 80))
        .minimumScaleFactor(0.1)
    }
     
    func view(for code : Code) -> some View {

        HStack {
            ForEach(code.pegs.indices, id: \.self) {
                index in
//                Circle().foregroundStyle(colors[index])
                PegsView(peg: code.pegs[index])
                    .onTapGesture {
                        if code.kind == .guess {
//                            game.changeGuessPeg(at: index)
                            selection = index
                        }
                    }
            }
            Rectangle()
                .foregroundStyle(Color.clear).aspectRatio(1,contentMode: .fit)
                .overlay {
                    if let matches = code.matches {
                        MatchMarkers(matches: matches)
                    } else {
                        if code.kind == .guess {
                            guessButton
                            
                        }
                    }
                }
        }
    }

}

#Preview {
    CodeBreakerView()
}
