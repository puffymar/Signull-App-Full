import SwiftUI

struct AchievementNotificationView: View {
    @ObservedObject var achievementManager = AchievementManager.shared
    
    var body: some View {
        if achievementManager.showingNotification, let achievement = achievementManager.lastUnlockedAchievement {
            VStack {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ACHIEVEMENT UNLOCKED!")
                            .font(Theme.terminalFont(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(achievement.title)
                            .font(Theme.terminalFont(size: 16))
                            .foregroundColor(Theme.terminalGreen)
                            .fontWeight(.bold)
                        
                        Text(achievement.description)
                            .font(Theme.terminalFont(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(achievement.category.rawValue)
                                .font(Theme.terminalFont(size: 10))
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text(achievement.rarity.rawValue)
                                .font(Theme.terminalFont(size: 10))
                                .foregroundColor(rarityColor(for: achievement.rarity))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Theme.darkBackground.opacity(0.9))
                .overlay(Rectangle().stroke(Theme.terminalGreen, lineWidth: 2))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.5), value: achievementManager.showingNotification)
            }
        }
    }
    
    private func rarityColor(for rarity: AchievementRarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
} 