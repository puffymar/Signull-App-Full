import SwiftUI

// MARK: - Transcendent Button Component - Living Essence
struct TranscendentButton: View {
    let icon: String
    let text: String
    let isActive: Bool
    let glowIntensity: Double
    let breathingScale: Double
    let rotation: Double
    let pulse: Double
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var internalBreathing: Double = 1.0
    
    var body: some View {
        Button(action: {
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
            // Just text - no background, no material, nothing
            Text(text)
                .font(.system(size: 12, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .scaleEffect(1.0 + (internalBreathing * 0.01))
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                internalBreathing = 1.0
            }
        }
    }
}

// MARK: - Transcendent Choice Button - For Story Choices
struct TranscendentChoiceButton: View {
    let text: String
    let isEnabled: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var internalGlow = 0.0
    @State private var internalBreathing = 1.0
    @State private var internalPulse = 0.0
    
    var body: some View {
        Button(action: {
            if isEnabled {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    onTap()
                }
            }
        }) {
            ZStack {
                // Outer glow aura
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        RadialGradient(
                            colors: isEnabled ? [
                                Color.white.opacity(0.2 * (1.0 + internalGlow)),
                                Color.blue.opacity(0.15 * (1.0 + internalGlow)),
                                Color.purple.opacity(0.1 * (1.0 + internalGlow)),
                                Color.clear
                            ] : [
                                Color.gray.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .scaleEffect(1.1)
                    .blur(radius: 12)
                    .opacity(isEnabled ? 0.8 : 0.3)
                
                // Glassy background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isEnabled ? [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.1)
                            ] : [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: isEnabled ? [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.3)
                                    ] : [
                                        Color.gray.opacity(0.3),
                                        Color.gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .frame(maxWidth: .infinity, minHeight: 60)
                
                // Content
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(isEnabled ? .white : .gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .shadow(color: isEnabled ? .black.opacity(0.5) : .clear, radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
        }
        .scaleEffect((internalBreathing) * (isPressed ? 0.98 : 1.0))
        .opacity(isEnabled ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .onAppear {
            if isEnabled {
                startInternalAnimations()
            }
        }
    }
    
    private func startInternalAnimations() {
        // Breathing animation
        withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
            internalBreathing = 0.03
        }
        
        // Glow animation
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            internalGlow = 0.2
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            internalPulse = 0.3
        }
    }
} 