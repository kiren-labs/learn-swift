//
//  FinChronicleMainView.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 26/1/26.
//

import SwiftUI

struct FinChronicleMainView: View {
    var finChronicleText: AttributedString {
        var fin = AttributedString("Fin")
        fin.foregroundColor = .orange
        var chronicle = AttributedString("Chronicle")
        chronicle.foregroundColor = .blue
        return fin + chronicle
    }

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Text(finChronicleText)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red, lineWidth: 4)
                )

            RoundedRectangle(cornerRadius: 10)
                .fill(.green)
                .aspectRatio(1, contentMode: .fit)

        }.padding(20)
    }
}



#Preview {
    FinChronicleMainView()
}
