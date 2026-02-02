//
//  FinChronicleMainView.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 26/1/26.
//

import SwiftUI

struct FinChronicleMainView: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    HStack {
                        Text("FinChronicle")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        
                    }
                }
           
            
        }
    }
}

#Preview {
    FinChronicleMainView()
}
