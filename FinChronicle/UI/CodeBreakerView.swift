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
            Button("Restart",systemImage: "arrow.circlepath" , action: restart)
            CodeView(code: game.masterCode) {
                ElapsedTime(startTime: game.startTime, endTime: game.endTime).flexibleSystemFont().monospaced().lineLimit(1)
            }
            ScrollView {
                if !game.isOver {
                    CodeView(code: game.guess,
                             selection: $selection) {
                        Button("Guess", action: guess).flexibleSystemFont()
                       
                    }
                        .animation(nil, value: game.attempts.count)
                        .opacity(restarting ? 0 : 1)
                }
                ForEach(game.attempts) { attempt in
                   
                    CodeView(code: attempt) {
                        let showMarkers = !hideMostRecentMarkers || attempt.pegs != game.attempts.first?.pegs
                        if showMarkers, let matches = attempt.matches
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
            restarting = game.isOver
            game.restart()
            selection = 0
        } completion: {
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
