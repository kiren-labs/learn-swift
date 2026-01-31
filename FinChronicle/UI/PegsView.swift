//
//  PegsView.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 29/1/26.
//
import SwiftUI

struct PegsView: View {
    // MARK: - Data in
    let peg: Peg
    
    // MARK: - Body
    var body: some View {
        
        let pegShape = Circle()
        // RoundedRectangle(cornerRadius: 10)
        pegShape
            .contentShape(pegShape)
            .aspectRatio(1, contentMode: .fit)
            .foregroundStyle(peg)
    }
}

#Preview {
    PegsView(peg: .blue)
        .padding()
}
