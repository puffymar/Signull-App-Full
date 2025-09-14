import Foundation

struct VisualCue: Codable, Hashable {
    let glowIntensity: Double
    
    init(glowIntensity: Double = 0.0) {
        self.glowIntensity = glowIntensity
    }
}

struct Trait: Codable, Identifiable, Hashable {
    let name: String
    let description: String
    let rarity: Rarity
    let category: String
    let effects: [String: Double]
    let visualCue: VisualCue?
    
    // Computed property for Identifiable
    var id: String { name }
    
    // Convenience initializer for stat modifiers
    init(name: String, description: String, statModifiers: [String: Int]) {
        self.name = name
        self.description = description
        self.rarity = .common
        self.category = "Character"
        self.effects = statModifiers.mapValues { Double($0) }
        self.visualCue = nil
    }
    
    // Full initializer
    init(name: String, description: String, rarity: Rarity, category: String, effects: [String: Double], visualCue: VisualCue? = nil) {
        self.name = name
        self.description = description
        self.rarity = rarity
        self.category = category
        self.effects = effects
        self.visualCue = visualCue
    }
    
    // Make it Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    // Make it Equatable
    static func == (lhs: Trait, rhs: Trait) -> Bool {
        lhs.name == rhs.name
    }
} 