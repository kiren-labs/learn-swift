//
//  CodeView.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 29/1/26.
//

import SwiftUI

struct CodeView<AncillaryView>:View where AncillaryView: View {
    //Mark: Data in
    let code: Code
    
    // MARK: Data shared with Me
    @Binding var selection: Int
    
    @ViewBuilder let ancillaryView: () -> AncillaryView
    
    init(code: Code, selection: Binding<Int>, @ViewBuilder ancillaryView: @escaping () -> AncillaryView) {
        self.code = code
        self._selection = selection
        self.ancillaryView = ancillaryView
    }
    
    
    //MARK: Body
    var body: some View {
        
        HStack {
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
                    .overlay {
                        Selection.shape.foregroundStyle(code.isHidden ? Color.gray : .clear)
                    }
                    .onTapGesture {
                        if code.kind == .guess {
                            selection = index
                        }
                    }
            }
            Color.clear.aspectRatio(1,contentMode: .fit)
                .overlay {
                    ancillaryView()
                }
        }
        

    }
}
fileprivate struct Selection {
    static let border: CGFloat = 5
    static let cornerRadius: CGFloat = 10
    static let color: Color = Color.gray(0.85)
    static let shape = RoundedRectangle(cornerRadius: cornerRadius)
    
}
//#Preview {
//    CodeView(code: <#T##Code#>)
//}
