import Foundation
import SwiftUI

enum AchievementCategory: String, CaseIterable, Codable {
    case story = "Story"
    case exploration = "Exploration"
    case combat = "Combat"
    case social = "Social"
    case survival = "Survival"
    case magic = "Magic"
    case ending = "Ending"
}

// Using AchievementRarity from StoryPlayerStats.swift

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    var isUnlocked: Bool
    var unlockDate: Date?
    var progress: Double // 0.0 to 1.0
    let maxProgress: Double
    
    init(id: String, title: String, description: String, category: AchievementCategory, rarity: AchievementRarity, maxProgress: Double = 1.0) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.rarity = rarity
        self.isUnlocked = false
        self.unlockDate = nil
        self.progress = 0.0
        self.maxProgress = maxProgress
    }
}

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = []
    @Published var showingNotification = false
    @Published var lastUnlockedAchievement: Achievement?
    @Published var notificationSetting: Int = 0 // 0 = off, 1 = on
    
    private init() {
        initializeAchievements()
    }
    
    private func initializeAchievements() {
        achievements = [
            // Story Achievements
            Achievement(id: "first_chapter", title: "First Steps", description: "Complete your first chapter", category: .story, rarity: .common),
            Achievement(id: "character_created", title: "Identity Forged", description: "Create your character", category: .story, rarity: .common),
            Achievement(id: "magic_test", title: "Arcane Discovery", description: "Complete the magic test", category: .magic, rarity: .uncommon),
            
            // Exploration Achievements
            Achievement(id: "explore_markets", title: "Market Explorer", description: "Explore the local markets", category: .exploration, rarity: .common),
            Achievement(id: "first_choice", title: "Decision Maker", description: "Make your first choice", category: .story, rarity: .common),
            
            // Social Achievements
            Achievement(id: "meet_traveler", title: "First Contact", description: "Meet the mysterious traveler", category: .social, rarity: .uncommon),
            Achievement(id: "high_charisma", title: "Silver Tongue", description: "Reach high charisma", category: .social, rarity: .rare),
            
            // Survival Achievements
            Achievement(id: "survive_storm", title: "Storm Survivor", description: "Survive a storm", category: .survival, rarity: .uncommon),
            Achievement(id: "low_health", title: "Near Death", description: "Survive with very low health", category: .survival, rarity: .rare),
            
            // Combat Achievements
            Achievement(id: "first_fight", title: "First Blood", description: "Engage in your first conflict", category: .combat, rarity: .common),
            
            // Magic Achievements
            Achievement(id: "high_magic", title: "Arcane Mastery", description: "Reach high magic affinity", category: .magic, rarity: .epic),
            Achievement(id: "exceptional_magic", title: "Magical Prodigy", description: "Achieve exceptional magic test result", category: .magic, rarity: .legendary),
            
            // Ending Achievements
            Achievement(id: "ending_pure_hero", title: "Pure Hero", description: "Achieve the Pure Hero ending", category: .ending, rarity: .epic),
            Achievement(id: "ending_corrupted_tyrant", title: "Corrupted Tyrant", description: "Achieve the Corrupted Tyrant ending", category: .ending, rarity: .epic),
            Achievement(id: "ending_balanced_master", title: "Balanced Master", description: "Achieve the Balanced Master ending", category: .ending, rarity: .legendary),
            Achievement(id: "ending_mysterious_disappearance", title: "Mysterious Disappearance", description: "Achieve the Mysterious Disappearance ending", category: .ending, rarity: .rare),
            Achievement(id: "ending_tragic_sacrifice", title: "Tragic Sacrifice", description: "Achieve the Tragic Sacrifice ending", category: .ending, rarity: .epic),
            Achievement(id: "ending_ancient_one_chosen", title: "Ancient One Chosen", description: "Achieve the Ancient One Chosen ending", category: .ending, rarity: .legendary),
            Achievement(id: "ending_kai_betrayal", title: "Kai's Betrayal", description: "Achieve the Kai's Betrayal ending", category: .ending, rarity: .rare),
            Achievement(id: "ending_naya_redemption", title: "Naya's Redemption", description: "Achieve the Naya's Redemption ending", category: .ending, rarity: .epic)
        ]
    }
    
    func checkAchievements(for stats: PlayerStats, gameState: GameState) {
        // Character creation
        if !stats.playerName.isEmpty {
            unlockAchievement("character_created")
        }
        
        // Magic test
        if stats.hasCompletedMagicTest {
            unlockAchievement("magic_test")
            
            if let result = stats.magicTestResult, result == .exceptional {
                unlockAchievement("exceptional_magic")
            }
        }
        
        // Magic affinity
        if stats.magicAffinity >= 80 {
            unlockAchievement("high_magic")
        }
        
        // Charisma
        if stats.charisma >= 80 {
            unlockAchievement("high_charisma")
        }
        
        // Health
        if stats.health <= 10 && stats.health > 0 {
            unlockAchievement("low_health")
        }
        
        // Weather
        if stats.currentWeather == .stormy {
            unlockAchievement("survive_storm")
        }
        
        // Story progress
        if gameState.currentChapter > 1 {
            unlockAchievement("first_chapter")
        }
        
        // Exploration
        if stats.hasExploredMarkets {
            unlockAchievement("explore_markets")
        }
        
        // Social
        if stats.hasMetTraveler {
            unlockAchievement("meet_traveler")
        }
    }
    
    func unlockAchievement(_ id: String) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        
        let achievement = achievements[index]
        if !achievement.isUnlocked {
            achievements[index].isUnlocked = true
            achievements[index].unlockDate = Date()
            achievements[index].progress = achievement.maxProgress
            
            lastUnlockedAchievement = achievements[index]
            
            // Only show notification if setting is enabled
            if notificationSetting > 0 {
                showingNotification = true
                
                // Auto-hide notification after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showingNotification = false
                }
            }
        }
    }
    
    func updateProgress(_ id: String, progress: Double) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        
        let achievement = achievements[index]
        if !achievement.isUnlocked {
            achievements[index].progress = min(progress, achievement.maxProgress)
            
            if achievements[index].progress >= achievement.maxProgress {
                unlockAchievement(id)
            }
        }
    }
    
    func getUnlockedCount() -> Int {
        return achievements.filter { $0.isUnlocked }.count
    }
    
    func getTotalCount() -> Int {
        return achievements.count
    }
    
    func getAchievementsByCategory(_ category: AchievementCategory) -> [Achievement] {
        return achievements.filter { $0.category == category }
    }
    
    func getAchievementsByRarity(_ rarity: AchievementRarity) -> [Achievement] {
        return achievements.filter { $0.rarity == rarity }
    }
    
    func resetAllAchievements() {
        for index in achievements.indices {
            achievements[index].isUnlocked = false
            achievements[index].unlockDate = nil
            achievements[index].progress = 0.0
        }
        print("🏆 All achievements reset")
    }
} 