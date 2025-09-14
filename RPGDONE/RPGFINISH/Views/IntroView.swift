import SwiftUI
import AVFoundation

struct IntroView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var audioManager = AudioManager.shared
    @State private var showFirst = false
    @State private var showSecond = false
    @State private var showSignull = false
    @State private var showJourney = false
    @State private var showInitializing = false
    @State private var activeDot = 0
    
    // Subtle CRT effects
    @State private var scanlineOffset: CGFloat = 0
    @State private var crtBloom: Double = 0.0
    @State private var mysticalAura: Double = 0.0
    
    // Reactive background energy
    @State private var reactiveEnergy: Double = 0.0
    @State private var textReaction: Double = 0.0
    
    // Pulsing scanline states
    @State private var pulseScanlines: [Int: Double] = [:]
    @State private var pulseTimer: Timer?
    
    // Transition state
    @State private var fadeToMainMenu: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Simple CRT bloom (reduced complexity)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.cyan.opacity(0.1),
                    Color.blue.opacity(0.05),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .blur(radius: 80)
            .opacity(crtBloom)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: crtBloom)
            
            // Simplified scanlines
            VStack(spacing: 8) {
                ForEach(0..<Int(UIScreen.main.bounds.height / 8), id: \.self) { index in
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.cyan.opacity(0.1))
                        .offset(x: scanlineOffset + CGFloat(index % 5) * 2)
                        .opacity(0.3)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 1.5, height: UIScreen.main.bounds.height * 2.0)
            .offset(y: -UIScreen.main.bounds.height * 0.2)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: scanlineOffset)
            
            // Main content
            VStack(spacing: 30) {
                Spacer()
                
                // First text
                if showFirst {
                    Text("INITIALIZING")
                        .font(.custom("SF Mono", size: 24).weight(.bold))
                        .foregroundColor(Color.cyan)
                        .tracking(4)
                        .shadow(color: Color.cyan.opacity(0.6), radius: 4)
                        .shadow(color: Color.red.opacity(0.3), radius: 2, x: -1, y: 0)
                        .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 1, y: 0)
                        .opacity(showFirst ? 1.0 : 0.0)
                        .scaleEffect(showFirst ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 1.5), value: showFirst)
                }
                
                // Second text
                if showSecond {
                    Text("SYSTEM")
                        .font(.custom("SF Mono", size: 20).weight(.medium))
                        .foregroundColor(Color.cyan.opacity(0.8))
                        .tracking(3)
                        .shadow(color: Color.cyan.opacity(0.4), radius: 2)
                        .shadow(color: Color.red.opacity(0.2), radius: 1, x: -0.5, y: 0)
                        .shadow(color: Color.blue.opacity(0.2), radius: 1, x: 0.5, y: 0)
                        .opacity(showSecond ? 1.0 : 0.0)
                        .scaleEffect(showSecond ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 1.5), value: showSecond)
                }
                
                // Signull logo
                if showSignull {
                    Text("SIGNULL")
                        .font(.custom("SF Mono", size: 36).weight(.bold))
                        .foregroundColor(Color.cyan)
                        .tracking(6)
                        .shadow(color: Color.cyan.opacity(0.8), radius: 6)
                        .shadow(color: Color.red.opacity(0.4), radius: 3, x: -2, y: 0)
                        .shadow(color: Color.blue.opacity(0.4), radius: 3, x: 2, y: 0)
                        .shadow(color: Color.green.opacity(0.3), radius: 2, x: 0, y: -1)
                        .opacity(showSignull ? 1.0 : 0.0)
                        .scaleEffect(showSignull ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 2.0), value: showSignull)
                }
                
                // Journey text
                if showJourney {
                    Text("YOUR JOURNEY BEGINS")
                        .font(.custom("SF Mono", size: 18).weight(.medium))
                        .foregroundColor(Color.cyan.opacity(0.9))
                        .tracking(2)
                        .shadow(color: Color.cyan.opacity(0.5), radius: 3)
                        .shadow(color: Color.red.opacity(0.2), radius: 1, x: -0.5, y: 0)
                        .shadow(color: Color.blue.opacity(0.2), radius: 1, x: 0.5, y: 0)
                        .opacity(showJourney ? 1.0 : 0.0)
                        .scaleEffect(showJourney ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 1.8), value: showJourney)
                }
                
                // Initializing dots
                if showInitializing {
                    HStack(spacing: 8) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 8, height: 8)
                                .opacity(activeDot >= index ? 1.0 : 0.3)
                                .scaleEffect(activeDot == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: activeDot)
                        }
                    }
                    .opacity(showInitializing ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0), value: showInitializing)
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .opacity(fadeToMainMenu ? 0.0 : 1.0)
        .animation(.easeInOut(duration: 2.0), value: fadeToMainMenu)
        .onAppear {
            print("🔍 DEBUG: IntroView appeared")
            audioManager.playIntroMusic()
            startCRTEffects()
            runIntroSequence()
        }
    }
    
    private func triggerReactiveEnergy() {
        withAnimation(.easeInOut(duration: 0.8)) {
            reactiveEnergy = 1.0
            textReaction = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.6)) {
                reactiveEnergy = 0.0
                textReaction = 0.0
            }
        }
    }
    
    private func startCRTEffects() {
        // Start CRT bloom
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            crtBloom = 1.0
        }
        
        // Start scanline movement
        withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
            scanlineOffset = 2.0
        }
        
        // Start mystical aura
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            mysticalAura = 1.0
        }
    }
    
    private func startDotAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                activeDot = (activeDot + 1) % 3
            }
        }
    }
    
    private func runIntroSequence() {
        // Start audio
        audioManager.playIntroMusic()
        
        // Start CRT effects
        startCRTEffects()
        
        // Start pulsing scanlines
        startPulsingScanlines()
        
        // Sequential timing - proper flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { // Added 0.4s (was 1.0)
            withAnimation(.easeInOut(duration: 1.2)) {
                showFirst = true
            }
            triggerReactiveEnergy()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.4) { // Added 0.4s (was 4.0)
            withAnimation(.easeOut(duration: 0.8)) {
                showFirst = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    showSecond = true
                }
                triggerReactiveEnergy()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.4) { // Added 0.4s (was 7.0)
            withAnimation(.easeOut(duration: 0.8)) {
                showSecond = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 2.0)) { // Increased duration for smoother flow
                    showSignull = true
                }
                triggerReactiveEnergy()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.4) { // Added 0.4s (was 10.0)
            withAnimation(.easeInOut(duration: 1.8)) { // Increased duration for smoother flow
                showJourney = true
            }
            triggerReactiveEnergy()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.4) { // Added 0.4s (was 12.0)
            withAnimation(.easeInOut(duration: 1.0)) {
                showInitializing = true
            }
            triggerReactiveEnergy()
        }
        
        // Start dot cycling
        startDotCycling()
        
        // Transition to main menu after sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.4) { // Added 0.4s (was 15.0)
            withAnimation(.easeInOut(duration: 2.0)) {
                fadeToMainMenu = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                gameState.showingMainMenu = true
            }
        }
    }
    
    private func startPulsingScanlines() {
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in // Increased interval for better performance
            // Randomly select scanlines to pulse with CRT-centric colors
            let randomIndex = Int.random(in: 0..<Int(UIScreen.main.bounds.height / 4)) // Adjusted for new density
            
            withAnimation(.easeInOut(duration: 1.0)) { // Slower animation
                pulseScanlines[randomIndex] = 1.0
            }
            
            // Reset pulse after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    pulseScanlines[randomIndex] = 0.0
                }
            }
        }
    }
    
    private func startDotCycling() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if activeDot < 3 {
                activeDot += 1
            } else {
                activeDot = 0
            }
        }
    }
    
    private func getPulseColor(for index: Int) -> Color {
        let pulseValue = pulseScanlines[index] ?? 0
        
        if pulseValue > 0.5 {
            return Color.red.opacity(0.4 + pulseValue * 0.2) // Simplified pulse logic
        } else if index % 20 == 0 && reactiveEnergy > 0.5 {
            return Color.cyan.opacity(0.3) // Simplified reactive logic
        } else if index % 10 == 0 {
            return Color.cyan.opacity(0.2) // Simplified base logic
        } else {
            return Color.cyan.opacity(0.1) // Simplified base color
        }
    }
}

// Optimized scanline view for better performance
struct ScanlineView: View {
    let index: Int
    let scanlineOffset: CGFloat
    let reactiveEnergy: Double
    let pulseScanlines: [Int: Double]
    let getPulseColor: (Int) -> Color
    
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(getPulseColor(index))
            .offset(x: scanlineOffset + CGFloat(index % 5) * 0.8)
            .opacity(0.1 + (Double(index % 6) * 0.02) + (pulseScanlines[index] ?? 0) * 0.05) // Simplified opacity calculation
            .scaleEffect(1.0 + (reactiveEnergy * 0.02) + (pulseScanlines[index] ?? 0) * 0.05) // Reduced scaling for performance
            .blur(radius: 0.5) // Reduced blur for performance
            .shadow(color: getPulseColor(index).opacity(0.2), radius: 1 + (pulseScanlines[index] ?? 0), x: 0, y: 0) // Simplified shadow
    }
}