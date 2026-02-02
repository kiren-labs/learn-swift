//
//  ContentView.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 25/1/26.
//

import SwiftUI

struct CodeBreakerView: View {
    
    //MARK
    @State private var game: CodeBreaker = CodeBreaker(pegChoices: [.blue, .green, .yellow, .orange])
    @State private var selection: Int = 0
    
    var body: some View {
        
        VStack {
            CodeView(code: game.masterCode) {
                Text("0:03").font(.title)
            }
            ScrollView {
                if !game.isOver {
                    CodeView(code: game.guess,
                             selection: $selection)
                 {guessButton}
                }
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    CodeView(code: game.attempts[index]) {
                        if let matches = game.attempts[index].matches
                        {
                            MatchMarkers(matches: matches)
                        }
                    }
                }
            }
            pegChooser(choices: game.pegChoices) {peg in
                game.setGuessPeg(peg, at: selection)
                selection = (selection + 1) % game.masterCode.pegs.count
            }
        }.padding()
    }
    
//    var pegChooser: some View {
//        HStack{
//            ForEach(game.pegChoices, id: \.self) {peg in
//                Button{
//                    game.setGuessPeg(peg, at: selection)
//                    selection = (selection +  1) % game.masterCode.pegs.count
//                } label: {
//                    PegsView(peg:peg)
//                }
//                
//            }
//        }
//    }
    var guessButton: some View {
        Button("Guess") {
            withAnimation {
                game.attemptGuess()
                selection = 0
            }
        }
        .font(.system(size: GuessButton.maximunfontSize))
        .minimumScaleFactor(GuessButton.scalefactor)
    }
    

    
    struct GuessButton {
        static let minimunFontSize: CGFloat = 8
        static let maximunfontSize: CGFloat = 80
        static let scalefactor = minimunFontSize / maximunfontSize
    }
  
}


extension Color {
    static func gray(_ brightness: CGFloat) -> Color {
        return Color(hue: 140/360, saturation: 0, brightness: brightness)
    }
}
#Preview {
    CodeBreakerView()
}
