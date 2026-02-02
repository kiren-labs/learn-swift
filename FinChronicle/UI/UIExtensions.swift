//
//  UIExtensions.swift
//  FinChronicle
//
//  Created by Paul, Kiren  on 2/2/26.
//

import SwiftUI



extension View {
    func flexibleSystemFont(minimum: CGFloat =  8, maximum: CGFloat = 80) -> some View {
        self
            .font(.system(size: maximum))
            .minimumScaleFactor(minimum/maximum)
    }
}
extension Animation {
    static let codeBreaker = Animation.bouncy
    static let guess = Animation.codeBreaker
    static let restart =  Animation.codeBreaker
    static let selection =  Animation.codeBreaker
}

extension AnyTransition {
    static let pegChooser = AnyTransition.offset(x:0, y:200)
    static func attempt(_ isOver: Bool) -> AnyTransition {
        AnyTransition.asymmetric(
            insertion: isOver ? .opacity : .move(edge: .top),
            removal: .move(edge: .trailing))
    }
}

extension Color {
    static func gray(_ brightness: CGFloat) -> Color {
        return Color(hue: 140/360, saturation: 0, brightness: brightness)
    }
}
