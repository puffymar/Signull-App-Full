import Foundation
import CoreHaptics
import UIKit
import AVFoundation

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    private var hapticEngine: CHHapticEngine?
    private var audioPlayer: AVAudioPlayer?
    private var idlePulseTimer: Timer?
    
    // 🧠 PSYCHO-SPIRITUAL HAPTIC STATES
    @Published var isHapticEnabled: Bool = true
    @Published var currentHapticMode: HapticMode = .idle
    @Published var hapticIntensity: Double = 0.5
    
    enum HapticMode {
        case idle
        case intro
        case menu
        case storySelection
        case paragraphTransition
        case buttonPress
        case ambient
        case musicSync
    }
    
    private init() {
        setupHapticEngine()
    }
    
    // 🔮 SETUP HAPTIC ENGINE
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Haptic engine not supported on this device")
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            hapticEngine?.resetHandler = { [weak self] in
                print("🔄 Haptic engine reset")
                self?.setupHapticEngine()
            }
            
            hapticEngine?.stoppedHandler = { reason in
                print("⏹️ Haptic engine stopped: \(reason)")
            }
            
        } catch {
            print("❌ Failed to start haptic engine: \(error)")
        }
    }
    
    // 🎯 MAIN MENU BUTTON HAPTICS (Breaking a seal)
    func menuButtonPress() async {
        guard isHapticEnabled else { return }
        
        // Primary impact
        let generator = await UIImpactFeedbackGenerator(style: .medium)
        await generator.prepare()
        await generator.impactOccurred()
        
        // Secondary notification for depth
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            Task {
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
            }
        }
        
        DispatchQueue.main.async {
            self.currentHapticMode = .menu
        }
    }
    
    // 🌌 INTRO SEQUENCE HAPTIC FLOW (Signal entering the body)
    func playIntroHaptic() {
        guard isHapticEnabled, let engine = hapticEngine else { return }
        
        DispatchQueue.main.async {
            self.currentHapticMode = .intro
        }
        
        let events = [
            // Soft encroaching pressure
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.0,
                duration: 2.5
            ),
            // Signal presence
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 2.7
            ),
            // Fading resonance
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ],
                relativeTime: 3.0,
                duration: 1.5
            )
        ]
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("❌ Intro haptic failed: \(error)")
        }
    }
    
    // 🧠 AI STORY INTRO HAPTICS (Tuning a psychic dial)
    func storySelectionHaptic() {
        guard isHapticEnabled, let engine = hapticEngine else { return }
        
        DispatchQueue.main.async {
            self.currentHapticMode = .storySelection
        }
        
        let events = [
            // Initial frequency shift
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0.0
            ),
            // Swelling gradient
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.2,
                duration: 1.8
            ),
            // Radio static decay
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.1),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.05)
                ],
                relativeTime: 2.0,
                duration: 0.8
            )
        ]
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("❌ Story selection haptic failed: \(error)")
        }
    }
    
    // ✴️ PARAGRAPH VIEW SUBTLE FEEDBACK (Screen breathing)
    func paragraphTransitionHaptic() {
        guard isHapticEnabled, let engine = hapticEngine else { return }
        
        DispatchQueue.main.async {
            self.currentHapticMode = .paragraphTransition
        }
        
        let events = [
            // Text appearance breath
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ],
                relativeTime: 0.0
            )
        ]
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("❌ Paragraph haptic failed: \(error)")
        }
    }
    
    // 🎮 BUTTON PRESS HAPTICS (Enhanced)
    func buttonPressHaptic(style: ButtonHapticStyle = .standard) {
        guard isHapticEnabled else { return }
        
        DispatchQueue.main.async {
            self.currentHapticMode = .buttonPress
        }
        
        switch style {
        case .standard:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
            
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            
        case .success:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            
        case .warning:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.warning)
            
        case .error:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
        }
    }
    
    enum ButtonHapticStyle {
        case standard
        case heavy
        case light
        case success
        case warning
        case error
    }
    
    // 🔁 FLOWING HAPTIC PULSE DURING IDLE (App awareness)
    func startIdlePulse() {
        guard isHapticEnabled else { return }
        
        stopIdlePulse()
        
        idlePulseTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            self?.playIdlePulse()
        }
    }
    
    func stopIdlePulse() {
        idlePulseTimer?.invalidate()
        idlePulseTimer = nil
    }
    
    private func playIdlePulse() {
        guard isHapticEnabled, let engine = hapticEngine else { return }
        
        DispatchQueue.main.async {
            self.currentHapticMode = .ambient
        }
        
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.1),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.05)
                ],
                relativeTime: 0.0,
                duration: 1.2
            )
        ]
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("❌ Idle pulse haptic failed: \(error)")
        }
    }
    
    // 🎧 AUDIO-HAPTIC SYNC (Advanced)
    func syncHapticWithAudio(_ audioPlayer: AVAudioPlayer, at time: TimeInterval) {
        guard isHapticEnabled else { return }
        
        DispatchQueue.main.async {
            self.currentHapticMode = .musicSync
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            Task {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            }
        }
    }
    
    // 🧬 ENVIRONMENTAL HAPTIC TRIGGERS
    func triggerEnvironmentalHaptic(for effect: String, intensity: Double = 0.5) {
        guard isHapticEnabled else { return }
        
        switch effect {
        case "pulse":
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case "glow":
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case "sigil_rotate":
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        case "ambient":
            playIdlePulse()
            
        default:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    // 🔧 UTILITY FUNCTIONS
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticEnabled else { return }
        
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(type)
    }
    
    func selection() {
        guard isHapticEnabled else { return }
        
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
    }
    
    // 🎛️ SETTINGS
    func setHapticIntensity(_ intensity: Double) {
        hapticIntensity = max(0.0, min(1.0, intensity))
    }
    
    func toggleHaptics() {
        isHapticEnabled.toggle()
        if !isHapticEnabled {
            stopIdlePulse()
        }
    }
} 