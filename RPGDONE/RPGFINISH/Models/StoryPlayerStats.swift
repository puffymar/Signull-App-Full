import Foundation
import SwiftUI

// MARK: - Morality System
public enum MoralityAlignment: String, CaseIterable, Codable {
    case pure = "Pure"
    case good = "Good"
    case neutral = "Neutral"
    case corrupted = "Corrupted"
    case evil = "Evil"
    
    public var description: String {
        switch self {
        case .pure: return "Pure Hero - Unwavering moral compass"
        case .good: return "Good - Generally virtuous choices"
        case .neutral: return "Neutral - Balanced approach"
        case .corrupted: return "Corrupted - Dark influences growing"
        case .evil: return "Evil - Embracing darkness"
        }
    }
    
    public var color: Color {
        switch self {
        case .pure: return .blue
        case .good: return .green
        case .neutral: return .yellow
        case .corrupted: return .orange
        case .evil: return .red
        }
    }
}

// MARK: - Dialogue System
public struct DialogueOption: Identifiable, Codable {
    public let id: String
    public let text: String
    public let moralityRequirement: MoralityAlignment?
    public let trustRequirement: Int?
    public let powerRequirement: Int?
    public let consequence: DialogueConsequence
    public let isHidden: Bool
    
    public init(id: String, text: String, moralityRequirement: MoralityAlignment?, trustRequirement: Int?, powerRequirement: Int?, consequence: DialogueConsequence, isHidden: Bool) {
        self.id = id
        self.text = text
        self.moralityRequirement = moralityRequirement
        self.trustRequirement = trustRequirement
        self.powerRequirement = powerRequirement
        self.consequence = consequence
        self.isHidden = isHidden
    }
}

public struct DialogueConsequence: Codable {
    public let moralityChange: Int
    public let trustChange: Int
    public let powerChange: Int
    public let unlocksQuest: String?
    public let revealsSecret: String?
    
    public init(moralityChange: Int, trustChange: Int, powerChange: Int, unlocksQuest: String?, revealsSecret: String?) {
        self.moralityChange = moralityChange
        self.trustChange = trustChange
        self.powerChange = powerChange
        self.unlocksQuest = unlocksQuest
        self.revealsSecret = revealsSecret
    }
}

// MARK: - Hidden Quest System
public struct HiddenQuest: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let requirements: [QuestRequirement]
    public let rewards: [QuestReward]
    public let isSecret: Bool
    public let chapterUnlock: Int
    
    public init(id: String, title: String, description: String, requirements: [QuestRequirement], rewards: [QuestReward], isSecret: Bool, chapterUnlock: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.requirements = requirements
        self.rewards = rewards
        self.isSecret = isSecret
        self.chapterUnlock = chapterUnlock
    }
}

public struct QuestRequirement: Codable {
    public let type: RequirementType
    public let value: String
    public let threshold: Int
    
    public init(type: RequirementType, value: String, threshold: Int) {
        self.type = type
        self.value = value
        self.threshold = threshold
    }
}

public struct QuestReward: Codable {
    public let type: RewardType
    public let value: String
    public let amount: Int
    
    public init(type: RewardType, value: String, amount: Int) {
        self.type = type
        self.value = value
        self.amount = amount
    }
}

// RequirementType is defined in GameState.swift

public enum RewardType: String, Codable {
    case stat, ability, item, lore, relationship, achievement
}

// MARK: - Achievement System
public struct StoryAchievement: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let rarity: AchievementRarity
    public var isUnlocked: Bool
    public var unlockDate: Date?
    public let requirements: [AchievementRequirement]
    
    public init(id: String, title: String, description: String, rarity: AchievementRarity, isUnlocked: Bool, unlockDate: Date?, requirements: [AchievementRequirement]) {
        self.id = id
        self.title = title
        self.description = description
        self.rarity = rarity
        self.isUnlocked = isUnlocked
        self.unlockDate = unlockDate
        self.requirements = requirements
    }
}

public struct AchievementRequirement: Codable {
    public let type: RequirementType
    public let value: String
    public let threshold: Int
    
    public init(type: RequirementType, value: String, threshold: Int) {
        self.type = type
        self.value = value
        self.threshold = threshold
    }
}

public enum AchievementRarity: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    public var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

// MARK: - Story Player Stats & Relational Tracking
public class StoryPlayerStats: ObservableObject {
    // MARK: - Core Stats
    @Published var curiosity: Int = 0
    @Published var survivalInstinct: Int = 0
    @Published var emotionalConnection: Int = 0
    @Published var knowledge: Int = 0
    @Published var resourcefulness: Int = 0
    @Published var survivalCaution: Int = 0
    @Published var practicality: Int = 0
    @Published var resources: Int = 0
    @Published var health: Int = 0
    @Published var emotionalClarity: Int = 0
    @Published var memory: Int = 0
    @Published var determination: Int = 0
    @Published var trusting: Int = 0
    @Published var caution: Int = 0
    @Published var forbiddenKnowledge: Int = 0
    @Published var insight: Int = 0
    @Published var prudence: Int = 0
    @Published var factionLoyalty: Int = 0
    @Published var independence: Int = 0
    @Published var deception: Int = 0
    @Published var moralClarity: Int = 0
    @Published var bravery: Int = 0
    @Published var communitySupport: Int = 0
    
    // MARK: - Morality System
    @Published var moralityScore: Int = 50 // 0-100 scale
    @Published var moralityAlignment: MoralityAlignment = .neutral
    @Published var corruptionEvents: [String] = []
    @Published var virtuousChoices: [String] = []
    
    // MARK: - Dialogue & Relationships
    @Published var dialogueHistory: [String] = []
    @Published var relationshipLevels: [String: Int] = [:]
    @Published var unlockedSecrets: Set<String> = []
    @Published var availableDialogueOptions: [DialogueOption] = []
    
    // MARK: - Hidden Quests
    @Published var discoveredQuests: [HiddenQuest] = []
    @Published var completedQuests: Set<String> = []
    @Published var activeQuests: [String] = []
    
    // MARK: - Achievements
    @Published var achievements: [StoryAchievement] = []
    @Published var recentAchievements: [StoryAchievement] = []
    
    // MARK: - Story Progression
    @Published var majorChoices: [String: String] = [:]
    @Published var storyFlags: [String: Bool] = [:]
    @Published var chapterProgress: [Int: Int] = [:]
    
    // MARK: - Computed Properties
    var isTrustworthy: Bool { trusting > caution }
    var isKnowledgeSeeker: Bool { curiosity + knowledge > survivalCaution }
    var isCommunityBuilder: Bool { emotionalConnection + trusting > independence }
    var isPowerHungry: Bool { forbiddenKnowledge > moralClarity }
    var isSurvivor: Bool { survivalInstinct + practicality > 0 }
    var hasAncientInsight: Bool { insight + knowledge > 3 }
    var isFactionAligned: Bool { factionLoyalty > independence }
    var isDeceptive: Bool { deception > 2 }
    var isBrave: Bool { bravery > 1 }
    var hasCommunitySupport: Bool { communitySupport > 1 }
    
    // MARK: - Morality Computed Properties
    var isPure: Bool { moralityScore >= 90 }
    var isGood: Bool { moralityScore >= 70 && moralityScore < 90 }
    var isNeutral: Bool { moralityScore >= 30 && moralityScore < 70 }
    var isCorrupted: Bool { moralityScore >= 10 && moralityScore < 30 }
    var isEvil: Bool { moralityScore < 10 }
    
    // MARK: - Initialization
    public init() {
        initializeAchievements()
        initializeHiddenQuests()
        setupDefaultRelationships()
    }
    
    // MARK: - Morality System
    public func updateMorality(change: Int, reason: String) {
        let oldAlignment = moralityAlignment
        moralityScore = max(0, min(100, moralityScore + change))
        
        // Update alignment based on score
        moralityAlignment = determineAlignment()
        
        // Track the choice
        if change > 0 {
            virtuousChoices.append(reason)
        } else if change < 0 {
            corruptionEvents.append(reason)
        }
        
        // Check for alignment-based achievements
        checkAlignmentAchievements(oldAlignment: oldAlignment)
        
        print("🎭 Morality updated: \(change) (\(reason)). New score: \(moralityScore) (\(moralityAlignment.rawValue))")
    }
    
    private func determineAlignment() -> MoralityAlignment {
        switch moralityScore {
        case 90...100: return .pure
        case 70..<90: return .good
        case 30..<70: return .neutral
        case 10..<30: return .corrupted
        default: return .evil
        }
    }
    
    // MARK: - Dialogue System
    public func getDialogueOptions(for character: String, context: String) -> [DialogueOption] {
        var options: [DialogueOption] = []
        
        // Base dialogue options
        options.append(DialogueOption(
            id: "greet_\(character)",
            text: "Greet \(character) warmly",
            moralityRequirement: .good,
            trustRequirement: 0,
            powerRequirement: nil,
            consequence: DialogueConsequence(moralityChange: 1, trustChange: 2, powerChange: 0, unlocksQuest: nil, revealsSecret: nil),
            isHidden: false
        ))
        
        options.append(DialogueOption(
            id: "question_\(character)",
            text: "Question \(character)'s motives",
            moralityRequirement: nil,
            trustRequirement: nil,
            powerRequirement: nil,
            consequence: DialogueConsequence(moralityChange: 0, trustChange: -1, powerChange: 1, unlocksQuest: nil, revealsSecret: nil),
            isHidden: false
        ))
        
        // Morality-specific options
        if moralityAlignment == .pure || moralityAlignment == .good {
            options.append(DialogueOption(
                id: "help_\(character)",
                text: "Offer to help \(character)",
                moralityRequirement: .good,
                trustRequirement: nil,
                powerRequirement: nil,
                consequence: DialogueConsequence(moralityChange: 2, trustChange: 3, powerChange: 0, unlocksQuest: "help_\(character)", revealsSecret: nil),
                isHidden: false
            ))
        }
        
        if moralityAlignment == .corrupted || moralityAlignment == .evil {
            options.append(DialogueOption(
                id: "threaten_\(character)",
                text: "Intimidate \(character)",
                moralityRequirement: .corrupted,
                trustRequirement: nil,
                powerRequirement: 5,
                consequence: DialogueConsequence(moralityChange: -2, trustChange: -3, powerChange: 3, unlocksQuest: nil, revealsSecret: nil),
                isHidden: false
            ))
        }
        
        // Power-specific options
        if forbiddenKnowledge > 5 {
            options.append(DialogueOption(
                id: "reveal_power_\(character)",
                text: "Reveal your ancient knowledge",
                moralityRequirement: nil,
                trustRequirement: nil,
                powerRequirement: 5,
                consequence: DialogueConsequence(moralityChange: -1, trustChange: 1, powerChange: 2, unlocksQuest: nil, revealsSecret: "ancient_power"),
                isHidden: false
            ))
        }
        
        return options.filter { option in
            // Check if player meets requirements
            if let moralityReq = option.moralityRequirement {
                if moralityAlignment != moralityReq { return false }
            }
            if let trustReq = option.trustRequirement {
                if trusting < trustReq { return false }
            }
            if let powerReq = option.powerRequirement {
                if forbiddenKnowledge < powerReq { return false }
            }
            return true
        }
    }
    
    public func selectDialogueOption(_ option: DialogueOption) {
        // Apply consequences
        updateMorality(change: option.consequence.moralityChange, reason: "Dialogue: \(option.text)")
        trusting += option.consequence.trustChange
        forbiddenKnowledge += option.consequence.powerChange
        
        // Track dialogue
        dialogueHistory.append(option.text)
        
        // Handle quest unlocks
        if let questId = option.consequence.unlocksQuest {
            unlockHiddenQuest(questId)
        }
        
        // Handle secret reveals
        if let secret = option.consequence.revealsSecret {
            unlockedSecrets.insert(secret)
        }
        
        print("💬 Selected dialogue: \(option.text)")
    }
    
    // MARK: - Hidden Quest System
    private func initializeHiddenQuests() {
        discoveredQuests = [
            HiddenQuest(
                id: "ancient_secrets",
                title: "Ancient Secrets",
                description: "Discover the truth about the cataclysm",
                requirements: [
                    QuestRequirement(type: .knowledge, value: "insight", threshold: 5),
                    QuestRequirement(type: .choice, value: "explore_ruins", threshold: 1)
                ],
                rewards: [
                    QuestReward(type: .lore, value: "cataclysm_truth", amount: 1),
                    QuestReward(type: .ability, value: "ancient_insight", amount: 1)
                ],
                isSecret: true,
                chapterUnlock: 2
            ),
            HiddenQuest(
                id: "mentor_legacy",
                title: "Mentor's Legacy",
                description: "Honor your teacher's memory through actions",
                requirements: [
                    QuestRequirement(type: .morality, value: "good", threshold: 70),
                    QuestRequirement(type: .choice, value: "mourn_teacher", threshold: 1)
                ],
                rewards: [
                    QuestReward(type: .stat, value: "emotional_clarity", amount: 10),
                    QuestReward(type: .achievement, value: "mentor_legacy", amount: 1)
                ],
                isSecret: true,
                chapterUnlock: 1
            ),
            HiddenQuest(
                id: "faction_espionage",
                title: "Faction Espionage",
                description: "Gather intelligence on the mysterious faction",
                requirements: [
                    QuestRequirement(type: .choice, value: "pretend_interest", threshold: 1),
                    QuestRequirement(type: .deception, value: "deception", threshold: 3)
                ],
                rewards: [
                    QuestReward(type: .lore, value: "faction_secrets", amount: 1),
                    QuestReward(type: .ability, value: "espionage", amount: 1)
                ],
                isSecret: true,
                chapterUnlock: 3
            )
        ]
    }
    
    public func unlockHiddenQuest(_ questId: String) {
        guard let quest = discoveredQuests.first(where: { $0.id == questId }),
              !activeQuests.contains(questId),
              !completedQuests.contains(questId) else { return }
        
        activeQuests.append(questId)
        print("🔍 Hidden quest unlocked: \(quest.title)")
        
        // Check for quest-related achievements
        checkQuestAchievements()
    }
    
    public func completeQuest(_ questId: String) {
        guard let quest = discoveredQuests.first(where: { $0.id == questId }),
              activeQuests.contains(questId) else { return }
        
        completedQuests.insert(questId)
        activeQuests.removeAll { $0 == questId }
        
        // Apply rewards
        for reward in quest.rewards {
            applyQuestReward(reward)
        }
        
        print("✅ Quest completed: \(quest.title)")
        
        // Check for completion achievements
        checkQuestCompletionAchievements()
    }
    
    private func applyQuestReward(_ reward: QuestReward) {
        switch reward.type {
        case .stat:
            // Apply stat bonus
            print("📈 Stat reward: \(reward.value) +\(reward.amount)")
        case .ability:
            // Unlock ability
            print("⚡ Ability unlocked: \(reward.value)")
        case .lore:
            // Reveal lore
            unlockedSecrets.insert(reward.value)
            print("📚 Lore revealed: \(reward.value)")
        case .relationship:
            // Improve relationship
            print("🤝 Relationship improved: \(reward.value)")
        case .achievement:
            // Unlock achievement
            unlockAchievement(reward.value)
        case .item:
            // Add item to inventory
            print("🎒 Item acquired: \(reward.value)")
        }
    }
    
    // MARK: - Achievement System
    private func initializeAchievements() {
        achievements = [
            // Morality Achievements
            StoryAchievement(
                id: "pure_hero",
                title: "Pure Hero",
                description: "Maintain pure morality throughout your journey",
                rarity: .legendary,
                isUnlocked: false,
                unlockDate: nil,
                requirements: [AchievementRequirement(type: .morality, value: "pure", threshold: 90)]
            ),
            StoryAchievement(
                id: "corrupted_path",
                title: "Corrupted Path",
                description: "Embrace the darkness within",
                rarity: .epic,
                isUnlocked: false,
                unlockDate: nil,
                requirements: [AchievementRequirement(type: .morality, value: "corrupted", threshold: 30)]
            ),
            
            // Choice Achievements
            StoryAchievement(
                id: "trusting_soul",
                title: "Trusting Soul",
                description: "Help others without hesitation",
                rarity: .rare,
                isUnlocked: false,
                unlockDate: nil,
                requirements: [AchievementRequirement(type: .choice, value: "help_stranger", threshold: 1)]
            ),
            StoryAchievement(
                id: "ancient_knowledge",
                title: "Ancient Knowledge",
                description: "Embrace forbidden knowledge",
                rarity: .epic,
                isUnlocked: false,
                unlockDate: nil,
                requirements: [AchievementRequirement(type: .power, value: "forbidden_knowledge", threshold: 5)]
            ),
            
            // Quest Achievements
            StoryAchievement(
                id: "quest_master",
                title: "Quest Master",
                description: "Complete multiple hidden quests",
                rarity: .rare,
                isUnlocked: false,
                unlockDate: nil,
                requirements: [AchievementRequirement(type: .quest, value: "completed_quests", threshold: 3)]
            ),
            
            // Relationship Achievements
            StoryAchievement(
                id: "community_builder",
                title: "Community Builder",
                description: "Build strong relationships with others",
                rarity: .uncommon,
                isUnlocked: false,
                unlockDate: nil,
                requirements: [AchievementRequirement(type: .relationship, value: "trust", threshold: 10)]
            )
        ]
    }
    
    public func unlockAchievement(_ achievementId: String) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }),
              !achievements[index].isUnlocked else { return }
        
        achievements[index].isUnlocked = true
        achievements[index].unlockDate = Date()
        
        let achievement = achievements[index]
        recentAchievements.append(achievement)
        
        print("🏆 Achievement unlocked: \(achievement.title) (\(achievement.rarity.rawValue))")
        
        // Auto-remove from recent after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.recentAchievements.removeAll { $0.id == achievementId }
        }
    }
    
    private func checkAlignmentAchievements(oldAlignment: MoralityAlignment) {
        if moralityAlignment == .pure && oldAlignment != .pure {
            unlockAchievement("pure_hero")
        }
        if moralityAlignment == .corrupted && oldAlignment != .corrupted {
            unlockAchievement("corrupted_path")
        }
    }
    
    private func checkQuestAchievements() {
        if activeQuests.count >= 2 {
            unlockAchievement("quest_master")
        }
    }
    
    private func checkQuestCompletionAchievements() {
        if completedQuests.count >= 3 {
            unlockAchievement("quest_master")
        }
    }
    
    // MARK: - Story Progression
    public func recordChoice(_ choiceId: String, context: String = "") {
        majorChoices[choiceId] = context
        
        // Check for choice-based achievements
        if choiceId == "help_stranger" {
            unlockAchievement("trusting_soul")
        }
        
        // Check for power-based achievements
        if forbiddenKnowledge >= 5 {
            unlockAchievement("ancient_knowledge")
        }
        
        // Check for relationship achievements
        if trusting >= 10 {
            unlockAchievement("community_builder")
        }
        
        print("📝 Recorded choice: \(choiceId) - \(context)")
    }
    
    private func setupDefaultRelationships() {
        let defaultCharacters = ["Teacher", "Stranger", "Faction Leader", "Ancient One"]
        for character in defaultCharacters {
            relationshipLevels[character] = 0
        }
    }
} 