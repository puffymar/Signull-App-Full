import SwiftUI

public struct AchievementsView: View {
    @ObservedObject var storyStats: StoryPlayerStats
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRarity: AchievementRarity? = nil
    
    public init(storyStats: StoryPlayerStats) {
        self.storyStats = storyStats
    }
    
    var filteredAchievements: [StoryAchievement] {
        if let rarity = selectedRarity {
            return storyStats.achievements.filter { $0.rarity == rarity }
        }
        return storyStats.achievements
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Rarity filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button(action: {
                                selectedRarity = nil
                            }) {
                                Text("All")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedRarity == nil ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedRarity == nil ? Color.yellow.opacity(0.3) : Color.clear)
                                            .stroke(selectedRarity == nil ? Color.yellow : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            ForEach(AchievementRarity.allCases, id: \.self) { rarity in
                                Button(action: {
                                    selectedRarity = rarity
                                }) {
                                    HStack(spacing: 4) {
                                        Text(rarity.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedRarity == rarity ? .white : .gray)
                                        
                                        Text("(\(storyStats.achievements.filter { $0.rarity == rarity && $0.isUnlocked }.count)/\(storyStats.achievements.filter { $0.rarity == rarity }.count))")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedRarity == rarity ? rarity.color.opacity(0.3) : Color.clear)
                                            .stroke(selectedRarity == rarity ? rarity.color : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Statistics
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Unlocked",
                            value: "\(storyStats.achievements.filter { $0.isUnlocked }.count)",
                            total: "\(storyStats.achievements.count)",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Completion",
                            value: "\(Int((Double(storyStats.achievements.filter { $0.isUnlocked }.count) / Double(storyStats.achievements.count)) * 100))",
                            total: "%",
                            color: .yellow
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Achievements list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}

public struct StatCard: View {
    let title: String
    let value: String
    let total: String
    let color: Color
    
    public init(title: String, value: String, total: String, color: Color) {
        self.title = title
        self.value = value
        self.total = total
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
                
                Text(total)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color.black.opacity(0.4))
        )
    }
}

public struct AchievementCard: View {
    let achievement: StoryAchievement
    
    public init(achievement: StoryAchievement) {
        self.achievement = achievement
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Achievement icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.rarity.color : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievementIcon(for: achievement.id))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    
                    Spacer()
                    
                    Text(achievement.rarity.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(achievement.rarity.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(achievement.rarity.color.opacity(0.2))
                        )
                }
                
                Text(achievement.description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                
                if achievement.isUnlocked, let unlockDate = achievement.unlockDate {
                    Text("Unlocked: \(unlockDate, style: .date)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? achievement.rarity.color.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 1.5)
                .background(Color.black.opacity(0.4))
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
    
    private func achievementIcon(for id: String) -> String {
        switch id {
        case "pure_hero": return "star.fill"
        case "corrupted_path": return "flame.fill"
        case "trusting_soul": return "heart.fill"
        case "ancient_knowledge": return "book.closed.fill"
        case "quest_master": return "map.fill"
        case "community_builder": return "person.3.fill"
        default: return "trophy.fill"
        }
    }
} 