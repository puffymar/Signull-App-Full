import SwiftUI

struct DailyBadge: View {
    @StateObject private var progression = Progression.shared
    @State private var glowIntensity: Double = 0.5
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            // Gem icon with count
            HStack(spacing: 4) {
                Image(systemName: "diamond.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 12, weight: .bold))
                
                Text("\(progression.gems)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            // Streak indicator
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 12, weight: .bold))
                
                Text("\(progression.streakDays)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .opacity(glowIntensity)
                )
        )
        .scaleEffect(pulseScale)
        .alert("Daily Reward!", isPresented: $progression.showDailyReward) {
            Button("Collect") {
                progression.showDailyReward = false
            }
        } message: {
            Text("Day \(progression.streakDays) • +\(min(5 + progression.streakDays, 20)) gems!")
        }
        .onAppear {
            startGlowAnimation()
        }
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
        
        // Subtle pulse when there's a good streak
        if progression.streakDays > 3 {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
} 