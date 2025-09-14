import SwiftUI
import Metal

// MARK: - Atmospheric Effects View

struct AtmosphericEffectsView: View {
    let corruption: Double
    let sanity: Double
    let isBroken: Bool
    let timeOfDay: TimeOfDay
    let weather: WeatherType
    
    @State private var pulse = false
    @State private var float = false
    @State private var shimmer = false
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base atmospheric layer
            baseAtmosphere
            
            // Weather effects
            weatherEffects
            
            // Time of day effects
            timeEffects
            
            // Corruption effects
            corruptionEffects
            
            // Sanity effects
            sanityEffects
            
            // Particle systems
            particleSystems
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Base Atmosphere
    
    private var baseAtmosphere: some View {
        GeometryReader { geo in
            ZStack {
                // Dynamic background gradient
                LinearGradient(
                    gradient: Gradient(colors: backgroundColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .blur(radius: 0.5)
                
                // Ambient light
                RadialGradient(
                    gradient: Gradient(colors: [
                        ambientColor.opacity(0.15 + (pulse ? 0.05 : 0)),
                        Color.clear
                    ]),
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: geo.size.height * 0.6
                )
                .blur(radius: 20)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: pulse)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Weather Effects
    
    private var weatherEffects: some View {
        GeometryReader { geo in
            ZStack {
                switch weather {
                case .rainy, .stormy, .storm:
                    rainEffect(geo: geo)
                case .foggy:
                    fogEffect(geo: geo)
                case .windy:
                    windEffect(geo: geo)
                case .magical, .mystical:
                    magicalEffect(geo: geo)
                case .cursed:
                    cursedEffect(geo: geo)
                default:
                    EmptyView()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func rainEffect(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<Int(geo.size.width / 20), id: \.self) { _ in
                Rectangle()
                    .fill(Theme.neonBlue.opacity(0.6))
                    .frame(width: 1, height: 20)
                    .offset(x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2))
                    .offset(y: float ? geo.size.height : -20)
                    .animation(
                        .linear(duration: Double.random(in: 0.8...1.5))
                        .repeatForever(autoreverses: false),
                        value: float
                    )
            }
        }
    }
    
    private func fogEffect(geo: GeometryProxy) -> some View {
        ForEach(0..<5, id: \.self) { index in
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.white.opacity(0.1))
                .frame(width: CGFloat.random(in: 100...200))
                .frame(height: 50)
                .offset(
                    x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                    y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                )
                .blur(radius: 30)
                .opacity(shimmer ? 0.3 : 0.1)
                .animation(
                    .easeInOut(duration: Double.random(in: 3...6))
                    .repeatForever(autoreverses: true),
                    value: shimmer
                )
        }
    }
    
    private func windEffect(geo: GeometryProxy) -> some View {
        ForEach(0..<8, id: \.self) { index in
            Circle()
                .fill(Theme.accentBeige.opacity(0.2))
                .frame(width: CGFloat.random(in: 10...30))
                .offset(
                    x: particleOffset + CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                    y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                )
                .blur(radius: 5)
                .animation(
                    .linear(duration: 8.0)
                    .repeatForever(autoreverses: false),
                    value: particleOffset
                )
        }
    }
    
    private func magicalEffect(geo: GeometryProxy) -> some View {
        ForEach(0..<12, id: \.self) { index in
            Circle()
                .fill(Theme.neonPurple.opacity(0.4))
                .frame(width: CGFloat.random(in: 5...15))
                .offset(
                    x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                    y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                )
                .scaleEffect(shimmer ? 1.5 : 0.5)
                .opacity(shimmer ? 0.8 : 0.3)
                .animation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true),
                    value: shimmer
                )
        }
    }
    
    private func cursedEffect(geo: GeometryProxy) -> some View {
        ForEach(0..<6, id: \.self) { index in
            RoundedRectangle(cornerRadius: 2)
                .fill(Theme.corruptionColor.opacity(0.3))
                .frame(width: CGFloat.random(in: 20...60))
                .frame(height: 2)
                .offset(
                    x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                    y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                )
                .rotationEffect(.degrees(shimmer ? 45 : -45))
                .opacity(shimmer ? 0.6 : 0.2)
                .animation(
                    .easeInOut(duration: Double.random(in: 2...5))
                    .repeatForever(autoreverses: true),
                    value: shimmer
                )
        }
    }
    
    // MARK: - Time Effects
    
    private var timeEffects: some View {
        GeometryReader { geo in
            ZStack {
                switch timeOfDay {
                case .dawn:
                    dawnEffect(geo: geo)
                case .dusk:
                    duskEffect(geo: geo)
                case .night, .midnight:
                    nightEffect(geo: geo)
                default:
                    EmptyView()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func dawnEffect(geo: GeometryProxy) -> some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Theme.neonOrange.opacity(0.2),
                Color.clear
            ]),
            center: .topLeading,
            startRadius: 0,
            endRadius: geo.size.width * 0.8
        )
        .blur(radius: 15)
    }
    
    private func duskEffect(geo: GeometryProxy) -> some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Theme.neonOrange.opacity(0.15),
                Color.clear
            ]),
            center: .topTrailing,
            startRadius: 0,
            endRadius: geo.size.width * 0.8
        )
        .blur(radius: 15)
    }
    
    private func nightEffect(geo: GeometryProxy) -> some View {
        ZStack {
            // Starlight effect
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: CGFloat.random(in: 1...3))
                    .offset(
                        x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                        y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                    )
                    .opacity(shimmer ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1...3))
                        .repeatForever(autoreverses: true),
                        value: shimmer
                    )
            }
            
            // Moonlight
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 0,
                endRadius: geo.size.width * 0.6
            )
            .blur(radius: 20)
        }
    }
    
    // MARK: - Corruption Effects
    
    private var corruptionEffects: some View {
        GeometryReader { geo in
            ZStack {
                if corruption > 0.3 {
                    // Corruption tendrils
                    ForEach(0..<Int(corruption * 10), id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Theme.corruptionColor.opacity(0.4))
                            .frame(width: 2)
                            .frame(height: CGFloat.random(in: 50...150))
                            .offset(
                                x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                                y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                            )
                            .rotationEffect(.degrees(shimmer ? 15 : -15))
                            .opacity(shimmer ? 0.8 : 0.3)
                            .animation(
                                .easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true),
                                value: shimmer
                            )
                    }
                }
                
                if corruption > 0.7 {
                    // Corruption overlay
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Theme.corruptionColor.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.5
                    )
                    .blur(radius: 30)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Sanity Effects
    
    private var sanityEffects: some View {
        GeometryReader { geo in
            ZStack {
                if sanity < 0.5 {
                    // Reality distortion
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 100)
                            .fill(Theme.sanityColor.opacity(0.1))
                            .frame(width: CGFloat.random(in: 200...400))
                            .frame(height: CGFloat.random(in: 200...400))
                            .offset(
                                x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                                y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                            )
                            .blur(radius: 50)
                            .scaleEffect(shimmer ? 1.2 : 0.8)
                            .opacity(shimmer ? 0.3 : 0.1)
                            .animation(
                                .easeInOut(duration: Double.random(in: 4...8))
                                .repeatForever(autoreverses: true),
                                value: shimmer
                            )
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Particle Systems
    
    private var particleSystems: some View {
        GeometryReader { geo in
            ZStack {
                // Ambient particles
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(Theme.primaryGreen.opacity(0.2))
                        .frame(width: CGFloat.random(in: 2...6))
                        .offset(
                            x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2),
                            y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2)
                        )
                        .scaleEffect(shimmer ? 1.5 : 0.5)
                        .opacity(shimmer ? 0.6 : 0.2)
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true),
                            value: shimmer
                        )
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColors: [Color] {
        switch weather {
        case .rainy, .stormy, .storm:
            return [Theme.darkBackground, Color.black, Theme.neonBlue.opacity(0.1)]
        case .foggy:
            return [Theme.darkBackground, Color.gray.opacity(0.3), Color.black]
        case .windy:
            return [Theme.darkBackground, Theme.accentBeige.opacity(0.1), Color.black]
        case .magical, .mystical:
            return [Theme.darkBackground, Theme.neonPurple.opacity(0.1), Color.black]
        case .cursed:
            return [Theme.darkBackground, Theme.corruptionColor.opacity(0.1), Color.black]
        default:
            return [Theme.darkBackground, Color.black]
        }
    }
    
    private var ambientColor: Color {
        switch timeOfDay {
        case .dawn: return Theme.neonOrange
        case .dusk: return Theme.neonOrange
        case .night, .midnight: return Theme.neonBlue
        default: return Theme.primaryGreen
        }
    }
    
    // MARK: - Animation Control
    
    private func startAnimations() {
        pulse = true
        float = true
        shimmer = true
        particleOffset = 1000
    }
}

// MARK: - Visual Effects System
// VisualEffect enum is defined in GameState.swift

struct VisualEffectsView: View {
    let effect: VisualEffect
    let intensity: Double // 0.0 to 1.0
    
    @State private var animationPhase: Double = 0.0
    @State private var distortionOffset: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base content goes here
                Color.clear
                
                // Apply visual effects based on type
                switch effect {
                case .none:
                    EmptyView()
                    
                case .glow:
                    magicFlickerEffect
                    
                case .sparkle:
                    magicFlickerEffect
                    
                case .shadow:
                    corruptionGlowEffect
                    
                case .mist:
                    ancientOnePresenceEffect
                    
                case .light:
                    magicFlickerEffect
                    
                case .dark:
                    corruptionGlowEffect
                    
                case .color:
                    magicFlickerEffect
                    
                case .pulse:
                    magicFlickerEffect
                    
                case .wave:
                    alcoholDistortionEffect
                    
                case .corruption:
                    corruptionGlowEffect
                    
                case .redemption:
                    magicFlickerEffect
                }
            }
            .onAppear {
                startAnimation()
            }
        }
    }
    
    // MARK: - Effect Implementations
    
    private var alcoholDistortionEffect: some View {
        ZStack {
            // Wave distortion
            ForEach(0..<3, id: \.self) { wave in
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.orange.opacity(0.1), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(1.0 + sin(animationPhase + Double(wave)) * 0.1)
                    .rotationEffect(.degrees(sin(animationPhase * 0.5) * 2))
                    .opacity(0.3)
            }
            
            // Blur overlay
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .blur(radius: 2.0)
        }
    }
    
    private var magicFlickerEffect: some View {
        ZStack {
            // Magic energy particles
            ForEach(0..<20, id: \.self) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 4, height: 4)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(sin(animationPhase + Double(particle)) * 0.5 + 0.5)
                    .scaleEffect(sin(animationPhase * 2 + Double(particle)) * 0.3 + 0.7)
            }
            
            // Ambient glow
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .opacity(sin(animationPhase * 0.5) * 0.3 + 0.2)
        }
    }
    
    private var corruptionGlowEffect: some View {
        ZStack {
            // Dark corruption aura
            ForEach(0..<5, id: \.self) { layer in
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.3), Color.black.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300 + Double(layer * 50)
                        )
                    )
                    .scaleEffect(1.0 + sin(animationPhase + Double(layer)) * 0.05)
                    .opacity(0.4)
            }
            
            // Corruption particles
            ForEach(0..<15, id: \.self) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.8), Color.black.opacity(0.6), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 6, height: 6)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(sin(animationPhase * 1.5 + Double(particle)) * 0.4 + 0.6)
                    .scaleEffect(sin(animationPhase * 3 + Double(particle)) * 0.2 + 0.8)
            }
        }
    }
    
    private var ancientOnePresenceEffect: some View {
        ZStack {
            // Ethereal mist
            ForEach(0..<8, id: \.self) { mist in
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.2), Color.cyan.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(Double(mist) * 45 + animationPhase * 10))
                    .scaleEffect(1.0 + sin(animationPhase + Double(mist)) * 0.1)
                    .opacity(0.3)
            }
            
            // Ancient symbols (simplified)
            ForEach(0..<6, id: \.self) { symbol in
                Text("✧")
                    .font(.system(size: 20))
                    .foregroundColor(.cyan.opacity(0.6))
                    .position(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 50...UIScreen.main.bounds.height - 50)
                    )
                    .opacity(sin(animationPhase * 0.8 + Double(symbol)) * 0.5 + 0.5)
                    .scaleEffect(sin(animationPhase * 2 + Double(symbol)) * 0.3 + 0.7)
            }
            
            // Ambient ethereal glow
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyan.opacity(0.15), Color.white.opacity(0.05), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .opacity(sin(animationPhase * 0.3) * 0.2 + 0.3)
        }
    }
    
    private var betrayalShockEffect: some View {
        ZStack {
            // Shock waves
            ForEach(0..<4, id: \.self) { wave in
                Circle()
                    .stroke(Color.red.opacity(0.4), lineWidth: 2)
                    .scaleEffect(1.0 + sin(animationPhase * 2 + Double(wave)) * 0.3)
                    .opacity(max(0, 1.0 - animationPhase * 0.5))
            }
            
            // Screen shake effect
            Rectangle()
                .fill(Color.red.opacity(0.1))
                .offset(x: sin(animationPhase * 20) * 5, y: cos(animationPhase * 15) * 3)
                .opacity(sin(animationPhase * 3) * 0.3 + 0.1)
            
            // Betrayal particles
            ForEach(0..<25, id: \.self) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.red.opacity(0.8), Color.orange.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 12
                        )
                    )
                    .frame(width: 3, height: 3)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(sin(animationPhase * 4 + Double(particle)) * 0.6 + 0.4)
                    .scaleEffect(sin(animationPhase * 5 + Double(particle)) * 0.4 + 0.6)
            }
        }
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
        
        // Start distortion animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            distortionOffset = 1.0
        }
    }
}

// MARK: - Effect Modifier

struct VisualEffectModifier: ViewModifier {
    let effect: VisualEffect
    let intensity: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if effect != .none {
                VisualEffectsView(effect: effect, intensity: intensity)
                    .allowsHitTesting(false)
            }
        }
    }
}

extension View {
    func visualEffect(_ effect: VisualEffect, intensity: Double = 1.0) -> some View {
        modifier(VisualEffectModifier(effect: effect, intensity: intensity))
    }
}

// MARK: - Ambient Audio Visualizer

struct AmbientVisualizerView: View {
    @ObservedObject var audioManager: AudioManager
    @State private var animationPhase: Double = 0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: index))
                    .frame(width: 3, height: barHeight(for: index))
                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: animationPhase)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 10
        let maxHeight: CGFloat = 50
        
        switch audioManager.currentTrack {
        case "Celestial":
            // Gentle, slow waves
            return baseHeight + maxHeight * 0.3 * sin(Double(index) * 0.3 + animationPhase * 2)
        case "Bliss":
            // Intense, rapid pulses
            return baseHeight + maxHeight * 0.8 * sin(Double(index) * 0.8 + animationPhase * 4)
        case "Rain2":
            // Steady, rhythmic drops
            return baseHeight + maxHeight * 0.5 * sin(Double(index) * 0.5 + animationPhase * 1.5)
        case "Liminal":
            // Flowing, wave-like motion
            return baseHeight + maxHeight * 0.4 * sin(Double(index) * 0.4 + animationPhase * 1.2)
        case "Night":
            // Subtle, ambient glow
            return baseHeight + maxHeight * 0.2 * sin(Double(index) * 0.2 + animationPhase * 0.8)
        default:
            return baseHeight
        }
    }
    
    private func barColor(for index: Int) -> Color {
        switch audioManager.currentTrack {
        case "Celestial":
            return Color.blue.opacity(0.6)
        case "Bliss":
            return Color.purple.opacity(0.8)
        case "Rain2":
            return Color.cyan.opacity(0.7)
        case "Liminal":
            return Color.green.opacity(0.6)
        case "Night":
            return Color.indigo.opacity(0.5)
        default:
            return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Weather Overlays
struct WindOverlay: View {
    let animationPhase: Double
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<20, id: \ .self) { gust in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 60, height: 4)
                        .offset(x: CGFloat((Double(gust) * 50 + animationPhase * 80).truncatingRemainder(dividingBy: Double(geometry.size.width + 80)) - 80),
                                y: CGFloat(gust * 18 % Int(geometry.size.height)))
                        .rotationEffect(.degrees(Double(gust) * 2 + animationPhase * 10))
                        .opacity(0.5)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Rain Overlay
struct RainOverlay: View {
    @State private var animationPhase: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Rain drops
                ForEach(0..<50, id: \.self) { drop in
                    Capsule()
                        .fill(Color.cyan.opacity(0.3))
                        .frame(width: 1, height: CGFloat.random(in: 10...25))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 1.0...2.5))
                                .repeatForever(autoreverses: false),
                            value: animationPhase
                        )
                }
                
                // Rain streaks
                ForEach(0..<30, id: \.self) { streak in
                    Rectangle()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 1, height: CGFloat.random(in: 20...40))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 0.8...2.0))
                                .repeatForever(autoreverses: false),
                            value: animationPhase
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
    }
}

// MARK: - Preview

struct VisualEffectsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Glow Effect")
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(Color.black)
                .visualEffect(.glow, intensity: 1.0)
            
            Text("Shadow Effect")
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(Color.black)
                .visualEffect(.shadow, intensity: 1.0)
            
            Text("Mist Effect")
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(Color.black)
                .visualEffect(.mist, intensity: 1.0)
        }
        .previewLayout(.sizeThatFits)
    }
} 