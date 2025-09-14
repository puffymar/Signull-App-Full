import Foundation
import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var currentTrack: String?
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.6
    
    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    // 🔮 ENHANCED AUDIO PLAYBACK WITH FALLBACK LOGIC
    func play(_ fileName: String, volume: Float = 0.6, loops: Bool = true, fadeIn: Bool = false) {
        #if targetEnvironment(simulator)
        // Simulators often can't find bundled audio; fail quietly
        return
        #else
        // Try multiple file extensions with fallback logic
        let extensions = ["mp3", "wav", "m4a"]
        var audioURL: URL?
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: fileName, withExtension: ext) {
                audioURL = url
                print("🎵 Found audio file: \(fileName).\(ext)")
                break
            }
        }
        
        guard let url = audioURL else {
            // Fail silently instead of logging errors
            return
        }
        
        do {
            // Stop current playback
            stop()
            
            // Create new player
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = fadeIn ? 0.0 : volume
            player?.numberOfLoops = loops ? -1 : 0
            player?.play()
            
            // Update state
            currentTrack = fileName
            isPlaying = true
            self.volume = volume
            
            // Fade in if requested
            if fadeIn {
                fadeInAudio(duration: 2.0, targetVolume: volume)
            }
            
            print("🎵 Now playing: \(fileName)")
        } catch {
            // Fail silently instead of logging errors
        }
        #endif
    }
    
    func stop() {
        player?.stop()
        player = nil
        currentTrack = nil
        isPlaying = false
        
        // Cancel any active fade timer
        fadeTimer?.invalidate()
        fadeTimer = nil
        
        print("🔇 Audio stopped")
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        print("⏸️ Audio paused")
    }
    
    func resume() {
        player?.play()
        isPlaying = true
        print("▶️ Audio resumed")
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
        player?.volume = volume
        print("🔊 Volume set to: \(volume)")
    }
    
    func fadeInAudio(duration: TimeInterval, targetVolume: Float) {
        guard let player = player else { return }
        
        let steps = 20
        let stepDuration = duration / TimeInterval(steps)
        let volumeStep = targetVolume / Float(steps)
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            let currentVolume = player.volume
            let newVolume = min(currentVolume + volumeStep, targetVolume)
            
            player.volume = newVolume
            
            if newVolume >= targetVolume {
                timer.invalidate()
                self.volume = targetVolume
                print("🎵 Fade in complete")
            }
        }
    }
    
    func fadeOutAudio(duration: TimeInterval, completion: @escaping () -> Void) {
        guard let player = player else {
            completion()
            return
        }
        
        let steps = 20
        let stepDuration = duration / TimeInterval(steps)
        let volumeStep = player.volume / Float(steps)
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            let currentVolume = player.volume
            let newVolume = max(currentVolume - volumeStep, 0.0)
            
            player.volume = newVolume
            
            if newVolume <= 0.0 {
                timer.invalidate()
                self.stop()
                completion()
                print("🎵 Fade out complete")
            }
        }
    }
    
    // 🔮 PSYCHO-SPIRITUAL AUDIO TRACKS
    func playIntroMusic() {
        // Try "Celestial" first, fallback to "Liminal"
        if Bundle.main.url(forResource: "Celestial", withExtension: "mp3") != nil ||
           Bundle.main.url(forResource: "Celestial", withExtension: "wav") != nil {
            play("Celestial", volume: 0.4, loops: true, fadeIn: true)
        } else {
            play("Liminal", volume: 0.4, loops: true, fadeIn: true)
        }
    }
    
    func playMenuMusic() {
        // Continue the intro music seamlessly
        if currentTrack == "Celestial" || currentTrack == "Liminal" {
            // Don't change track, just ensure it's playing
            if !isPlaying {
                resume()
            }
        } else {
            play("Liminal", volume: 0.5, loops: true, fadeIn: true)
        }
    }
    
    func playAmbientMusic() {
        play("Wind", volume: 0.3, loops: true, fadeIn: true)
    }
    
    func transitionToMenuMusic() {
        fadeOutAudio(duration: 2.0) {
            self.playMenuMusic()
        }
    }
    
    // MARK: - Utility Methods
    
    func getCurrentTrackDisplayName() -> String {
        guard let currentTrack = currentTrack else { return "None" }
        
        switch currentTrack {
        case "Celestial":
            return "Celestial (Intro/Menu)"
        case "Liminal":
            return "Liminal (Intro/Menu)"
        case "Wind":
            return "Wind (Ambient)"
        case "Night":
            return "Night (Ambient)"
        default:
            return currentTrack
        }
    }
    
    func getAvailableTracks() -> [String] {
        var tracks = ["Liminal", "Wind", "Night"]
        
        // Add Celestial if available
        if Bundle.main.url(forResource: "Celestial", withExtension: "mp3") != nil ||
           Bundle.main.url(forResource: "Celestial", withExtension: "wav") != nil {
            tracks.insert("Celestial", at: 0)
        }
        
        return tracks
    }
    
    // MARK: - Ending Music
    
    func playEndingMusic(for endingType: String) {
        switch endingType {
        case "pure_hero":
            play("Liminal", volume: 0.6, loops: true, fadeIn: true)
        case "corrupted_tyrant":
            play("Liminal", volume: 0.4, loops: true, fadeIn: true)
        case "balanced_master":
            play("Liminal", volume: 0.5, loops: true, fadeIn: true)
        case "mysterious_disappearance":
            play("Wind", volume: 0.3, loops: true, fadeIn: true)
        case "tragic_sacrifice":
            play("Liminal", volume: 0.4, loops: true, fadeIn: true)
        case "ancient_one_chosen":
            play("Liminal", volume: 0.6, loops: true, fadeIn: true)
        case "kai_betrayal":
            play("Wind", volume: 0.3, loops: true, fadeIn: true)
        case "naya_redemption":
            play("Liminal", volume: 0.5, loops: true, fadeIn: true)
        default:
            // Default ending music
            play("Liminal", volume: 0.5, loops: true, fadeIn: true)
        }
    }
} 