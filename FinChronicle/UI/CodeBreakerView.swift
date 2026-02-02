//
//  ContentView.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 25/1/26.
//

import SwiftUI

struct CodeBreakerView: View {
    
    //MARK: Data owned by me
    @State private var game: CodeBreaker = CodeBreaker(pegChoices: [.blue, .green, .yellow, .orange])
    @State private var selection: Int = 0
    @State private var restarting = false
    @State private var hideMostRecentMarkers = false
    
    // MARK: - Body
    var body: some View {
        
        VStack {
            Button("Restart", action: restart)
            CodeView(code: game.masterCode) {
                Text("0:03").font(.title)
            }
            ScrollView {
                if !game.isOver || restarting {
                    CodeView(code: game.guess,
                             selection: $selection) {
                        Button("Guess", action: guess).flexibleSystemFont()
                       
                    }
                        .animation(nil, value: game.attempts.count)
                        .opacity(restarting ? 0 : 1)
                }
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                   
                    CodeView(code: game.attempts[index]) {
                        let showMarkers = !hideMostRecentMarkers || index != game.attempts.count - 1
                        
                        if showMarkers, let matches = game.attempts[index].matches
                        {
                            MatchMarkers(matches: matches)
                        }
                    }.transition(.attempt(game.isOver))
                }
            }
            if !game.isOver {
                PegChooser(choices: game.pegChoices, onChoose: changePegAtSelection)
                    .transition(.pegChooser)
            }
        }.padding()
    }
    
    func changePegAtSelection(to peg: Peg) {
        game.setGuessPeg(peg, at: selection)
        selection = (selection + 1) % game.masterCode.pegs.count
    }
    func restart() {
        withAnimation(.restart){
            restarting = true
        } completion: {
            game.restart()
            selection = 0
            restarting = false
        }
    }
    
    func guess() {
        withAnimation(Animation.guess) {
            game.attemptGuess()
            selection = 0
            hideMostRecentMarkers = true
        } completion: {
            withAnimation(.guess){
                hideMostRecentMarkers = false;
            }
        }
    }
}


#Preview {
    CodeBreakerView()
}
