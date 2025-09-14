import Foundation

struct WorldState: Codable, Equatable {
    var id: String = UUID().uuidString
    var season: String = "Eclipse"    // e.g., Eclipse, Ashfall, Monsoon
    var timeOfDay: String = "Twilight"
    var tension: Int = 3              // 1..5 guides intensity
    var flags: [String] = []          // e.g., ["city_blackout","artifact_cursed"]
    var inventory: [String] = []      // player-owned items/sigils

    mutating func apply(choice: String) {
        // Basic example: tweak tension/flags from choice id
        if choice.contains("risk") || choice.contains("dangerous") || choice.contains("fight") { 
            tension = min(5, tension+1) 
            flags.append("tension_high")
        }
        if choice.contains("calm") || choice.contains("peaceful") || choice.contains("meditate") { 
            tension = max(1, tension-1) 
            flags.append("peaceful_moment")
        }
        if choice.contains("explore") || choice.contains("investigate") {
            flags.append("curious_explorer")
        }
        if choice.contains("trust") {
            flags.append("trusting_nature")
        }
        if choice.contains("suspicious") || choice.contains("doubt") {
            flags.append("paranoid_tendency")
        }
        
        // Remove duplicate flags
        flags = Array(Set(flags))
        
        // Seasonal progression based on choices
        if flags.count > 10 {
            advanceSeason()
        }
    }
    
    private mutating func advanceSeason() {
        switch season {
        case "Eclipse": season = "Ashfall"
        case "Ashfall": season = "Monsoon"
        case "Monsoon": season = "Convergence"
        case "Convergence": season = "Eclipse"
        default: season = "Eclipse"
        }
        flags.removeAll() // Reset flags on season change
        print("🌟 Season advanced to: \(season)")
    }
} 