//
//  ContentView.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 25/1/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack {
            pegs(colors:[.red,.green,.blue,.yellow])
            pegs(colors: [.red,.green,.blue,.green])
            pegs(colors: [.red,.green,.red,.blue])
            pegs(colors: [.red,.blue,.red,.yellow])
            
        }.padding()
      
    }
    func pegs(colors:Array<Color>)-> some View {
        HStack {
            Circle().foregroundStyle(colors[0])
            Circle().foregroundStyle(colors[1])
            Circle().foregroundStyle(colors[2])
            Circle().foregroundStyle(colors[3])
        }
    }
}

#Preview {
    ContentView()
}
