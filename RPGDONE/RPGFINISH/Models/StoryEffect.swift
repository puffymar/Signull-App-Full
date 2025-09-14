import Foundation

enum StoryEffect: Codable, Hashable {
    case health(Int)
    case energy(Int)
    case charisma(Int)
    case money(Double)
    case morality(Double)
    case hunger(Int)
    case sanity(Int)
    case strength(Int)
    case finalChoice
} 