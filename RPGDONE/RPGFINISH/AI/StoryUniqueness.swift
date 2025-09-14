import Foundation

struct StoryFingerprint {
    static func make(from s: StoryData) -> String {
        (s.title + "|" + s.theme + "|" + s.setting + "|" + s.openingHook)
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    static func boilerplate(_ s: StoryData) -> Bool {
        let hay = (s.openingHook + " " + s.fullStory).lowercased()
        return hay.contains("your story begins here") || 
               hay.contains("the ai has thought") || 
               hay.contains("in this tale")
    }
}

final class StoryMemory { 
    static var seen = Set<String>() 
} 