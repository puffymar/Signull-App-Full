import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager.shared
    @State private var musicEnabled = true
    @State private var visualEffectsEnabled = true
    @State private var highContrastMode = false
    @State private var vfxEnabled = true
    @State private var skipMusic = false
    @State private var resetPlaythrough = false
    @State private var musicVolume: Double = 0.6
    @State private var soundEffectsVolume: Double = 0.5
    @State private var breath = false
    
    // 🔮 PSYCHO-SPIRITUAL SETTINGS EFFECTS
    @State private var cardGlow: Double = 0.0
    @State private var scanlineOffset: CGFloat = 0
    @State private var scanlinePulse: Double = 0.0
    @State private var scanlineIntensity: Double = 0.0
    @State private var cyanPulse: Double = 0.0
    @State private var mysticalAura: Double = 0.0
    
    var body: some View {
        ZStack {
            // MARK: - MYSTICAL CRT BACKGROUND
            Color.black
                .ignoresSafeArea()
            
            // MARK: - OPTIMIZED SCANLINES (FULL PAGE COVERAGE)
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.height / 3), id: \.self) { index in
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cyan.opacity(0.05 + (scanlinePulse * 0.02)))
                            .offset(x: scanlineOffset + CGFloat(index % 3) * 1.5)
                            .opacity(0.3 + (scanlineIntensity * 0.2))
                    }
                }
                .offset(y: -100) // Extend beyond screen bounds
                .clipped()
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true), value: scanlineOffset)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: scanlinePulse)
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: scanlineIntensity)
            
            // MARK: - MYSTICAL AURA
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.cyan.opacity(mysticalAura * 0.1),
                    Color.blue.opacity(mysticalAura * 0.05),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .blur(radius: 150)
            .scaleEffect(1.0 + (mysticalAura * 0.1))
            .opacity(mysticalAura)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: mysticalAura)
            
            // MARK: - CARD-STYLE FLOATING PANEL
            VStack(spacing: 0) {
                // MARK: - HEADER
                HStack {
                    Text("Settings")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.3), radius: 5)
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.cyan)
                    .underline()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // MARK: - SCROLLABLE CONTENT
                ScrollView {
                    VStack(spacing: 30) {
                        // MARK: - AUDIO SECTION (ENHANCED)
                        MysticalSettingsSection(
                            title: "Audio",
                            icon: "speaker.wave.3.fill"
                        ) {
                            VStack(spacing: 15) {
                                MysticalToggleRow(
                                    title: "Music",
                                    icon: "music.note",
                                    isOn: $musicEnabled
                                )
                                
                                MysticalInfoRow(
                                    title: "Now Playing:",
                                    value: audioManager.getCurrentTrackDisplayName(),
                                    icon: "play.circle"
                                )
                                
                                MysticalSliderRow(
                                    title: "Music Volume",
                                    icon: "speaker.wave.2",
                                    value: $musicVolume,
                                    percentage: "\(Int(musicVolume * 100))%"
                                )
                                
                                MysticalSliderRow(
                                    title: "Sound Effects",
                                    icon: "speaker.wave.1",
                                    value: $soundEffectsVolume,
                                    percentage: "\(Int(soundEffectsVolume * 100))%"
                                )
                            }
                        }
                        
                        // MARK: - VISUAL EFFECTS SECTION (ENHANCED)
                        MysticalSettingsSection(
                            title: "Visual Effects",
                            icon: "sparkles"
                        ) {
                            VStack(spacing: 15) {
                                MysticalToggleRow(
                                    title: "Visual Effects",
                                    icon: "sparkles",
                                    isOn: $vfxEnabled
                                )
                                
                                MysticalToggleRow(
                                    title: "High Contrast",
                                    icon: "eye",
                                    isOn: $highContrastMode
                                )
                                
                                MysticalToggleRow(
                                    title: "Skip Music",
                                    icon: "forward",
                                    isOn: $skipMusic
                                )
                            }
                        }
                        
                        // MARK: - SYSTEM SECTION (ENHANCED)
                        MysticalSettingsSection(
                            title: "System",
                            icon: "gearshape"
                        ) {
                            VStack(spacing: 15) {
                                MysticalToggleRow(
                                    title: "Reset Playthrough",
                                    icon: "arrow.clockwise",
                                    isOn: $resetPlaythrough
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(
                // MARK: - TRANSLUCENT CYAN GLOW + SCANLINES
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.1),
                                Color.blue.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.cyan.opacity(0.3),
                                        Color.blue.opacity(0.2),
                                        Color.cyan.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .cyan.opacity(cardGlow * 0.4), radius: 20)
                    .shadow(color: .blue.opacity(cardGlow * 0.2), radius: 30)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .onAppear {
            startMysticalEffects()
        }
    }
    
    // 🔮 MYSTICAL EFFECTS
    private func startMysticalEffects() {
        // Card glow pulse
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            cardGlow = 1.0
        }
        
        // Optimized scanline effects
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            scanlinePulse = 1.0
        }
        
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) {
            scanlineIntensity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
            scanlineOffset = 2.0
        }
        
        // Cyan pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            cyanPulse = 1.0
        }
        
        // Mystical aura
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            mysticalAura = 1.0
        }
    }
}

// MARK: - MYSTICAL SETTINGS COMPONENTS
struct MysticalSettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cyan.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
            )
            
            content
                .padding(.horizontal, 15)
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

struct MysticalToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .font(.system(size: 16))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOn.toggle()
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isOn ? Color.cyan : Color.gray.opacity(0.3))
                    .frame(width: 44, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 18, height: 18)
                            .offset(x: isOn ? 10 : -10)
                            .animation(.easeInOut(duration: 0.2), value: isOn)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
        }
        .padding(.vertical, 8)
    }
}

struct MysticalInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .font(.system(size: 16))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.cyan)
        }
        .padding(.vertical, 8)
    }
}

struct MysticalSliderRow: View {
    let title: String
    let icon: String
    @Binding var value: Double
    let percentage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                    .font(.system(size: 16))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(percentage)
                    .font(.system(size: 14))
                    .foregroundColor(.cyan)
            }
            
            Slider(value: $value, in: 0...1)
                .accentColor(.cyan)
        }
        .padding(.vertical, 8)
    }
} 