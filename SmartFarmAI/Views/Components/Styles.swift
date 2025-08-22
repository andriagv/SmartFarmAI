import SwiftUI

// MARK: - Premium Color Palette
extension Color {
    // Primary Colors
    static let primaryGreen = Color(hex: "2D5016")      // Rich forest green
    static let secondaryGreen = Color(hex: "4CAF50")    // Fresh leaf green
    static let accentBlue = Color(hex: "2196F3")        // Sky blue
    static let accentOrange = Color(hex: "FF9800")      // Warm orange
    
    // Background Colors
    static let backgroundLight = Color(hex: "F1F8E9")   // Light sage
    static let backgroundWhite = Color.white
    
    // Text Colors
    static let textPrimary = Color(hex: "263238")       // Dark charcoal
    static let textSecondary = Color(hex: "546E7A")     // Medium gray
    static let textLight = Color(hex: "78909C")         // Light gray
    
    // Status Colors
    static let statusConnected = Color(hex: "4CAF50")   // Green
    static let statusDisconnected = Color(hex: "F44336") // Red
    static let statusConnecting = Color(hex: "FF9800")  // Orange
    static let statusWarning = Color(hex: "FF5722")     // Deep orange
    
    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Premium Gradients
extension LinearGradient {
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color.primaryGreen, Color.secondaryGreen],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [Color.secondaryGreen, Color.accentBlue],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.backgroundLight, Color.backgroundWhite],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Premium Card Modifier
struct PremiumCardModifier: ViewModifier {
    let elevation: CGFloat
    
    init(elevation: CGFloat = 4) {
        self.elevation = elevation
    }
    
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.backgroundWhite)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: elevation,
                        x: 0,
                        y: elevation / 2
                    )
            )
    }
}

// MARK: - Premium Button Modifier
struct PremiumButtonModifier: ViewModifier {
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary, secondary, danger, success
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .semibold, design: .default))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .shadow(
                color: shadowColor,
                radius: 2,
                x: 0,
                y: 1
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.primaryGreen
        case .secondary: return Color.backgroundWhite
        case .danger: return Color.statusWarning
        case .success: return Color.statusConnected
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .danger, .success: return Color.white
        case .secondary: return Color.textPrimary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: return Color.primaryGreen.opacity(0.3)
        case .secondary: return Color.black.opacity(0.1)
        case .danger: return Color.statusWarning.opacity(0.3)
        case .success: return Color.statusConnected.opacity(0.3)
        }
    }
}

// MARK: - Status Indicator Modifier
struct StatusIndicatorModifier: ViewModifier {
    let status: ConnectionStatus
    
    enum ConnectionStatus {
        case connected, disconnected, connecting
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(statusColor)
            .font(.system(size: 14, weight: .medium))
    }
    
    private var statusColor: Color {
        switch status {
        case .connected: return Color.statusConnected
        case .disconnected: return Color.statusDisconnected
        case .connecting: return Color.statusConnecting
        }
    }
}

// MARK: - Pressable Button Style
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Premium Pill Button
struct PremiumPillButton: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isActive ? Color.primaryGreen : Color.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.backgroundWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                isActive ? Color.primaryGreen : Color.textLight.opacity(0.3),
                                lineWidth: isActive ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: Color.black.opacity(isActive ? 0.15 : 0.08),
                radius: isActive ? 8 : 4,
                x: 0,
                y: isActive ? 4 : 2
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - View Extensions
extension View {
    func premiumCard(elevation: CGFloat = 4) -> some View {
        self.modifier(PremiumCardModifier(elevation: elevation))
    }
    
    func premiumButton(_ style: PremiumButtonModifier.ButtonStyle) -> some View {
        self.modifier(PremiumButtonModifier(style: style))
    }
    
    func statusIndicator(_ status: StatusIndicatorModifier.ConnectionStatus) -> some View {
        self.modifier(StatusIndicatorModifier(status: status))
    }
    
    func hoverEffect() -> some View {
        self.scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.2), value: true)
    }
}

// MARK: - Typography Extensions
extension Font {
    static func premiumTitle(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    static func premiumHeadline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    static func premiumBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func premiumCaption(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
}


