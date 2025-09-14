import AVFoundation
import SwiftUI

class NarrativeAudioManager: ObservableObject {
    static let shared = NarrativeAudioManager()
    
    @Published var currentMood: StoryMood = .neutral
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
    
    func updateAmbientTrack(for mood: StoryMood) {
        switch mood {
        case .dream:
            play("Liminal", volume: 0.4, loops: true, fadeIn: true)
        case .fear:
            play("Night", volume: 0.5, loops: true, fadeIn: true)
        case .panic:
            play("Night", volume: 0.7, loops: true, fadeIn: true)
        case .resolve:
            play("Liminal", volume: 0.6, loops: true, fadeIn: true)
        case .calm:
            play("Wind", volume: 0.3, loops: true, fadeIn: true)
        case .tension:
            play("Night", volume: 0.4, loops: true, fadeIn: true)
        case .wonder:
            play("Liminal", volume: 0.5, loops: true, fadeIn: true)
        case .dread:
            play("Night", volume: 0.6, loops: true, fadeIn: true)
        case .hope:
            play("Liminal", volume: 0.5, loops: true, fadeIn: true)
        case .neutral:
            play("Wind", volume: 0.4, loops: true, fadeIn: true)
        }
        
        currentMood = mood
        print("🎵 NarrativeAudioManager: Updated track for mood \(mood.rawValue)")
    }
    
    func play(_ fileName: String, volume: Float = 0.6, loops: Bool = true, fadeIn: Bool = false) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            // Try .wav extension
            guard let wavUrl = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
                print("❌ Audio file not found: \(fileName)")
                return
            }
            playAudioFile(wavUrl, volume: volume, loops: loops, fadeIn: fadeIn)
            return
        }
        
        playAudioFile(url, volume: volume, loops: loops, fadeIn: fadeIn)
    }
    
    private func playAudioFile(_ url: URL, volume: Float, loops: Bool, fadeIn: Bool) {
        do {
            // Stop current playback
            stop()
            
            // Create new player
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = fadeIn ? 0.0 : volume
            player?.numberOfLoops = loops ? -1 : 0
            player?.play()
            
            // Update state
            isPlaying = true
            self.volume = volume
            
            // Fade in if requested
            if fadeIn {
                fadeInAudio(duration: 2.0, targetVolume: volume)
            }
            
            print("🎵 Now playing: \(url.lastPathComponent)")
        } catch {
            print("❌ Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        player?.stop()
        player = nil
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
} 