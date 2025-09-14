import SwiftUI

struct EndingView: View {
    let ending: Ending
    @Environment(\.dismiss) private var dismiss
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        ZStack {
            // Background with ending-appropriate visual effect
            Color.black
                .ignoresSafeArea()
                .visualEffect(getVisualEffectForEnding(), intensity: 1.0)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Ending Title
                    VStack(spacing: 10) {
                        Text("ENDING ACHIEVED")
                            .font(Theme.terminalFont(size: 20))
                            .foregroundColor(Theme.terminalGreen)
                        
                        Text(ending.type.title)
                            .font(Theme.terminalFont(size: 28))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)
                    
                    // Ending Description
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Journey's End")
                            .font(Theme.terminalFont(size: 18))
                            .foregroundColor(Theme.terminalGreen)
                        
                        Text(ending.type.description)
                            .font(Theme.terminalFont(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)
                    
                    // Narrative Text
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Final Chapter")
                            .font(Theme.terminalFont(size: 18))
                            .foregroundColor(Theme.terminalGreen)
                        
                        Text(ending.narrative)
                            .font(Theme.terminalFont(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    // Consequences
                    if !ending.consequences.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("The Consequences")
                                .font(Theme.terminalFont(size: 18))
                                .foregroundColor(Theme.terminalGreen)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(ending.consequences, id: \.self) { consequence in
                                    HStack(alignment: .top, spacing: 10) {
                                        Text("•")
                                            .foregroundColor(Theme.terminalGreen)
                                        
                                        Text(consequence)
                                            .font(Theme.terminalFont(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Achievement Unlocked
                    VStack(spacing: 15) {
                        Text("🏆 ACHIEVEMENT UNLOCKED")
                            .font(Theme.terminalFont(size: 16))
                            .foregroundColor(.yellow)
                        
                        Text("Ending: \(ending.type.title)")
                            .font(Theme.terminalFont(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .overlay(Rectangle().stroke(Color.yellow.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            // Unlock achievement
                            achievementManager.unlockAchievement("ending_\(ending.type.rawValue)")
                            
                            // Dismiss and return to main menu
                            dismiss()
                        }) {
                            Text("Return to Main Menu")
                                .font(Theme.terminalFont(size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.terminalGreen)
                                .overlay(Rectangle().stroke(Theme.terminalGreen, lineWidth: 1))
                        }
                        
                        Button(action: {
                            // Start new game
                            dismiss()
                            // This would need to be handled by the parent view
                        }) {
                            Text("Start New Game")
                                .font(Theme.terminalFont(size: 16))
                                .foregroundColor(Theme.terminalGreen)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(Rectangle().stroke(Theme.terminalGreen.opacity(0.4), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            // Play ending-specific audio
            playEndingAudio()
            
            // Apply haptic feedback
            Task {
                await HapticManager.shared.notification(.success)
            }
        }
    }
    
    private func getVisualEffectForEnding() -> VisualEffect {
        switch ending.type {
        case .pureHero:
            return .light
        case .corruptedTyrant:
            return .corruption
        case .balancedMaster:
            return .glow
        case .mysteriousDisappearance:
            return .shadow
        case .tragicSacrifice:
            return .dark
        case .ancientOneChosen:
            return .sparkle
        case .kaiBetrayal:
            return .shadow
        case .nayaRedemption:
            return .light
        }
    }
    
    private func playEndingAudio() {
        AudioManager.shared.playEndingMusic(for: ending.type.rawValue)
    }
} 