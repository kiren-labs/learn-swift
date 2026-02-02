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
    
    // MARK: - Body
    var body: some View {
        
        VStack {
            Button("Restart") {
                withAnimation(.restart){
                    restarting = true
                } completion: {
                    game.restart()
                    selection = 0
                    restarting = false
                }
            }
            CodeView(code: game.masterCode) {
                Text("0:03").font(.title)
            }
            ScrollView {
                if !game.isOver || restarting {
                    CodeView(code: game.guess,
                             selection: $selection)
                    {guessButton}.animation(nil, value: game.attempts.count)
                }
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    CodeView(code: game.attempts[index]) {
                        if let matches = game.attempts[index].matches
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
    
    var guessButton: some View {
        Button("Guess") {
            withAnimation(Animation.guess) {
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

extension Animation {
    static let codeBreaker = Animation.easeInOut(duration: 3)
    static let guess = Animation.codeBreaker
    static let restart =  Animation.codeBreaker
}

extension AnyTransition {
    static let pegChooser = AnyTransition.offset(x:0, y:200)
    static func attempt(_ isOver: Bool) -> AnyTransition {
        AnyTransition.asymmetric(
            insertion: isOver ? .opacity : .move(edge: .top),
            removal: .move(edge: .trailing))
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
