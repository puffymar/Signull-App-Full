import SwiftUI

// MARK: - Clean Loading Bar
struct WaveformBar: View {
    let progress: Double
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            Rectangle()
                .fill(Color.black.opacity(0.4))
                .frame(height: 12)
                .cornerRadius(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.green.opacity(0.15), lineWidth: 1)
                )
            
            // Progress fill
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.5),
                            Color.green.opacity(0.7),
                            Color.green.opacity(0.5)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 320 * progress, height: 12)
                .cornerRadius(2)
                .shadow(color: Color.green.opacity(0.15), radius: 2, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Subtle glow at the end
            if progress > 0.1 {
                Rectangle()
                    .fill(Color.green.opacity(0.25 * glowIntensity))
                    .frame(width: 8, height: 12)
                    .cornerRadius(2)
                    .offset(x: (320 * progress) - 8)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(width: 320)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowIntensity = 0.8
            }
        }
    }
}

struct NewGameInitView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var audioManager = AudioManager.shared
    @State private var breathingScale: Double = 0.8
    @StateObject private var abilityManager = AbilityManager.shared
    @State private var currentPhase: InitPhase = .welcome
    @State private var loadingText = ""
    @State private var loadingProgress = 0.0
    @State private var showLoadingText = false
    @State private var generatedAbility: Ability?
    @State private var fadeOpacity = 0.0
    @State private var canSkip = false
    @State private var skipTimer: Timer?
    @State private var welcomeScale = 0.8
    @State private var welcomeOpacity: Double = 0.0
    @State private var ohOpacity: Double = 0.0
    @State private var whoOpacity: Double = 0.0
    @State private var slitOpacity: Double = 0.0
    @State private var journeyOpacity: Double = 0.0
    @State private var choicesOpacity: Double = 0.0
    @State private var symbolOpacity: Double = 0.0
    @State private var groupOpacity: Double = 1.0 // For unified fade out
    @State private var generatedTraits: [Trait] = []
    @State private var transitionOpacity = 0.0
    @State private var animateAbilityReveal = false
    @State private var loadingOpacity: Double = 0.0

    enum InitPhase {
        case welcome
        case loading
        case cognitiveChecks
        case geneticAnalysis
        case abilityGeneration
        case traitGeneration
        case abilityResult
        case complete
    }
    
    var body: some View {
        ZStack {
            // Dark terminal background for ALL phases
            Color.black
                .ignoresSafeArea()
            
            // Full initialization sequence
            switch currentPhase {
            case .welcome:
                welcomeView
            case .loading:
                loadingView
            case .cognitiveChecks:
                cognitiveChecksView
            case .geneticAnalysis:
                geneticAnalysisView
            case .abilityGeneration:
                abilityGenerationView
            case .traitGeneration:
                traitGenerationView
            case .abilityResult:
                abilityResultView
            case .complete:
                completeView
            }
        }
        .opacity(transitionOpacity)
        .animation(.easeInOut(duration: 1.5), value: transitionOpacity)
        .onAppear {
            // Continue music from main menu
            if !audioManager.isPlaying {
                audioManager.playMenuMusic()
            }
            
            // Smooth fade-in transition
            withAnimation(.easeInOut(duration: 0.7)) {
                transitionOpacity = 1.0
            }
            
            // Start breathing animation for background
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) { // Slower
                breathingScale = 1.0
            }
        }
    }
    
    private var welcomeView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Centered cinematic sequence - individual fade in, unified fade out
                VStack(spacing: 50) {
                    // First message - legendary wisdom speaking
                    VStack(spacing: 12) {
                        Text("Oh...")
                            .font(.custom("Georgia", size: 26).weight(.light))
                            .foregroundColor(.orange)
                            .opacity(ohOpacity)
                            .offset(y: ohOpacity == 0 ? 10 : 0)
                            .animation(.easeInOut(duration: 1.5).delay(0.8), value: ohOpacity)
                        
                        Text("Who do we have here?")
                            .font(.custom("Georgia", size: 26).weight(.light))
                            .foregroundColor(.orange)
                            .opacity(whoOpacity)
                            .offset(y: whoOpacity == 0 ? 10 : 0)
                            .animation(.easeInOut(duration: 1.5).delay(2.0), value: whoOpacity)
                    }
                    
                    // Green loading slit - perfectly centered
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.green.opacity(0.0),
                                    Color.green.opacity(0.8),
                                    Color.green.opacity(0.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 1, height: 80)
                        .opacity(slitOpacity)
                        .scaleEffect(slitOpacity > 0 ? 1.0 : 0.3)
                        .animation(.easeInOut(duration: 1.0).delay(4.0), value: slitOpacity)
                    
                    // Wisdom message - perfectly aligned
                    VStack(spacing: 12) {
                        Text("Prepare yourself for this journey")
                            .font(.custom("Georgia", size: 22).weight(.light))
                            .foregroundColor(.orange)
                            .opacity(journeyOpacity)
                            .offset(y: journeyOpacity == 0 ? 10 : 0)
                            .animation(.easeInOut(duration: 1.5).delay(6.0), value: journeyOpacity)
                        
                        Text("you will face treacherous choices")
                            .font(.custom("Georgia", size: 20).weight(.light))
                            .foregroundColor(.orange)
                            .opacity(choicesOpacity)
                            .offset(y: choicesOpacity == 0 ? 10 : 0)
                            .animation(.easeInOut(duration: 1.5).delay(8.0), value: choicesOpacity)
                    }
                    
                    // Cool symbol at the end
                    Text("✦")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.orange)
                        .opacity(symbolOpacity)
                        .scaleEffect(symbolOpacity > 0 ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: 1.0).delay(10.0), value: symbolOpacity)
                }
                .frame(maxWidth: .infinity)
                .opacity(groupOpacity) // For unified fade out
                .animation(.easeInOut(duration: 3.0), value: groupOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            // Reset all opacities
            welcomeOpacity = 0.0
            ohOpacity = 0.0
            whoOpacity = 0.0
            slitOpacity = 0.0
            journeyOpacity = 0.0
            choicesOpacity = 0.0
            symbolOpacity = 0.0
            groupOpacity = 1.0
            
            // Individual fade in sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    ohOpacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    whoOpacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    slitOpacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    journeyOpacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.6) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    choicesOpacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.4) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    symbolOpacity = 1.0
                }
            }
            
            // Unified fade out after 4 seconds of last text
            DispatchQueue.main.asyncAfter(deadline: .now() + 14.0) {
                withAnimation(.easeInOut(duration: 3.0)) {
                    groupOpacity = 0.0
                }
            }
            
            // Transition to loading after complete fade
            DispatchQueue.main.asyncAfter(deadline: .now() + 17.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    currentPhase = .loading
                }
            }
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                TerminalLoadingText(text: "Initializing systems", isVisible: true)
                
                WaveformBar(progress: loadingProgress)
                    .opacity(loadingOpacity)
                    .animation(.easeInOut(duration: 1.0), value: loadingOpacity)
                
                Spacer()
            }
        }
        .opacity(loadingOpacity)
        .animation(.easeInOut(duration: 1.5), value: loadingOpacity)
        .onAppear {
            loadingOpacity = 0.0
            
            // Smooth fade in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    loadingOpacity = 1.0
                }
            }
            
            // Start loading progress after fade in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                startLoadingProgress()
            }
        }
    }
    
    private var cognitiveChecksView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                VStack(spacing: 50) {
                    // Title with enhanced animation
                    Text("COGNITIVE MATRICES")
                        .font(.custom("SF Pro Display", size: 42).weight(.bold))
                        .foregroundColor(Color.green)
                        .shadow(color: Color.green.opacity(0.8), radius: 12, x: 0, y: 0)
                        .shadow(color: Color.green.opacity(0.3), radius: 24, x: 0, y: 0)
                        .opacity(showLoadingText ? 1 : 0)
                        .offset(y: showLoadingText ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showLoadingText)
                    
                    // Enhanced loading messages with faster timing
                    VStack(spacing: 20) {
                        TerminalLoadingText(text: "Neural pathways", isVisible: loadingProgress > 0.1)
                        TerminalLoadingText(text: "Synaptic connections", isVisible: loadingProgress > 0.25)
                        TerminalLoadingText(text: "Memory consolidation", isVisible: loadingProgress > 0.4)
                        TerminalLoadingText(text: "Pattern recognition", isVisible: loadingProgress > 0.6)
                        TerminalLoadingText(text: "Cognitive mapping", isVisible: loadingProgress > 0.8)
                    }
                    .padding(.horizontal, 50)
                }
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            showLoadingText = false
            loadingProgress = 0.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showLoadingText = true
            }
            
            // Faster loading sequence
            Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
                if loadingProgress < 1.0 {
                    loadingProgress += 0.03
                } else {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            currentPhase = .geneticAnalysis
                        }
                    }
                }
            }
        }
    }
    
    private var geneticAnalysisView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                VStack(spacing: 50) {
                    // Title with enhanced animation
                    Text("GENETIC SEQUENCING")
                        .font(.custom("SF Pro Display", size: 42).weight(.bold))
                        .foregroundColor(Color.green)
                        .shadow(color: Color.green.opacity(0.8), radius: 12, x: 0, y: 0)
                        .shadow(color: Color.green.opacity(0.3), radius: 24, x: 0, y: 0)
                        .opacity(showLoadingText ? 1 : 0)
                        .offset(y: showLoadingText ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showLoadingText)
                    
                    // Enhanced loading messages with faster timing
                    VStack(spacing: 20) {
                        TerminalLoadingText(text: "DNA helix analysis", isVisible: loadingProgress > 0.1)
                        TerminalLoadingText(text: "Genetic markers", isVisible: loadingProgress > 0.25)
                        TerminalLoadingText(text: "Protein synthesis", isVisible: loadingProgress > 0.4)
                        TerminalLoadingText(text: "Cellular regeneration", isVisible: loadingProgress > 0.6)
                        TerminalLoadingText(text: "Genetic optimization", isVisible: loadingProgress > 0.8)
                    }
                    .padding(.horizontal, 50)
                }
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            showLoadingText = false
            loadingProgress = 0.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showLoadingText = true
            }
            
            // Faster loading sequence
            Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
                if loadingProgress < 1.0 {
                    loadingProgress += 0.03
                } else {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            currentPhase = .abilityGeneration
                        }
                    }
                }
            }
        }
    }
    
    private var abilityGenerationView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                VStack(spacing: 50) {
                    // Title with enhanced animation
                    Text("ABILITY MANIFESTATION")
                        .font(.custom("SF Pro Display", size: 42).weight(.bold))
                        .foregroundColor(Color.green)
                        .shadow(color: Color.green.opacity(0.8), radius: 12, x: 0, y: 0)
                        .shadow(color: Color.green.opacity(0.3), radius: 24, x: 0, y: 0)
                        .opacity(showLoadingText ? 1 : 0)
                        .offset(y: showLoadingText ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showLoadingText)
                    
                    // Enhanced loading messages with faster timing
                    VStack(spacing: 20) {
                        TerminalLoadingText(text: "Psychic resonance", isVisible: loadingProgress > 0.1)
                        TerminalLoadingText(text: "Quantum entanglement", isVisible: loadingProgress > 0.25)
                        TerminalLoadingText(text: "Reality distortion", isVisible: loadingProgress > 0.4)
                        TerminalLoadingText(text: "Temporal manipulation", isVisible: loadingProgress > 0.6)
                        TerminalLoadingText(text: "Ability crystallization", isVisible: loadingProgress > 0.8)
                    }
                    .padding(.horizontal, 50)
                }
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            showLoadingText = false
            loadingProgress = 0.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showLoadingText = true
            }
            
            // Faster loading sequence
            Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
                if loadingProgress < 1.0 {
                    loadingProgress += 0.03
                } else {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            currentPhase = .traitGeneration
                        }
                    }
                }
            }
        }
    }
    
    private var traitGenerationView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                VStack(spacing: 50) {
                    // Title with enhanced animation
                    Text("TRAIT SYNTHESIS")
                        .font(.custom("SF Pro Display", size: 42).weight(.bold))
                        .foregroundColor(Color.green)
                        .shadow(color: Color.green.opacity(0.8), radius: 12, x: 0, y: 0)
                        .shadow(color: Color.green.opacity(0.3), radius: 24, x: 0, y: 0)
                        .opacity(showLoadingText ? 1 : 0)
                        .offset(y: showLoadingText ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showLoadingText)
                    
                    // Enhanced loading messages with faster timing
                    VStack(spacing: 20) {
                        TerminalLoadingText(text: "Personality mapping", isVisible: loadingProgress > 0.1)
                        TerminalLoadingText(text: "Behavioral patterns", isVisible: loadingProgress > 0.25)
                        TerminalLoadingText(text: "Character formation", isVisible: loadingProgress > 0.4)
                        TerminalLoadingText(text: "Trait integration", isVisible: loadingProgress > 0.6)
                        TerminalLoadingText(text: "Identity crystallization", isVisible: loadingProgress > 0.8)
                    }
                    .padding(.horizontal, 50)
                }
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            // Reset states to prevent glitches
            showLoadingText = false
            loadingProgress = 0.0
            animateAbilityReveal = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showLoadingText = true
            }
            
            // Faster loading sequence
            Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
                if loadingProgress < 1.0 {
                    loadingProgress += 0.03
                } else {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            currentPhase = .abilityResult
                        }
                    }
                }
            }
        }
    }
    
    private var abilityResultView: some View {
        ZStack {
            // Terminal scanline background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                if let ability = generatedAbility {
                    VStack(spacing: 50) {
                        // Animated sequential reveal
                        VStack(spacing: 24) {
                            Image(systemName: ability.type.icon)
                                .font(.system(size: 72, weight: .medium))
                                .foregroundColor(Color(ability.type.tier.color))
                                .shadow(color: Color(ability.type.tier.color).opacity(0.8), radius: 12, x: 0, y: 0)
                                .shadow(color: Color(ability.type.tier.color).opacity(0.4), radius: 24, x: 0, y: 0)
                                .opacity(animateAbilityReveal ? 1 : 0)
                                .offset(y: animateAbilityReveal ? 0 : 40)
                                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1), value: animateAbilityReveal)
                            Text(ability.type.rawValue)
                                .font(.custom("SF Pro Display", size: 32).weight(.bold))
                                .foregroundColor(Color(ability.type.tier.color))
                                .shadow(color: Color(ability.type.tier.color).opacity(0.6), radius: 6, x: 0, y: 0)
                                .opacity(animateAbilityReveal ? 1 : 0)
                                .offset(y: animateAbilityReveal ? 0 : 40)
                                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2), value: animateAbilityReveal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                        // Ability Manifested
                        Text("Ability Manifested")
                            .font(.custom("SF Pro Display", size: 48).weight(.bold))
                            .foregroundColor(Color.green)
                            .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
                            .shadow(color: Color.green.opacity(0.3), radius: 16, x: 0, y: 0)
                            .padding(.bottom, 30)
                            .opacity(animateAbilityReveal ? 1 : 0)
                            .offset(y: animateAbilityReveal ? 0 : 40)
                            .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.3), value: animateAbilityReveal)
                        // Description
                        Text(ability.type.description)
                            .font(.custom("SF Pro Text", size: 20).weight(.medium))
                            .foregroundColor(Color.green.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 50)
                            .padding(.bottom, 40)
                            .opacity(animateAbilityReveal ? 1 : 0)
                            .offset(y: animateAbilityReveal ? 0 : 40)
                            .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.4), value: animateAbilityReveal)
                        // Confirm button
                        Button(action: {
                            HapticManager.shared.impact(.medium)
                            withAnimation(.easeInOut(duration: 1.2)) {
                                currentPhase = .complete
                            }
                        }) {
                            Text("Confirm")
                                .font(.custom("SF Pro Display", size: 20).weight(.bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 50)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                        .shadow(color: Color.green.opacity(0.6), radius: 8, x: 0, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.8), lineWidth: 2)
                                )
                        }
                        .opacity(animateAbilityReveal ? 1 : 0)
                        .offset(y: animateAbilityReveal ? 0 : 40)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.5), value: animateAbilityReveal)
                    }
                }
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            // Generate ability if not already generated
            if generatedAbility == nil {
                generatedAbility = abilityManager.assignRandomAbility()
            }
            
            // Animate sequential reveal
            animateAbilityReveal = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateAbilityReveal = true
            }
        }
    }
    
    private var completeView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("CONSCIOUSNESS AWAKENED")
                    .font(.custom("SF Pro Display", size: 42).weight(.bold))
                    .foregroundColor(Color.green)
                    .shadow(color: Color.green.opacity(0.8), radius: 12, x: 0, y: 0)
                    .shadow(color: Color.green.opacity(0.3), radius: 24, x: 0, y: 0)
                
                Text("Your identity awaits")
                    .font(.custom("SF Pro Text", size: 20).weight(.medium))
                    .foregroundColor(Color.green.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            // Transition directly to character creation with proper timing
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Increased delay for better timing
                print("🔍 DEBUG: Attempting to transition to CharacterCreation")
                print("🔍 DEBUG: Current gameState.showingNewGameInit = \(gameState.showingNewGameInit)")
                print("🔍 DEBUG: Current gameState.showingCharacterCreation = \(gameState.showingCharacterCreation)")
                print("🔍 DEBUG: Current gameState object: \(gameState)")
                
                // Force the state change on the main thread
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        gameState.showingCharacterCreation = true
                        gameState.showingNewGameInit = false
                    }
                    
                    print("🔍 DEBUG: After transition - gameState.showingCharacterCreation = \(gameState.showingCharacterCreation)")
                    print("🔍 DEBUG: After transition - gameState.showingNewGameInit = \(gameState.showingNewGameInit)")
                    
                    // Additional verification
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("🔍 DEBUG: Verification - gameState.showingCharacterCreation = \(gameState.showingCharacterCreation)")
                        print("🔍 DEBUG: Verification - gameState.showingNewGameInit = \(gameState.showingNewGameInit)")
                    }
                }
            }
        }
    }
    
    private func startLoadingSequence() {
        loadingProgress = 0.0
        loadingText = ""
        showLoadingText = false
        
        let loadingMessages = [
            "Matrices synced...",
            "Neural pathways established...",
            "Consciousness interface active...",
            "Reality anchors calibrated...",
            "Psychic barriers lowered...",
            "System ready for story...",
            "DNA sequences analyzed...",
            "Genetic markers mapped...",
            "Cellular regeneration protocols...",
            "Bio-neural integration complete...",
            "Cognitive patterns scanned...",
            "Memory matrices initialized...",
            "Synaptic connections optimized...",
            "Neural plasticity enhanced...",
            "Quantum consciousness bridge...",
            "Dimensional awareness expanded...",
            "Temporal perception calibrated...",
            "Reality distortion fields...",
            "Multiverse probability matrices...",
            "Existence anchors stabilized..."
        ]
        
        var messageIndex = 0
        
        func showNextMessage() {
            if messageIndex < loadingMessages.count {
                loadingText = loadingMessages[messageIndex]
                showLoadingText = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showLoadingText = false
                }
                messageIndex += 1
            }
        }
        
        showNextMessage()
        
        // Story progresses naturally
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            loadingProgress += 0.006
            
                            if Int(loadingProgress * 100) % 12 == 0 && messageIndex < loadingMessages.count {
                    showNextMessage()
                }
            
            if loadingProgress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        currentPhase = .cognitiveChecks
                    }
                }
            }
        }
    }
    
    private func startLoadingProgress() {
        loadingProgress = 0.0
        
        // Enhanced loading sequence
        Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
            if loadingProgress < 1.0 {
                loadingProgress += 0.025
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        currentPhase = .cognitiveChecks
                    }
                }
            }
        }
    }
    
    private func generateAbility() {
        generatedAbility = abilityManager.assignRandomAbility()
    }
    
    private func generateTraits() {
        // Simple trait generation
        let allTraits = [
            Trait(name: "Adaptable", description: "You adapt quickly to new situations", statModifiers: ["adaptability": 15]),
            Trait(name: "Brave", description: "You face danger with courage", statModifiers: ["courage": 15]),
            Trait(name: "Charismatic", description: "You have a natural way with people", statModifiers: ["charisma": 15]),
            Trait(name: "Intelligent", description: "You have sharp analytical skills", statModifiers: ["intelligence": 15]),
            Trait(name: "Strong", description: "You have impressive physical strength", statModifiers: ["strength": 15])
        ]
        
        generatedTraits = Array(allTraits.shuffled().prefix(3))
    }
}

// MARK: - Loading Text Component - Part of the story
struct LoadingText: View {
    let text: String
    let delay: Double
    
    @State private var showText = false
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .light, design: .serif))
            .foregroundColor(.white.opacity(0.8))
            .opacity(showText ? 1.0 : 0.0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showText = true
                    }
                }
            }
    }
}

// MARK: - Enhanced Terminal Loading Text with Oomph
struct TerminalLoadingText: View {
    let text: String
    let isVisible: Bool
    @State private var opacity: Double = 0.0
    @State private var offset: Double = 20.0
    @State private var scale: Double = 0.9
    @State private var dotOpacity: Double = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.custom("SF Pro Text", size: 18).weight(.medium))
                .foregroundColor(Color.green.opacity(0.8))
                .shadow(color: Color.green.opacity(0.3), radius: 3, x: 0, y: 0)
            
            // Moving dots
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    Text(".")
                        .font(.custom("SF Pro Text", size: 18).weight(.medium))
                        .foregroundColor(Color.green.opacity(0.8))
                        .opacity(dotOpacity)
                        .scaleEffect(dotOpacity > 0 ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .delay(Double(index) * 0.2)
                                .repeatForever(autoreverses: true),
                            value: dotOpacity
                        )
                }
            }
        }
        .opacity(opacity)
        .offset(y: offset)
        .scaleEffect(scale)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isVisible)
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.05)) {
                    opacity = 1.0
                    offset = 0.0
                    scale = 1.0
                }
                // Start dots animation after text appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dotOpacity = 1.0
                    }
                }
            } else {
                opacity = 0.0
                offset = 20.0
                scale = 0.9
                dotOpacity = 0.0
            }
        }
    }
} 