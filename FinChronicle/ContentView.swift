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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.largeTitle, )
            Text("Hello, Wlcome 193p!")
                .font(.largeTitle)
                .foregroundStyle(.green)
                .font(.largeTitle)
            Circle()
                .background()
                .foregroundColor(.blue)
                .padding(.horizontal)
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
