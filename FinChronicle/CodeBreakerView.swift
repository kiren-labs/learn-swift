//
//  ContentView.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 25/1/26.
//

import SwiftUI

struct CodeBreakerView: View {
    
    @State private var selectedIndex: Int = 0
    
    //MARK
    @State var game: CodeBreaker = CodeBreaker(pegChoices: [.blue, .green, .yellow, .orange])
    
    var body: some View {
        
        VStack {
            view(for: game.masterCode)
            ScrollView {
                view(for: game.guess)
                pegChooser
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
                }
            }
        }.padding()
    }
    
    var pegChooser: some View {
        VStack(spacing: 8) {
            // Slot selector for the current guess
            HStack(spacing: 12) {
                ForEach(game.guess.pegs.indices, id: \.self) { index in
                    Button {
                        selectedIndex = index
                    } label: {
                        Circle()
                            .stroke(selectedIndex == index ? Color.accentColor : Color.secondary, lineWidth: selectedIndex == index ? 3 : 1)
                            .background(
                                Circle().fill(Color.clear)
                            )
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(selectedIndex == index ? Color.accentColor : Color.secondary)
                            )
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                }
            }
            // Peg choices to set on the selected slot
            HStack(spacing: 12) {
                ForEach(game.pegChoices, id: \.self) { peg in
                    Button {
                        // Set the selected slot in the guess to the chosen peg
                        game.setGuessPeg(at: selectedIndex, to: peg)
                    } label: {
                        PegsView(peg: peg)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
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
                            game.changeGuessPeg(at: index)
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
