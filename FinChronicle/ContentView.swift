//
//  ContentView.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 25/1/26.
//

import SwiftUI

struct ContentView: View {
    let game: CodeBreaker = CodeBreaker()
    
    var body: some View {
        
        VStack {
            pegs(colors:[.green,.red,.blue,.yellow])
            pegs(colors: [.red,.green,.blue,.green])
            pegs(colors: [.blue,.green,.red,.blue])
            pegs(colors: [.red,.blue,.red,.yellow])
            
        }.padding()
      
    }
    func pegs(colors:Array<Color>)-> some View {
        HStack {
            ForEach(colors.indices, id: \.self) {
                index in
//                Circle().foregroundStyle(colors[index])
                RoundedRectangle(cornerRadius: 10)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(colors[index])
            }
            MatchMarkers(matches: [.exact,.inexact,.nomatch,.exact])
        }
    }

}

#Preview {
    ContentView()
}
