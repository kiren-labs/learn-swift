//
//  CodeView.swift
//  FinChronicle
//
//  Created by Paul, Kiren (Allianz Technology) on 29/1/26.
//

import SwiftUI

struct CodeView: View {
    //Mark: Data in
    let code: Code
    
    // MARK: Data owned by Me
    @State private var selection: Int = 0
    //MARK: Body
    var body: some View {
        ForEach(code.pegs.indices, id: \.self) {
            index in
            PegsView(peg: code.pegs[index])
                .padding(Selection.border)
                .background{
                    if selection == index, code.kind == .guess {
                        Selection.shape
                            .foregroundStyle(Selection.color)
                    }
                }
                .onTapGesture {
                    if code.kind == .guess {
                        selection = index
                    }
                }
        }
    }
    
    struct Selection {
        static let border: CGFloat = 5
        static let cornerRadius: CGFloat = 10
        static let color: Color = Color.gray(0.85)
        static let shape = RoundedRectangle(cornerRadius: cornerRadius)
        
    }
}

//#Preview {
//    CodeView(code: <#T##Code#>)
//}
