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
        
        let pegShape = RoundedRectangle(cornerRadius: 10)
        pegShape
            .overlay {
                if peg == Code.missingPeg {
                    pegShape
                        .strokeBorder(Color.gray)
                    
                }
            }
            .contentShape(pegShape)
            .aspectRatio(1, contentMode: .fit)
            .foregroundStyle(peg)
    }
}

#Preview {
    PegsView(peg: .blue)
        .padding()
}
