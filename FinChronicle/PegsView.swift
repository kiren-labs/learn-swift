//
//  PegsView.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 29/1/26.
//
import SwiftUI

struct PegsView: View {
    // MARK: - Data in
    let peg: Peg
    
    // MARK: - Body
    var body: some View {
        
        
        RoundedRectangle(cornerRadius: 10)
            .overlay {
                if peg == Code.missingPeg {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.gray)
                    
                }
            }
            .contentShape(Rectangle())
            .aspectRatio(1, contentMode: .fit)
            .foregroundStyle(peg)
    }
}

#Preview {
    PegsView(peg: .blue)
        .padding()
}
