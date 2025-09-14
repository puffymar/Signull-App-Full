import Foundation

// MARK: - Story Mood System
enum StoryMood: String, CaseIterable, Codable {
    case neutral = "neutral"
    case calm = "calm"
    case fear = "fear"
    case panic = "panic"
    case resolve = "resolve"
    case dream = "dream"
    case tension = "tension"
    case wonder = "wonder"
    case dread = "dread"
    case hope = "hope"
}

// MARK: - Story Action Types

enum ActionType: String, CaseIterable {
    case think = "Think"
    case act = "Act"
    case ask = "Ask"
    case reflect = "Reflect"
}

// MARK: - Story Tone Types

enum StoryTone: String, CaseIterable, Codable {
    case mystery = "mystery"
    case conflict = "conflict"
    case wonder = "wonder"
    case horror = "horror"
    case romance = "romance"
    case adventure = "adventure"
    
    var color: String {
        switch self {
        case .mystery: return "#6b46c1"
        case .conflict: return "#dc2626"
        case .wonder: return "#059669"
        case .horror: return "#7c2d12"
        case .romance: return "#be185d"
        case .adventure: return "#d97706"
        }
    }
    
    var description: String {
        switch self {
        case .mystery: return "Enigmatic and puzzling"
        case .conflict: return "Tense and confrontational"
        case .wonder: return "Magical and awe-inspiring"
        case .horror: return "Dark and terrifying"
        case .romance: return "Intimate and emotional"
        case .adventure: return "Exciting and exploratory"
        }
    }
}

// MARK: - Story Rarity Types

enum StoryRarity: String, CaseIterable, Codable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var color: String {
        switch self {
        case .common: return "#6b7280"
        case .uncommon: return "#059669"
        case .rare: return "#3b82f6"
        case .epic: return "#8b5cf6"
        case .legendary: return "#f59e0b"
        }
    }
    
    var glowIntensity: Double {
        switch self {
        case .common: return 0.1
        case .uncommon: return 0.3
        case .rare: return 0.5
        case .epic: return 0.7
        case .legendary: return 1.0
        }
    }
    
    var statBonus: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 5
        case .rare: return 10
        case .epic: return 20
        case .legendary: return 50
        }
    }
}

// MARK: - Story Metadata
struct StoryMetadata: Codable {
    let tone: String
    let intensity: Double
    let ambientColor: String
    let mood: StoryMood
    let sigil: String
    let rotation: Double
    let effect: String?
}