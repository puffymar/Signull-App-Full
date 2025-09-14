import SwiftUI
import AVFoundation

// MARK: - Intent System
enum Intent: String, CaseIterable {
    case say, act, think, intervene
}

struct StoryView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var audioManager = AudioManager.shared
    
    let initialStory: String
    
    // MARK: - Initializer
    init(initialStory: String) {
        self.initialStory = initialStory
    }
    
    // 🧠 AGI STORY STATES
    @State private var currentStory: String = ""
    @State private var isLoading: Bool = false
    @State private var isTyping: Bool = false
    @State private var userInput: String = ""
    @State private var storyHistory: [String] = []
    private let userDisplayName: String = "[Samson]"
    private let aiDisplayName: String = "[DreamTech]"
    
    // 🔮 PSYCHO-SPIRITUAL VISUAL EFFECTS
    @State private var textFlickerPhase: Bool = false
    @State private var crtBloom: Double = 0.0
    @State private var chromaticAberration: Double = 0.0
    @State private var scanlineOffset: CGFloat = 0
    @State private var mysticalAura: Double = 0.0
    @State private var ambientPulse: Double = 0.0
    
    // 🎮 INTERACTION BUTTONS
    @State private var activeButton: String? = nil
    @State private var buttonPressStates: [String: Bool] = [:]
    @State private var selectedButton: String? = nil
    @State private var selectedIntent: Intent? = nil
    
    // 🧬 AGI LIGHTING EFFECTS (Recursive)
    @State private var environmentalPulse: String = "neutral"
    @State private var lightShift: String = "stable"
    @State private var backgroundIntensity: Double = 0.0
    
    var body: some View {
        ZStack {
            // MARK: - CRT SHADER BACKGROUND + NOISE
            Color.black
                .ignoresSafeArea()
            
            // MARK: - CRT BLOOM + CHROMATIC ABERRATION
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.cyan.opacity(crtBloom * 0.3),
                    Color.blue.opacity(crtBloom * 0.2),
                    Color.purple.opacity(crtBloom * 0.1),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .blur(radius: 120 + (chromaticAberration * 20))
            .opacity(crtBloom)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: crtBloom)
            
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
            
            // MARK: - MAIN CONTENT
            VStack(spacing: 0) {
                // MARK: - BACK BUTTON
                HStack {
                    Button(action: {
                        Task {
                            await hapticManager.buttonPressHaptic(style: .light)
                        }
                        withAnimation(.easeInOut(duration: 0.5)) {
                            gameState.showingStoryView = false
                            gameState.showingAIStories = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("Back")
                                .font(.custom("SF Mono", size: 12).weight(.medium))
                        }
                        .foregroundColor(Color.cyan.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // MARK: - STORY CONTENT (Edge-to-edge, no borders)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if !currentStory.isEmpty {
                            Text(currentStory)
                                .font(.custom("SF Mono", size: 16))
                                .foregroundColor(.white)
                                .lineSpacing(8)
                                .padding(.horizontal, 20)
                                .opacity(textFlickerPhase ? 0.9 : 1.0)
                                .animation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true), value: textFlickerPhase)
                                .onAppear {
                                    hapticManager.paragraphTransitionHaptic()
                                }
                        }
                        
                        if isLoading {
                            HStack(spacing: 10) {
                                GlitchText(text: "\(aiDisplayName) Thinking…")
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                Spacer()
                
                // MARK: - INPUT BAR (Translucent with whisper glow)
                VStack(spacing: 15) {
                    // MARK: - THINK/ACT/SAY/INTERVENE BUTTONS
                    HStack(spacing: 12) {
                        intentChip(title: "Think", icon: "brain.head.profile", intent: .think)
                        intentChip(title: "Act", icon: "bolt.fill", intent: .act)
                        intentChip(title: "Say", icon: "quote.bubble.fill", intent: .say)
                        intentChip(title: "Intervene", icon: "exclamationmark.triangle.fill", intent: .intervene)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - TEXT INPUT BAR
                    HStack {
                        TextField("Enter your response...", text: $userInput)
                            .font(.custom("SF Mono", size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.cyan.opacity(0.3),
                                                        Color.blue.opacity(0.2),
                                                        Color.cyan.opacity(0.1)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: .cyan.opacity(0.2), radius: 4)
                            )
                            .submitLabel(.send)
                            .onSubmit {
                                submitUserInputWithIntent()
                            }
                        
                        Button(action: {
                            Task {
                                await hapticManager.buttonPressHaptic(style: .success)
                            }
                            submitUserInputWithIntent()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(!userInput.isEmpty ? .cyan : .gray)
                                .shadow(color: (!userInput.isEmpty) ? .cyan.opacity(0.5) : .clear, radius: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(userInput.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    

                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            startPsychoSpiritualEffects()
            loadInitialStory()
        }
        .onReceive(gameState.$selectedStory) { story in
            guard let story else { return }
            let newText = story.fullStory.trimmingCharacters(in: .whitespacesAndNewlines)
            if !newText.isEmpty && newText != currentStory {
                currentStory = newText
                storyHistory.append(newText)
            }
        }
    }
    
    // Strip JSON wrapper if somehow bubbled up; keep only paragraph content
    private func extractStoryText(from text: String) -> String {
        if text.hasPrefix("{") {
            if let data = text.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let fs = dict["fullStory"] as? String { return fs }
                if let paras = dict["paragraphs"] as? [String] { return paras.joined(separator: "\n\n") }
                if let scene = dict["scene"] as? String { return scene }
            }
        }
        return text
    }

    // 🔮 AGI BUTTON COMPONENT
    private func agiButton(
        title: String,
        icon: String,
        intent: Intent
    ) -> some View {
        let isSelected = selectedIntent == intent
        let isPressed = buttonPressStates[intent.rawValue] ?? false
        
        return Button(action: {
            Task {
                await hapticManager.buttonPressHaptic(style: .heavy)
            }
            
            // Toggle selection state
            withAnimation(.easeInOut(duration: 0.2)) {
                if selectedIntent == intent {
                    // If clicking the same button, deselect it
                    selectedIntent = nil
                } else {
                    // Select this button, deselect others
                    selectedIntent = intent
                }
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .cyan)
                    .shadow(color: .cyan.opacity(isSelected ? 0.8 : (isPressed ? 0.6 : 0.4)), radius: 4)
                
                Text(title)
                    .font(.custom("SF Mono", size: 10).weight(.medium))
                    .foregroundColor(isSelected ? .cyan : .white)
                    .tracking(1)
            }
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.cyan : Color.cyan.opacity(isPressed ? 0.8 : 0.4),
                                lineWidth: isSelected ? 2 : (isPressed ? 2 : 1)
                            )
                    )
                    .shadow(
                        color: .cyan.opacity(isSelected ? 0.8 : (isPressed ? 0.6 : 0.3)),
                        radius: isSelected ? 8 : (isPressed ? 6 : 4)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : (isPressed ? 0.95 : 1.0))
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    buttonPressStates[intent.rawValue] = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        buttonPressStates[intent.rawValue] = false
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // New chip that never steals focus from the TextField
    private func intentChip(title: String, icon: String, intent: Intent) -> some View {
        let isSelected = selectedIntent == intent
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedIntent = (selectedIntent == intent) ? nil : intent
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.custom("SF Mono", size: 11).weight(.medium))
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(
                Capsule()
                    .fill((isSelected ? Color.cyan.opacity(0.2) : Color.black.opacity(0.5)))
                    .overlay(Capsule().stroke(Color.cyan.opacity(isSelected ? 0.9 : 0.4), lineWidth: isSelected ? 1.5 : 1))
            )
            .foregroundColor(isSelected ? .white : .cyan)
        }
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(true)
    }
    
    // 🧠 AGI ACTION HANDLER
    private func handleAgiAction(_ action: String) {
        // Require text input first
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Don't autogenerate; ask the user to type first
            Task {
                await hapticManager.buttonPressHaptic(style: .warning)
            }
            // Show a temporary error message
            print("⚠️ Type something first, then choose an intent.")
            return
        }
        
        // Trigger visual effects first
        switch action {
        case "think":
            triggerEnvironmentalEffect("pulse", intensity: 0.6)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "pulse", intensity: 0.6)
            }
            generateAIResponse(for: "think", userInput: userInput)
            
        case "act":
            triggerEnvironmentalEffect("glow", intensity: 0.8)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "glow", intensity: 0.8)
            }
            generateAIResponse(for: "act", userInput: userInput)
            
        case "say":
            triggerEnvironmentalEffect("sigil_rotate", intensity: 0.7)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "sigil_rotate", intensity: 0.7)
            }
            generateAIResponse(for: "say", userInput: userInput)
            
        case "intervene":
            triggerEnvironmentalEffect("ambient", intensity: 1.0)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "ambient", intensity: 1.0)
            }
            generateAIResponse(for: "intervene", userInput: userInput)
            
        default:
            break
        }
    }
    
    // 🚀 SUBMIT WITH INTENT
    private func submitUserInputWithIntent() {
        guard !userInput.isEmpty else { return }
        let intent = selectedIntent ?? .say
        
        // Trigger visual effects based on intent
        switch intent {
        case .think:
            triggerEnvironmentalEffect("pulse", intensity: 0.6)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "pulse", intensity: 0.6)
            }
        case .act:
            triggerEnvironmentalEffect("glow", intensity: 0.8)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "glow", intensity: 0.8)
            }
        case .say:
            triggerEnvironmentalEffect("sigil_rotate", intensity: 0.7)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "sigil_rotate", intensity: 0.7)
            }
        case .intervene:
            triggerEnvironmentalEffect("ambient", intensity: 1.0)
            Task {
                await hapticManager.triggerEnvironmentalHaptic(for: "ambient", intensity: 1.0)
            }
        }
        
        // Generate AI response with intent
        let echoedText = userInput
        // Show the user's line immediately in the transcript
        currentStory += "\n\n\(userDisplayName) \"\(echoedText)\""
        generateAIResponse(for: intent.rawValue, userInput: echoedText)
        
        // Clear input and intent after sending
        userInput = ""
        selectedIntent = nil
    }
    
    // 🤖 AI RESPONSE GENERATOR
    private func generateAIResponse(for action: String, userInput: String) {
        // User input is already validated in handleAgiAction, so we can proceed directly
        
        let userMessage = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add user input to history
        storyHistory.append("User (\(action)): \(userMessage)")
        
        // Clear input
        self.userInput = ""
        
        // Show loading state
        isLoading = true
        
        // Generate AI response based on action type
        Task {
            do {
                let composer = PromptComposer()
                let systemPrompt = composer.systemPrompt()
                
                let actionPrompts = [
                    "think": "The character is thinking deeply about: \(userMessage). Continue the story with introspective narrative.",
                    "act": "The character is taking action based on: \(userMessage). Continue the story with dynamic action.",
                    "say": "The character is speaking about: \(userMessage). Continue the story with dialogue and conversation.",
                    "intervene": "The character is intervening in the situation: \(userMessage). Continue the story with dramatic intervention."
                ]
                
                // Rolling context tail to keep tokens sane but preserve continuity
                let contextTail = String(currentStory.suffix(2400))

                // Streamlined payload so we can steer output without code changes
                let payload: [String: Any] = [
                    "action": action,
                    "input": userMessage,
                    "preferences": [
                        "length": "2-4 paragraphs",
                        "endingMode": "decisive",
                        "voice": "cinematic-concrete",
                        "avoid": ["meta", "boilerplate", "generic mystery openers"]
                    ]
                ]
                let payloadJSON = (try? JSONSerialization.data(withJSONObject: payload)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
                // Stronger continuation instructions to avoid generic boilerplate
                let continuityHint = "Maintain continuity with the context and incorporate the player input explicitly. Conclude with a decisive closing image (e.g., 'You wake up in the bed.')."
                let userPrompt = "<TEXT_ONLY> Use the following action+input to continue the story for [Samson].\nPayload: \n\(payloadJSON)\n\nHistory tail (most recent content):\n\(contextTail)\n\n\(continuityHint)"
                
                let storyData = try await SignullAPI.generateContinuationStory(
                    prompt: userPrompt,
                    onPhase: { phase in
                        DispatchQueue.main.async {
                            print("🔍 AI Phase (\(action)): \(phase)")
                        }
                    },
                    onIntensity: { intensity in
                        DispatchQueue.main.async {
                            print("🔍 AI Intensity (\(action)): \(intensity)")
                        }
                    }
                )
                
                DispatchQueue.main.async {
                    let aiResponse = storyData.fullStory.trimmingCharacters(in: .whitespacesAndNewlines)
                    let extracted = extractStoryText(from: aiResponse)
                    let safeText = extracted.isEmpty ? "(no content)" : extracted
                    currentStory += "\n\n\(aiDisplayName)\n\(safeText)"
                    storyHistory.append("AI (\(action)): \(aiResponse)")
                    isLoading = false
                    hapticManager.paragraphTransitionHaptic()
                }
                
                               } catch let liveError as LiveAPI.LiveError {
                       DispatchQueue.main.async {
                           let errorResponse: String
                           switch liveError {
                           case .badStatus(let code, let body):
                               errorResponse = "HTTP \(code): \(body)"
                           case .badServerResponse:
                               errorResponse = "Server response error"
                           case .schemaNotLoaded:
                               errorResponse = "Schema not loaded"
                           case .invalidResponse:
                               errorResponse = "Invalid response format"
                           }
                           currentStory += "\n\n\(errorResponse)"
                           storyHistory.append("Error (\(action)): \(errorResponse)")
                           isLoading = false
                           hapticManager.paragraphTransitionHaptic()
                           print("🔴 StoryView API Error (\(action)): \(errorResponse)")
                       }
                   } catch {
                       DispatchQueue.main.async {
                           let errorResponse = "The AI encountered an error while processing your \(action) action. Please try again."
                           currentStory += "\n\n\(errorResponse)"
                           storyHistory.append("Error (\(action)): \(errorResponse)")
                           isLoading = false
                           hapticManager.paragraphTransitionHaptic()
                           print("🔴 StoryView API Error (\(action)): \(error)")
                       }
                   }
        }
    }

    // MARK: - Glitching text effect
    private struct GlitchText: View {
        let text: String
        @State private var phase: Double = 0
        var body: some View {
            ZStack {
                Text(text)
                    .font(.custom("SF Mono", size: 14))
                    .foregroundColor(.cyan.opacity(0.85))
                    .opacity(0.7)
                    .offset(x: sin(phase * 12) * 0.8, y: 0)
                Text(text)
                    .font(.custom("SF Mono", size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .blur(radius: 0.6)
                Text(text)
                    .font(.custom("SF Mono", size: 14))
                    .foregroundColor(.purple.opacity(0.6))
                    .offset(x: cos(phase * 10) * -0.6, y: 0)
            }
            .onAppear {
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) { phase = 1 }
            }
        }
    }
    

    
    // 🧬 ENVIRONMENTAL EFFECT TRIGGER
    private func triggerEnvironmentalEffect(_ effect: String, intensity: Double) {
        withAnimation(.easeInOut(duration: 1.0)) {
            switch effect {
            case "pulse":
                environmentalPulse = "blue"
                backgroundIntensity = intensity
                
            case "glow":
                lightShift = "vibration"
                backgroundIntensity = intensity
                
            case "sigil_rotate":
                environmentalPulse = "cyan"
                backgroundIntensity = intensity
                
            case "ambient":
                lightShift = "pulse"
                backgroundIntensity = intensity
                
            default:
                environmentalPulse = "neutral"
                lightShift = "stable"
                backgroundIntensity = 0.0
            }
        }
        
        // Reset after effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                environmentalPulse = "neutral"
                lightShift = "stable"
                backgroundIntensity = 0.0
            }
        }
    }
    
    // 📖 STORY LOADING
    private func loadInitialStory() {
        currentStory = initialStory
        storyHistory.append(initialStory)
        
        // Start text flicker effect
        withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
            textFlickerPhase = true
        }
    }
    
    // 📝 USER INPUT SUBMISSION
    private func submitUserInput() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add user input to history
        storyHistory.append("User: \(userMessage)")
        
        // Clear input
        userInput = ""
        
        // Show loading state
        isLoading = true
        
        // Call the actual AI API
        Task {
            do {
                let userPrompt = "Continue the story based on this user input: \(userMessage)\n\nCurrent story context: \(currentStory)"
                
                let storyData = try await SignullAPI.generateStory(
                    prompt: userPrompt,
                    onPhase: { phase in
                        DispatchQueue.main.async {
                            print("🔍 AI Phase: \(phase)")
                        }
                    },
                    onIntensity: { intensity in
                        DispatchQueue.main.async {
                            print("🔍 AI Intensity: \(intensity)")
                            // Map intensity 0..1 to a subtle aura strength
                            backgroundIntensity = max(0.0, min(1.0, intensity))
                        }
                    }
                )
                
                DispatchQueue.main.async {
                    let aiResponse = storyData.fullStory
                    currentStory += "\n\n\(aiResponse)"
                    storyHistory.append(aiResponse)
                    isLoading = false
                    hapticManager.paragraphTransitionHaptic()
                }
                
            } catch {
                DispatchQueue.main.async {
                    let errorResponse = "The AI encountered an error while processing your input. Please try again."
                    currentStory += "\n\n\(errorResponse)"
                    storyHistory.append(errorResponse)
                    isLoading = false
                    hapticManager.paragraphTransitionHaptic()
                    print("🔴 StoryView API Error: \(error)")
                }
            }
        }
    }
    
    // 🔮 PSYCHO-SPIRITUAL EFFECTS
    private func startPsychoSpiritualEffects() {
        // CRT Bloom and Chromatic Aberration
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            crtBloom = 1.0
            chromaticAberration = 1.0
        }
        
        // Ambient Pulse
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            ambientPulse = 1.0
        }
        
        // Scanline movement
        withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
            scanlineOffset = 2.0
        }
        
        // Mystical Aura
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            mysticalAura = 1.0
        }
    }
} 

