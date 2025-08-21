import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func card() -> some View { self.modifier(CardStyle()) }
}


