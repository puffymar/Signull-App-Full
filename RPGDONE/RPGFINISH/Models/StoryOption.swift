import Foundation

struct StoryOption: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let summary: String
    var fullStory: String
    let theme: String
    let tone: StoryTone
    let rarity: StoryRarity
    let weight: Double
    let risk: Bool
    let unavailable: Bool
    
    init(title: String, summary: String, fullStory: String, theme: String, tone: StoryTone = .mystery, rarity: StoryRarity = .common, weight: Double = 1.0, risk: Bool = false, unavailable: Bool = false) {
        self.id = UUID()
        self.title = title
        self.summary = summary
        self.fullStory = fullStory
        self.theme = theme
        self.tone = tone
        self.rarity = rarity
        self.weight = weight
        self.risk = risk
        self.unavailable = unavailable
    }
    
    static func == (lhs: StoryOption, rhs: StoryOption) -> Bool {
        return lhs.id == rhs.id
    }
}

 
