import Foundation
import SwiftUI

final class PrewarmStore: ObservableObject {
    static let shared = PrewarmStore()
    
    @Published var seedId: String?
    @Published var storyJSON: Data?
    @Published var timestamp: Date?
    @Published var isPrewarming: Bool = false

    func hasFresh(seconds: TimeInterval = 90) -> Bool {
        guard let t = timestamp else { return false }
        return Date().timeIntervalSince(t) < seconds && storyJSON != nil
    }

    func clear() { 
        seedId = nil
        storyJSON = nil 
        timestamp = nil 
    }
    
    func consume() -> StoryData? {
        guard let data = storyJSON,
              let story = try? JSONDecoder().decode(StoryData.self, from: data) else {
            clear()
            return nil
        }
        clear()
        return story
    }
} 