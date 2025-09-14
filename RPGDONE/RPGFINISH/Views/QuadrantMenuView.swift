import SwiftUI

// MARK: - Haptic Manager Import
// Note: HapticManager is already defined in the project

struct QuadrantMenuView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var audioManager = AudioManager.shared
    
    // 🧠 PSYCHO-SPIRITUAL BUTTON STATES
    @State private var buttonPressStates: [String: Bool] = [:]
    @State private var buttonGlowStates: [String: Double] = [:]
    @State private var buttonBreathingStates: [String: Bool] = [:]
    @State private var buttonHoverStates: [String: Bool] = [:]
    
    // 🔮 AMBIENT EFFECTS
    @State private var ambientPulse: Double = 0.0
    @State private var mysticalAura: Double = 0.0
    @State private var scanlineOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // MARK: - MYSTICAL CRT BACKGROUND
            Color.black
                .ignoresSafeArea()
            
            // MARK: - AMBIENT PULSE BACKGROUND
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.cyan.opacity(ambientPulse * 0.2),
                    Color.blue.opacity(ambientPulse * 0.1),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .blur(radius: 150)
            .scaleEffect(1.0 + (ambientPulse * 0.1))
            .opacity(ambientPulse)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: ambientPulse)
            
            // MARK: - SCANLINES
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.height / 3), id: \.self) { index in
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cyan.opacity(0.05))
                            .offset(x: scanlineOffset + CGFloat(index % 3) * 1.5)
                            .opacity(0.3)
                    }
                }
                .offset(y: -100)
                .clipped()
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true), value: scanlineOffset)
            
            // MARK: - MYSTICAL AURA
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(mysticalAura * 0.1),
                    Color.cyan.opacity(mysticalAura * 0.05),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .blur(radius: 150)
            .scaleEffect(1.0 + (mysticalAura * 0.1))
            .opacity(mysticalAura)
            .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: mysticalAura)
            
            // MARK: - QUADRANT BUTTONS
            VStack(spacing: 40) {
                Spacer()
                
                // MARK: - TOP ROW
                HStack(spacing: 40) {
                    mysticalButton(
                        title: "AI STORIES",
                        icon: "brain.head.profile",
                        action: { handleButtonPress("ai_stories") },
                        buttonId: "ai_stories"
                    )
                    
                    mysticalButton(
                        title: "ACHIEVEMENTS",
                        icon: "trophy.fill",
                        action: { handleButtonPress("achievements") },
                        buttonId: "achievements"
                    )
                }
                
                // MARK: - BOTTOM ROW
                HStack(spacing: 40) {
                    mysticalButton(
                        title: "SETTINGS",
                        icon: "gearshape.fill",
                        action: { handleButtonPress("settings") },
                        buttonId: "settings"
                    )
                    
                    mysticalButton(
                        title: "COMMUNITY",
                        icon: "person.3.fill",
                        action: { handleButtonPress("community") },
                        buttonId: "community"
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startPsychoSpiritualEffects()
            startButtonBreathing()
        }
    }
    
    // 🔮 MYSTICAL BUTTON COMPONENT
    private func mysticalButton(
        title: String,
        icon: String,
        action: @escaping () -> Void,
        buttonId: String
    ) -> some View {
        Button(action: {
            Task {
                await hapticManager.buttonPressHaptic(style: .standard)
            }
            action()
        }) {
            VStack(spacing: 12) {
                // Icon with mystical glow
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(buttonGlowStates[buttonId] ?? 0.0), radius: 8)
                    .scaleEffect(buttonBreathingStates[buttonId] ?? false ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: buttonBreathingStates[buttonId] ?? false)
                
                // Title with enhanced typography
                Text(title)
                    .font(.custom("SF Mono", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .tracking(2)
                    .shadow(color: .cyan.opacity(0.6), radius: 2)
            }
            .frame(width: 140, height: 140)
            .background(
                // MARK: - ENHANCED BUTTON BACKGROUND
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.cyan.opacity(buttonHoverStates[buttonId] ?? false ? 0.8 : 0.4),
                                        Color.blue.opacity(buttonHoverStates[buttonId] ?? false ? 0.6 : 0.2),
                                        Color.cyan.opacity(buttonHoverStates[buttonId] ?? false ? 0.4 : 0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: buttonHoverStates[buttonId] ?? false ? 2 : 1
                            )
                    )
                    .shadow(
                        color: .cyan.opacity((buttonGlowStates[buttonId] ?? 0.0) * 0.6),
                        radius: buttonHoverStates[buttonId] ?? false ? 12 : 6
                    )
                    .shadow(
                        color: .blue.opacity((buttonGlowStates[buttonId] ?? 0.0) * 0.3),
                        radius: buttonHoverStates[buttonId] ?? false ? 16 : 8
                    )
            )
            .scaleEffect(buttonPressStates[buttonId] ?? false ? 0.95 : 1.0)
            .blur(radius: buttonPressStates[buttonId] ?? false ? 1.0 : 0)
            .animation(.easeInOut(duration: 0.15), value: buttonPressStates[buttonId] ?? false)
            .onHover { isHovered in
                withAnimation(.easeInOut(duration: 0.3)) {
                    buttonHoverStates[buttonId] = isHovered
                }
                
                if isHovered {
                    Task {
                        await hapticManager.buttonPressHaptic(style: .light)
                    }
                }
            }
            .onTapGesture {
                // Enhanced press feedback
                withAnimation(.easeInOut(duration: 0.15)) {
                    buttonPressStates[buttonId] = true
                }
                
                // Haptic feedback
                Task {
                    await hapticManager.buttonPressHaptic(style: .standard)
                }
                
                // Visual feedback
                withAnimation(.easeInOut(duration: 0.3)) {
                    buttonGlowStates[buttonId] = 1.0
                }
                
                // Reset after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        buttonPressStates[buttonId] = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        buttonGlowStates[buttonId] = 0.0
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 🧠 BUTTON PRESS HANDLER
    private func handleButtonPress(_ buttonId: String) {
        switch buttonId {
        case "ai_stories":
            Task {
                await hapticManager.menuButtonPress()
            }
            withAnimation(.easeInOut(duration: 0.5)) {
                gameState.showingMainMenu = false
                gameState.showingAIStories = true
            }
            
        case "achievements":
            Task {
                await hapticManager.buttonPressHaptic(style: .success)
            }
            withAnimation(.easeInOut(duration: 0.5)) {
                gameState.showingMainMenu = false
                gameState.showingAchievements = true
            }
            
        case "settings":
            Task {
                await hapticManager.buttonPressHaptic(style: .light)
            }
            gameState.showingSettings = true
            
        case "community":
            Task {
                await hapticManager.buttonPressHaptic(style: .standard)
            }
            withAnimation(.easeInOut(duration: 0.5)) {
                gameState.showingMainMenu = false
                gameState.showingCommunity = true
            }
            
        default:
            Task {
                await hapticManager.buttonPressHaptic(style: .standard)
            }
        }
    }
    
    // 🔮 PSYCHO-SPIRITUAL EFFECTS
    private func startPsychoSpiritualEffects() {
        // Ambient pulse
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            ambientPulse = 1.0
        }
        
        // Mystical aura
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            mysticalAura = 1.0
        }
        
        // Scanline movement
        withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
            scanlineOffset = 2.0
        }
    }
    
    // 🫁 BUTTON BREATHING ANIMATION
    private func startButtonBreathing() {
        let buttonIds = ["ai_stories", "achievements", "settings", "community"]
        
        for (index, buttonId) in buttonIds.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                    buttonBreathingStates[buttonId] = true
                }
            }
        }
    }
}

// SACRED LOADING SCREEN - Minimal and ethereal
struct SacredLoadingScreen: View {
    let time: Double
    let fadeInOpacity: Double
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // Sacred loading text
                Text("INITIALIZING")
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
                    .offset(y: sin(time * 0.5) * 2)
                
                // Sacred loading indicator
                VStack(spacing: 15) {
                    // Minimal rotating ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.8), Color.cyan.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(time * 45))
                    }
                    
                    // Sacred text
                    Text("SIGNULL")
                        .font(.system(size: 16, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.7))
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            }
            .opacity(fadeInOpacity)
        }
    }
}

// SLEEK PARALLEL CARDS - Dynamic spacing and small size
struct SleekParallelCards: View {
    let time: Double
    let bobbingOffset: CGFloat
    let onCardSelected: (QuadrantMode) -> Void
    
    // Fixed spacing for smooth layout
    private var dynamicSpacing: CGFloat {
        return 14
    }
    
    var body: some View {
        VStack(spacing: dynamicSpacing) {
            ForEach(Array(QuadrantMode.allCases.enumerated()), id: \.element) { index, mode in
                SleekCard(
                    mode: mode,
                    index: index,
                    time: time,
                    onTap: { onCardSelected(mode) }
                )
            }
        }
    }
}

// SLEEK CARD - Small and elegant
struct SleekCard: View {
    let mode: QuadrantMode
    let index: Int
    let time: Double
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var cardBreathing: Double = 0.0
    @State private var essencePulse: Double = 0.0
    
    var body: some View {
        Button(action: {
            // Immediate haptic feedback
            Task {
                await HapticManager.shared.impact(.light)
            }
            
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            HStack(spacing: 12) {
                // Icon with subtle glow
                Text(mode.icon)
                    .font(.system(size: 20))
                    .frame(width: 24, height: 24)
                
                // Text
                Text(mode.title)
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
                
                Spacer()
                
                // Subtle arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12) // Increased vertical padding for better touch area
            .frame(maxWidth: .infinity) // Ensure full width touch area
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3 + essencePulse * 0.1),
                                        Color.cyan.opacity(0.2 + essencePulse * 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.3))
            )
            .shadow(color: Color.cyan.opacity(0.2 + essencePulse * 0.1), radius: 3, x: 0, y: 0)
            .contentShape(Rectangle()) // Ensure entire area is tappable
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(y: cardBreathing * 2)
        .opacity(0.9 + essencePulse * 0.1)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Staggered breathing animation - smoother and slower
            withAnimation(.easeInOut(duration: 3.5 + Double(index) * 0.3).repeatForever(autoreverses: true)) {
                cardBreathing = 1.0
            }
            
            // Essence pulse - smoother and slower
            withAnimation(.easeInOut(duration: 4.0 + Double(index) * 0.4).repeatForever(autoreverses: true)) {
                essencePulse = 1.0
            }
        }
    }
}

// CRT SCANLINES EFFECT
struct CRTScanlines: View {
    @State private var scanlineOffset: CGFloat = 0
    
    var body: some View {
        Canvas { context, size in
            let lineHeight: CGFloat = 2
            let lineSpacing: CGFloat = 4
            
            for y in stride(from: 0, through: size.height, by: lineSpacing) {
                let linePath = Path(CGRect(x: 0, y: y + scanlineOffset, width: size.width, height: lineHeight))
                context.fill(linePath, with: .color(.white.opacity(0.1)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: false)) {
                scanlineOffset = 4
            }
        }
    }
}

// CRT BUZZ EFFECT
struct CRTBuzz: View {
    @State private var buzzPhase: Double = 0
    
    var body: some View {
        Canvas { context, size in
            let buzzCount = Int(size.width * size.height / 2000)
            
            for _ in 0..<buzzCount {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let opacity = Double.random(in: 0...0.3)
                
                let buzzPath = Path(CGRect(x: x, y: y, width: 0.5, height: 0.5))
                context.fill(buzzPath, with: .color(.white.opacity(opacity)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: false)) {
                buzzPhase = 1.0
            }
        }
    }
}

// STORY MODE CHOICE OVERLAY - Liminal Terminal Screen
struct NavigationOverlay: View {
    let selectedMode: QuadrantMode?
    @EnvironmentObject var gameState: GameState
    @Binding var showNavigation: Bool
    @Binding var showingManualSaves: Bool
    @State private var terminalOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var buttonOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Liminal terminal background
            Color.black
                .ignoresSafeArea()
            
            // Terminal scanlines effect
            TerminalScanlines()
                .opacity(0.3)
            
            if let mode = selectedMode, mode == .storyMode {
                // Simplified terminal interface
                VStack(spacing: 60) {
                    Spacer()
                    
                    // Simple header
                    Text("FILE DETECTED")
                        .font(.custom("SF Mono", size: 18).weight(.medium))
                        .foregroundColor(Color.green)
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: 0.4), value: textOpacity)
                    
                    // Simple buttons
                    VStack(spacing: 20) {
                        // New Game Button
                        Button(action: {
                            Task {
                                await HapticManager.shared.impact(.medium)
                            }
                            
                            // Immediately set all states - no delays
                            gameState.showingBlackTransition = true
                            gameState.hasStartedGame = false
                            gameState.showingNewGameInit = true
                            gameState.showingCharacterCreation = false
                            gameState.showingIntro = false
                            
                            // Dismiss overlay immediately
                            showNavigation = false
                            
                            print("🎮 New Game button pressed - immediate transition")
                        }) {
                            Text("NEW GAME")
                                .font(.custom("SF Mono", size: 16).weight(.medium))
                                .foregroundColor(Color.green)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.5))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.green.opacity(0.6), lineWidth: 1)
                                        )
                                )
                        }
                        .opacity(buttonOpacity)
                        .animation(.easeInOut(duration: 0.4), value: buttonOpacity)
                        
                        // Load Game Button
                        Button(action: {
                            Task {
                                await HapticManager.shared.impact(.medium)
                            }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showNavigation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                // Load game logic here
                                print("🎮 Load game selected")
                            }
                        }) {
                            Text("LOAD GAME")
                                .font(.custom("SF Mono", size: 16).weight(.medium))
                                .foregroundColor(Color.green)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.5))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.green.opacity(0.6), lineWidth: 1)
                                )
                        }
                        .opacity(buttonOpacity)
                        .animation(.easeInOut(duration: 0.4), value: buttonOpacity)
                    }
                    .padding(.horizontal, 60)
                    
                    Spacer()
                }
                .opacity(terminalOpacity)
                .animation(.easeInOut(duration: 1.0), value: terminalOpacity)
                .onAppear {
                    // Pre-set the black transition state to prevent main menu flash
                    gameState.showingBlackTransition = true
                    
                    // Subtle fade-in sequence
                    withAnimation(.easeInOut(duration: 0.4)) {
                        terminalOpacity = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            textOpacity = 1.0
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            buttonOpacity = 1.0
                        }
                    }
                }
            } else {
                // Default loading overlay for other modes
                VStack(spacing: 30) {
                    Text("LOADING")
                        .font(.custom("SF Mono", size: 18).weight(.medium))
                                                    .foregroundColor(Color.green)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.green))
                        .scaleEffect(1.2)
                }
                .opacity(terminalOpacity)
                .animation(.easeInOut(duration: 1.0), value: terminalOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) { terminalOpacity = 1.0 }
                }
            }
        }
    }
}

// MARK: - Quadrant Mode Enum
enum QuadrantMode: CaseIterable {
    case storyMode
    case aiStories
    case createStory
    case community
    case settings
    
    var title: String {
        switch self {
        case .storyMode:
            return "Story Mode"
        case .aiStories:
            return "AI Stories"
        case .createStory:
            return "Create Story"
        case .community:
            return "Community"
        case .settings:
            return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .storyMode:
            return "📖"
        case .aiStories:
            return "◉"
        case .createStory:
            return "✎"
        case .community:
            return "◯"
        case .settings:
            return "⚙️"
        }
    }
}

// MARK: - Film Grain Shield Layer
struct GrainView: View {
    let intensity: Double
    @State private var grainPhase: Double = 0.0
    
    var body: some View {
        Canvas { context, size in
            let grainCount = Int(size.width * size.height / 1500)
            
            for _ in 0..<grainCount {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let opacity = Double.random(in: 0...intensity)
                
                let grainPath = Path(CGRect(x: x, y: y, width: 1, height: 1))
                context.fill(grainPath, with: .color(.white.opacity(opacity)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: false)) {
                grainPhase = 1.0
            }
        }
    }
}

// MARK: - Sleek Dream Card Component (for MainMenuView compatibility)
struct SleekDreamCard: View {
    let text: String
    let isActive: Bool
    let dreamPhase: Double
    let visibility: Double
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var cardBreathing: Double = 0.0
    @State private var essencePulse: Double = 0.0
    @State private var signalDrift: Double = 0.0
    
    // Dynamic symbolic scale based on essence level
    private var cardScaleFactor: Double {
        let essenceLevel = isActive ? 1.0 : 0.8
        let viewportCoefficient = 1.0
        return essenceLevel * viewportCoefficient
    }
    
    // Noise-based spacing drift
    private var spacingDrift: CGFloat {
        let baseSpacing: CGFloat = 8.0
        let noise = sin(signalDrift * 0.002) * 4.0
        return baseSpacing + noise
    }
    
    var body: some View {
        Button(action: {
            // Immediate haptic feedback
            Task {
                await HapticManager.shared.impact(.light)
            }
            
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            ZStack {
                // Living dream membrane - not just a rectangle
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4 + essencePulse * 0.2),
                                        Color.cyan.opacity(0.3 + essencePulse * 0.1),
                                        Color.white.opacity(0.2 + essencePulse * 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.cyan.opacity(0.3 + essencePulse * 0.2), radius: 6, x: 0, y: 0)
                
                // Glyph-weighted text with resonance
                Text(text)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.cyan.opacity(0.9 + essencePulse * 0.1), radius: 10, x: 0, y: 0)
                    .shadow(color: Color.white.opacity(0.5 + essencePulse * 0.1), radius: 5, x: 0, y: 0)
                    .shadow(color: Color.purple.opacity(0.4 + essencePulse * 0.1), radius: 7, x: 0, y: 0)
                
                // Film grain shield layer
                GrainView(intensity: 0.08)
                    .blendMode(.overlay)
                    .opacity(0.3)
            }
            .padding(.horizontal, 32 + spacingDrift)
            .padding(.vertical, 20 + spacingDrift * 0.5) // Increased vertical padding
            .frame(maxWidth: .infinity) // Ensure full width touch area
            .scaleEffect((isPressed ? 0.92 : 1.0) * cardScaleFactor * (1.0 + cardBreathing * 0.02))
            .opacity(visibility + essencePulse * 0.1)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isActive)
            .contentShape(Rectangle()) // Ensure entire area is tappable
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Breathing rhythm tied to dream phase
            withAnimation(.easeInOut(duration: 2.5 + dreamPhase).repeatForever(autoreverses: true)) {
                cardBreathing = 1.0
            }
            
            // Essence pulse for living interface
            withAnimation(.easeInOut(duration: 3.0 + dreamPhase * 0.5).repeatForever(autoreverses: true)) {
                essencePulse = 1.0
            }
            
            // Signal drift for spacing animation
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                signalDrift = 1.0
            }
        }
    }
}

// CRT-style Settings Icon with rainbow gradient and glow effects
struct SettingsIcon: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        Image(systemName: "gear")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32) // Increased size
            .foregroundStyle(
                LinearGradient(colors: [.cyan, .purple, .yellow],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .shadow(color: .purple.opacity(0.8), radius: 5) // Enhanced shadow
            .padding(10) // Increased padding
            .background(
                Circle()
                    .fill(Color.black.opacity(0.6)) // Increased opacity
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.4), lineWidth: 1.5) // Enhanced stroke
                    )
                    .blur(radius: 0.5)
            )
            .overlay(
                Circle()
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [.blue, .yellow, .purple, .blue]),
                                        center: .center),
                        lineWidth: 2.5 // Increased line width
                    )
                    .blur(radius: 0.4)
            )
            .scaleEffect(1.0)
            .rotationEffect(.degrees(rotationAngle))
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: rotationAngle)
            .onAppear {
                withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
    }
}

#Preview {
    QuadrantMenuView()
} 