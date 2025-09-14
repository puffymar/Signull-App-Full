import SwiftUI

enum Theme {
    // Core Colors
    static let terminalGreen = Color(red: 0.1, green: 0.8, blue: 0.4)
    static let darkBackground = Color(red: 0.05, green: 0.08, blue: 0.07)
    static let accentBeige = Color(red: 0.8, green: 0.75, blue: 0.65)
    
    // Enhanced Color Palette
    static let primaryGreen = Color(red: 0.0, green: 0.9, blue: 0.5)
    static let secondaryGreen = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let darkGreen = Color(red: 0.0, green: 0.4, blue: 0.2)
    
    // Premium Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryGreen, secondaryGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let darkGradient = LinearGradient(
        colors: [darkBackground, Color.black],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Spinner Colors
    static let spinnerGray = Color(red: 0.4, green: 0.4, blue: 0.45)      // Common
    static let spinnerGreen = Color(red: 0.2, green: 0.6, blue: 0.5)     // Uncommon
    static let spinnerOrange = Color(red: 0.9, green: 0.5, blue: 0.2)    // Rare
    static let spinnerYellow = Color(red: 0.9, green: 0.8, blue: 0.3)    // Legendary
    
    static let mutedGold = Color(red: 0.85, green: 0.72, blue: 0.38)
    static let mutedMenu = Color(red: 0.55, green: 0.65, blue: 0.68)
    
    // Enhanced Neon Colors
    static let neonOrange = Color(red: 1.0, green: 0.6, blue: 0.1)
    static let neonBlue = Color(red: 0.1, green: 0.9, blue: 1.0)
    static let neonPurple = Color(red: 0.8, green: 0.2, blue: 1.0)
    static let neonRed = Color(red: 1.0, green: 0.2, blue: 0.3)
    static let neonGlow = Color.white.opacity(0.7)
    
    // Status Colors
    static let healthColor = Color(red: 0.9, green: 0.3, blue: 0.3)
    static let manaColor = Color(red: 0.3, green: 0.6, blue: 0.9)
    static let staminaColor = Color(red: 0.9, green: 0.7, blue: 0.2)
    static let magicColor = Color(red: 0.6, green: 0.3, blue: 0.9)
    static let energyColor = Color(red: 0.9, green: 0.8, blue: 0.2)
    static let strengthColor = Color(red: 0.8, green: 0.4, blue: 0.2)
    static let intelligenceColor = Color(red: 0.2, green: 0.6, blue: 0.8)
    static let charismaColor = Color(red: 0.8, green: 0.2, blue: 0.6)
    static let corruptionColor = Color(red: 0.8, green: 0.2, blue: 0.8)
    static let sanityColor = Color(red: 0.2, green: 0.8, blue: 0.8)
    
    // Typography
    static func terminalFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func titleFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
    
    static func subtitleFont(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static func bodyFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    
    // Shadows and Effects
    static let primaryShadow = Color.black.opacity(0.3)
    static let glowShadow = primaryGreen.opacity(0.5)
    static let glassShadow = Color.white.opacity(0.1)
    
    // Animation Durations
    static let quickAnimation: Double = 0.2
    static let standardAnimation: Double = 0.3
    static let slowAnimation: Double = 0.6
    static let atmosphericAnimation: Double = 4.0
}

// MARK: - Enhanced UI Components

struct FramedBox<Content: View>: View {
    let content: Content
    let style: FrameStyle
    
    enum FrameStyle {
        case standard, premium, glass, neon
    }
    
    init(style: FrameStyle = .standard, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(backgroundForStyle)
            .overlay(borderForStyle)
            .shadow(color: shadowForStyle, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    @ViewBuilder
    private var backgroundForStyle: some View {
        switch style {
        case .standard:
            Theme.darkBackground.opacity(0.5)
        case .premium:
            Theme.glassGradient
        case .glass:
            Color.white.opacity(0.1)
        case .neon:
            Color.black.opacity(0.3)
        }
    }
    
    @ViewBuilder
    private var borderForStyle: some View {
        switch style {
        case .standard:
            Rectangle()
                .stroke(Theme.terminalGreen.opacity(0.4), lineWidth: 1)
        case .premium:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.primaryGradient, lineWidth: 2)
        case .glass:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.glassShadow, lineWidth: 1)
        case .neon:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.primaryGreen, lineWidth: 2)
                .shadow(color: Theme.glowShadow, radius: 8, x: 0, y: 0)
        }
    }
    
    private var shadowForStyle: Color {
        switch style {
        case .standard: return Theme.primaryShadow
        case .premium: return Theme.primaryShadow
        case .glass: return Theme.glassShadow
        case .neon: return Theme.glowShadow
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .standard: return 4
        case .premium: return 8
        case .glass: return 12
        case .neon: return 16
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .standard: return 2
        case .premium: return 4
        case .glass: return 6
        case .neon: return 8
        }
    }
}

struct SegmentedProgressView: View {
    var value: Double // 0.0 to 1.0
    let segmentCount: Int = 10
    let style: ProgressStyle
    
    enum ProgressStyle {
        case standard, health, mana, stamina, corruption, sanity
    }
    
    init(value: Double, style: ProgressStyle = .standard) {
        self.value = value
        self.style = style
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<segmentCount, id: \.self) { index in
                Rectangle()
                    .fill(fillColor(for: index))
                    .animation(.easeInOut(duration: 0.3), value: value)
            }
        }
        .frame(height: 12)
        .overlay(
            Rectangle()
                .stroke(borderColor, lineWidth: 1)
        )
        .padding(.horizontal, 4)
    }
    
    private func fillColor(for index: Int) -> Color {
        let activeSegments = Int(value * Double(segmentCount))
        return index < activeSegments ? progressColor : .clear
    }
    
    private var progressColor: Color {
        switch style {
        case .standard: return Theme.primaryGreen
        case .health: return Theme.healthColor
        case .mana: return Theme.manaColor
        case .stamina: return Theme.staminaColor
        case .corruption: return Theme.corruptionColor
        case .sanity: return Theme.sanityColor
        }
    }
    
    private var borderColor: Color {
        progressColor.opacity(0.4)
    }
}

// MARK: - Premium Button Styles

struct PremiumButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    let style: ButtonStyle
    let isEnabled: Bool
    
    enum ButtonStyle {
        case primary, secondary, danger, glass, neon
    }
    
    init(style: ButtonStyle = .primary, isEnabled: Bool = true, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .font(Theme.subtitleFont(size: 18))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundForStyle)
                .overlay(borderForStyle)
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .opacity(isEnabled ? 1.0 : 0.6)
        .animation(.easeInOut(duration: Theme.quickAnimation), value: isEnabled)
    }
    
    private var foregroundColor: Color {
        guard isEnabled else { return .gray }
        
        switch style {
        case .primary: return .white
        case .secondary: return Theme.primaryGreen
        case .danger: return .white
        case .glass: return .white
        case .neon: return Theme.primaryGreen
        }
    }
    
    @ViewBuilder
    private var backgroundForStyle: some View {
        switch style {
        case .primary:
            Theme.primaryGradient
        case .secondary:
            Color.clear
        case .danger:
            LinearGradient(colors: [Theme.neonRed, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .glass:
            Color.white.opacity(0.1)
        case .neon:
            Color.black.opacity(0.3)
        }
    }
    
    @ViewBuilder
    private var borderForStyle: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.primaryGreen, lineWidth: 2)
        case .secondary:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.primaryGreen, lineWidth: 2)
        case .danger:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.neonRed, lineWidth: 2)
        case .glass:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.glassShadow, lineWidth: 1)
        case .neon:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.primaryGreen, lineWidth: 2)
                .shadow(color: Theme.glowShadow, radius: 8, x: 0, y: 0)
        }
    }
    
    private var shadowColor: Color {
        guard isEnabled else { return .clear }
        
        switch style {
        case .primary: return Theme.glowShadow
        case .secondary: return Theme.primaryShadow
        case .danger: return Theme.neonRed.opacity(0.5)
        case .glass: return Theme.glassShadow
        case .neon: return Theme.glowShadow
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary: return 12
        case .secondary: return 4
        case .danger: return 12
        case .glass: return 8
        case .neon: return 16
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .primary: return 6
        case .secondary: return 2
        case .danger: return 6
        case .glass: return 4
        case .neon: return 8
        }
    }
} 