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
                    selection = (selection +  1) % game.masterCode.pegs.count
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
        .font(.system(size: GuessButton.maximunfontSize))
        .minimumScaleFactor(GuessButton.scalefactor)
    }
    
    func view(for code : Code) -> some View {
        
        HStack {
            CodeView(code: code)
            Color.clear.aspectRatio(1,contentMode: .fit)
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
