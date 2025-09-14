import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    var scene: StoryData?     // AI output
    var userInput: String?    // Your text for that turn
}
