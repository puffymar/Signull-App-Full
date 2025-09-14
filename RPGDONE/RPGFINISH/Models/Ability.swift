import Foundation
import SwiftUI

// MARK: - Ability Tier System

enum AbilityTier: String, CaseIterable, Codable {
    case divine = "S"
    case legendary = "A"
    case rare = "B"
    case uncommon = "C"
    case common = "D"
    
    var color: String {
        switch self {
        case .divine: return "gold"
        case .legendary: return "purple"
        case .rare: return "blue"
        case .uncommon: return "green"
        case .common: return "gray"
        }
    }
    
    var dropChance: Int {
        switch self {
        case .divine: return 3
        case .legendary: return 10
        case .rare: return 20
        case .uncommon: return 30
        case .common: return 37
        }
    }
}

// MARK: - Ability Types

enum AbilityType: String, CaseIterable, Codable {
    // Divine Tier (S) - 3% drop chance
    case divineEcho = "Divine Echo"
    case dreamphase = "Dreamphase"
    case realityShifter = "Reality Shifter"
    
    // Legendary Tier (A) - 10% drop chance
    case emberTongue = "Ember Tongue"
    case nullfoot = "Nullfoot"
    case echoMemory = "Echo Memory"
    case shadowStep = "Shadow Step"
    case mindReader = "Mind Reader"
    
    // Rare Tier (B) - 20% drop chance
    case fireBreath = "Fire Breath"
    case stealthMaster = "Stealth Master"
    case loreEcho = "Lore Echo"
    case timeSlip = "Time Slip"
    case spiritWalk = "Spirit Walk"
    case crystalSight = "Crystal Sight"
    
    // Uncommon Tier (C) - 30% drop chance
    case nightVision = "Night Vision"
    case waterBreathing = "Water Breathing"
    case stoneSkin = "Stone Skin"
    case windWalker = "Wind Walker"
    case lightningReflexes = "Lightning Reflexes"
    case ironWill = "Iron Will"
    
    // Common Tier (D) - 37% drop chance
    case basicHealing = "Basic Healing"
    case minorStrength = "Minor Strength"
    case simpleMagic = "Simple Magic"
    case basicStealth = "Basic Stealth"
    case minorSpeed = "Minor Speed"
    case simpleWisdom = "Simple Wisdom"
    
    var tier: AbilityTier {
        switch self {
        case .divineEcho, .dreamphase, .realityShifter:
            return .divine
        case .emberTongue, .nullfoot, .echoMemory, .shadowStep, .mindReader:
            return .legendary
        case .fireBreath, .stealthMaster, .loreEcho, .timeSlip, .spiritWalk, .crystalSight:
            return .rare
        case .nightVision, .waterBreathing, .stoneSkin, .windWalker, .lightningReflexes, .ironWill:
            return .uncommon
        case .basicHealing, .minorStrength, .simpleMagic, .basicStealth, .minorSpeed, .simpleWisdom:
            return .common
        }
    }
    
    var description: String {
        switch self {
        // Divine Tier
        case .divineEcho:
            return "Echoes of divine power resonate through your being. Skip major story forks and unlock rare stat bonuses."
        case .dreamphase:
            return "Phase between dreams and reality. Unlock unique side quests and hidden story paths."
        case .realityShifter:
            return "Bend the fabric of reality itself. Access alternate story outcomes and secret endings."
            
        // Legendary Tier
        case .emberTongue:
            return "Your words carry the heat of fire. Fire-based dialogue overrides and combat advantages."
        case .nullfoot:
            return "Move silently through shadows. Enhanced stealth and evasion bonuses."
        case .echoMemory:
            return "Past experiences echo in your mind. Minor lore revelations on NPC contact."
        case .shadowStep:
            return "Step through shadows to appear elsewhere. Instant movement and escape abilities."
        case .mindReader:
            return "Read the thoughts of others. Unlock hidden dialogue options and secrets."
            
        // Rare Tier
        case .fireBreath:
            return "Breathe controlled flames. Fire-based combat abilities and environmental interactions."
        case .stealthMaster:
            return "Master of shadows and silence. Enhanced stealth capabilities and infiltration."
        case .loreEcho:
            return "Ancient knowledge whispers to you. Reveal hidden lore and historical secrets."
        case .timeSlip:
            return "Briefly slip through time. Momentary advantages in combat and exploration."
        case .spiritWalk:
            return "Walk between the material and spiritual realms. Access to spirit-based interactions."
        case .crystalSight:
            return "See through illusions and deception. Reveal hidden objects and true intentions."
            
        // Uncommon Tier
        case .nightVision:
            return "See clearly in darkness. Enhanced vision in low-light conditions."
        case .waterBreathing:
            return "Breathe underwater. Aquatic exploration and survival capabilities."
        case .stoneSkin:
            return "Skin as hard as stone. Enhanced physical defense and damage resistance."
        case .windWalker:
            return "Walk on air currents. Enhanced mobility and environmental traversal."
        case .lightningReflexes:
            return "React with lightning speed. Enhanced combat reflexes and initiative."
        case .ironWill:
            return "Unbreakable mental fortitude. Resistance to mental effects and corruption."
            
        // Common Tier
        case .basicHealing:
            return "Basic healing abilities. Minor health restoration and recovery."
        case .minorStrength:
            return "Slightly enhanced physical strength. Minor combat and carrying bonuses."
        case .simpleMagic:
            return "Basic magical abilities. Minor spell casting and magical interactions."
        case .basicStealth:
            return "Basic stealth capabilities. Minor concealment and quiet movement."
        case .minorSpeed:
            return "Slightly enhanced movement speed. Minor mobility and escape bonuses."
        case .simpleWisdom:
            return "Basic wisdom and insight. Minor problem-solving and dialogue bonuses."
        }
    }
    
    var icon: String {
        switch self {
        // Divine Tier
        case .divineEcho: return "sparkles.rectangle.stack"
        case .dreamphase: return "moon.stars"
        case .realityShifter: return "atom"
            
        // Legendary Tier
        case .emberTongue: return "flame"
        case .nullfoot: return "person.fill.questionmark"
        case .echoMemory: return "brain.head.profile"
        case .shadowStep: return "person.fill.turn.down"
        case .mindReader: return "eye.trianglebadge.exclamationmark"
            
        // Rare Tier
        case .fireBreath: return "flame.fill"
        case .stealthMaster: return "person.fill.turn.right"
        case .loreEcho: return "book.closed"
        case .timeSlip: return "clock.arrow.circlepath"
        case .spiritWalk: return "person.2.wave.2"
        case .crystalSight: return "eye.trianglebadge.exclamationmark.fill"
            
        // Uncommon Tier
        case .nightVision: return "eye"
        case .waterBreathing: return "drop"
        case .stoneSkin: return "shield"
        case .windWalker: return "wind"
        case .lightningReflexes: return "bolt"
        case .ironWill: return "brain"
            
        // Common Tier
        case .basicHealing: return "heart"
        case .minorStrength: return "figure.strengthtraining.traditional"
        case .simpleMagic: return "sparkles"
        case .basicStealth: return "person.fill.questionmark"
        case .minorSpeed: return "figure.run"
        case .simpleWisdom: return "lightbulb"
        }
    }
    
    var storyTriggers: [String] {
        switch self {
        case .divineEcho:
            return ["story_fork", "rare_stat_bonus", "divine_intervention"]
        case .dreamphase:
            return ["side_quest", "hidden_path", "dream_realm"]
        case .realityShifter:
            return ["alternate_ending", "reality_bend", "secret_outcome"]
        case .emberTongue:
            return ["fire_dialogue", "combat_advantage", "fire_environment"]
        case .nullfoot:
            return ["stealth_mission", "evasion", "shadow_movement"]
        case .echoMemory:
            return ["npc_contact", "lore_revelation", "memory_echo"]
        case .shadowStep:
            return ["instant_movement", "escape", "shadow_teleport"]
        case .mindReader:
            return ["hidden_dialogue", "secret_revelation", "thought_reading"]
        case .fireBreath:
            return ["fire_combat", "environmental_fire", "fire_interaction"]
        case .stealthMaster:
            return ["stealth_mission", "infiltration", "silent_movement"]
        case .loreEcho:
            return ["lore_discovery", "historical_secret", "ancient_knowledge"]
        case .timeSlip:
            return ["combat_advantage", "exploration_boost", "temporal_shift"]
        case .spiritWalk:
            return ["spirit_interaction", "realm_travel", "spiritual_insight"]
        case .crystalSight:
            return ["illusion_reveal", "hidden_object", "true_vision"]
        case .nightVision:
            return ["dark_exploration", "low_light_advantage", "night_vision"]
        case .waterBreathing:
            return ["aquatic_exploration", "underwater_survival", "water_movement"]
        case .stoneSkin:
            return ["physical_defense", "damage_resistance", "stone_protection"]
        case .windWalker:
            return ["air_movement", "wind_traversal", "aerial_advantage"]
        case .lightningReflexes:
            return ["combat_initiative", "quick_reaction", "speed_advantage"]
        case .ironWill:
            return ["mental_resistance", "corruption_resistance", "willpower"]
        case .basicHealing:
            return ["health_restoration", "recovery", "healing"]
        case .minorStrength:
            return ["combat_bonus", "carrying_capacity", "physical_advantage"]
        case .simpleMagic:
            return ["spell_casting", "magical_interaction", "basic_magic"]
        case .basicStealth:
            return ["concealment", "quiet_movement", "stealth"]
        case .minorSpeed:
            return ["mobility", "escape", "speed_advantage"]
        case .simpleWisdom:
            return ["problem_solving", "dialogue_bonus", "wisdom"]
        }
    }
    
    var statBonuses: [String: Int] {
        switch self {
        case .divineEcho:
            return ["magic": 10, "intelligence": 5, "realityBending": 15]
        case .dreamphase:
            return ["dreamAlignment": 15, "magic": 8, "empathy": 5]
        case .realityShifter:
            return ["realityBending": 20, "magic": 10, "intelligence": 8]
        case .emberTongue:
            return ["strength": 8, "magic": 5, "charisma": 3]
        case .nullfoot:
            return ["agility": 10, "stealth": 8, "speed": 5]
        case .echoMemory:
            return ["intelligence": 5, "empathy": 3, "wisdom": 5]
        case .shadowStep:
            return ["agility": 8, "stealth": 10, "speed": 5]
        case .mindReader:
            return ["intelligence": 8, "empathy": 10, "charisma": 5]
        case .fireBreath:
            return ["strength": 5, "magic": 8, "combat": 10]
        case .stealthMaster:
            return ["agility": 10, "stealth": 15, "speed": 8]
        case .loreEcho:
            return ["intelligence": 8, "wisdom": 10, "knowledge": 5]
        case .timeSlip:
            return ["agility": 8, "speed": 10, "intelligence": 5]
        case .spiritWalk:
            return ["magic": 8, "empathy": 10, "spirit": 15]
        case .crystalSight:
            return ["intelligence": 10, "perception": 15, "wisdom": 5]
        case .nightVision:
            return ["perception": 8, "survival": 5, "exploration": 3]
        case .waterBreathing:
            return ["survival": 10, "exploration": 8, "aquatic": 15]
        case .stoneSkin:
            return ["defense": 15, "strength": 5, "survival": 8]
        case .windWalker:
            return ["agility": 8, "speed": 10, "mobility": 12]
        case .lightningReflexes:
            return ["agility": 12, "speed": 8, "combat": 10]
        case .ironWill:
            return ["resolve": 15, "sanity": 10, "mental": 8]
        case .basicHealing:
            return ["health": 5, "recovery": 8, "survival": 3]
        case .minorStrength:
            return ["strength": 3, "combat": 5, "physical": 3]
        case .simpleMagic:
            return ["magic": 3, "spellcasting": 5, "magical": 3]
        case .basicStealth:
            return ["stealth": 5, "agility": 3, "concealment": 3]
        case .minorSpeed:
            return ["speed": 3, "agility": 3, "mobility": 3]
        case .simpleWisdom:
            return ["wisdom": 3, "intelligence": 3, "insight": 3]
        }
    }
}

// MARK: - Ability Structure

struct Ability: Identifiable, Codable {
    var id = UUID()
    let type: AbilityType
    let tier: AbilityTier
    var isUnlocked: Bool = false
    var unlockDate: Date?
    var usageCount: Int = 0
    var lastUsed: Date?
    
    var displayName: String {
        return type.rawValue
    }
    
    var description: String {
        return type.description
    }
    
    var icon: String {
        return type.icon
    }
    
    var storyTriggers: [String] {
        return type.storyTriggers
    }
    
    var statBonuses: [String: Int] {
        return type.statBonuses
    }
    
    init(type: AbilityType) {
        self.type = type
        self.tier = type.tier
    }
}

// MARK: - Ability Manager

class AbilityManager: ObservableObject {
    static let shared = AbilityManager()
    
    @Published var unlockedAbilities: [Ability] = []
    @Published var availableAbilities: [AbilityType] = []
    
    private init() {
        setupAvailableAbilities()
    }
    
    private func setupAvailableAbilities() {
        availableAbilities = AbilityType.allCases
    }
    
    func assignRandomAbility() -> Ability? {
        let rng = Int.random(in: 1...100)
        var cumulativeChance = 0
        
        for abilityType in availableAbilities {
            cumulativeChance += abilityType.tier.dropChance
            if rng <= cumulativeChance {
                let ability = Ability(type: abilityType)
                unlockAbility(ability)
                return ability
            }
        }
        
        return nil
    }
    
    func unlockAbility(_ ability: Ability) {
        if !unlockedAbilities.contains(where: { $0.type == ability.type }) {
            var newAbility = ability
            newAbility.isUnlocked = true
            newAbility.unlockDate = Date()
            unlockedAbilities.append(newAbility)
            
            print("🎯 Ability unlocked: \(ability.displayName) (Tier \(ability.tier.rawValue))")
        }
    }
    
    func useAbility(_ ability: Ability) {
        if let index = unlockedAbilities.firstIndex(where: { $0.id == ability.id }) {
            unlockedAbilities[index].usageCount += 1
            unlockedAbilities[index].lastUsed = Date()
        }
    }
    
    func getAbilityByType(_ type: AbilityType) -> Ability? {
        return unlockedAbilities.first { $0.type == type }
    }
    
    func hasAbility(_ type: AbilityType) -> Bool {
        return unlockedAbilities.contains { $0.type == type && $0.isUnlocked }
    }
    
    func getAbilitiesByTier(_ tier: AbilityTier) -> [Ability] {
        return unlockedAbilities.filter { $0.tier == tier }
    }
    
    func resetAbilities() {
        unlockedAbilities.removeAll()
    }
    
    func applyAbilityBonuses(to stats: inout PlayerStats) {
        for ability in unlockedAbilities where ability.isUnlocked {
            for (statName, bonus) in ability.statBonuses {
                switch statName {
                case "health":
                    stats.modifyHealth(bonus)
                case "strength":
                    stats.modifyStrength(bonus)
                case "intelligence":
                    stats.modifyIntelligence(bonus)
                case "charisma":
                    stats.modifyCharisma(bonus)
                case "magic":
                    stats.modifyMagic(bonus)
                case "sanity":
                    stats.modifySanity(bonus)
                case "dreamAlignment":
                    stats.modifyDreamAlignment(bonus)
                case "realityBending":
                    stats.modifyRealityBending(bonus)
                case "compassion":
                    stats.modifyCompassion(bonus)
                case "resolve":
                    stats.modifyResolve(bonus)
                case "empathy":
                    stats.modifyEmpathy(bonus)
                case "energy":
                    stats.modifyEnergy(bonus)
                case "kaiLoyalty":
                    stats.modifyKaiLoyalty(bonus)
                case "nayaTrust":
                    stats.modifyNayaTrust(bonus)
                case "ancientOneFavor":
                    stats.modifyAncientOneFavor(bonus)
                case "courage":
                    stats.modifyCourage(bonus)
                case "adaptability":
                    stats.modifyAdaptability(bonus)
                default:
                    break
                }
            }
        }
    }
    
    func checkStoryTriggers(for trigger: String) -> [Ability] {
        return unlockedAbilities.filter { ability in
            ability.isUnlocked && ability.storyTriggers.contains(trigger)
        }
    }
} 