import Foundation
import SwiftUI

@MainActor
final class StoryVM: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isThinking = false
    @Published var errorToast: String?
    @Published var currentInput: String = ""
    
    private let api = SignullAPI.shared
    
    func generateTapped() {
        Task {
            isThinking = true
            defer { isThinking = false }
            
            do {
                let input = currentInput
                currentInput = ""
                
                let scene = try await SignullAPI.generateStory(
                    prompt: input,
                    onPhase: { _ in },
                    onIntensity: { _ in }
                )
                var s = scene
                s.ensureTitle()
                messages.append(ChatMessage(scene: s, userInput: input))
            } catch {
                messages.append(ChatMessage(scene: nil, userInput: currentInput))
                errorToast = "The aether crackled. Try again?"
            }
        }
    }
}
