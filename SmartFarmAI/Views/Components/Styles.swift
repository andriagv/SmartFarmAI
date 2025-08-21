import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PillButton: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title).font(.subheadline).fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isActive ? Color.green : Color.green.opacity(0.4), lineWidth: isActive ? 2 : 1)
            )
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

extension LinearGradient {
    static var farmGreen: LinearGradient {
        LinearGradient(colors: [Color(red: 0.0, green: 0.5, blue: 0.2), Color.green], startPoint: .leading, endPoint: .trailing)
    }
}


