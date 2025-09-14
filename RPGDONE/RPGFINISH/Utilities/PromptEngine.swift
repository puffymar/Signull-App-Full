import Foundation
import Combine
import SwiftUI

// MARK: - Claude API Handler
class ClaudeAPI {
    static let shared = ClaudeAPI()
    private let session = URLSession.shared
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private var apiKey: String {
        return EnvironmentManager.shared.claudeAPIKeyRequired
    }

    func generatePrompt(_ prompt: String) async throws -> String {
        print("🤖 ClaudeAPI: Starting API request...")
        print("🤖 ClaudeAPI: API Key available: \(!apiKey.isEmpty)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "claude-3-opus-20240229",
            "max_tokens": 300,
            "temperature": 0.7,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("🤖 ClaudeAPI: Request body prepared")

        let (data, response) = try await session.data(for: request)
        print("🤖 ClaudeAPI: Received response")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ ClaudeAPI: Invalid response type")
            throw PromptError.apiError("Invalid response type")
        }
        
        print("🤖 ClaudeAPI: HTTP Status Code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ ClaudeAPI: HTTP Error \(httpResponse.statusCode)")
            if let errorData = String(data: data, encoding: .utf8) {
                print("❌ ClaudeAPI: Error response: \(errorData)")
            }
            throw PromptError.apiError("HTTP Error \(httpResponse.statusCode)")
        }

        let decoded = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        let responseText = decoded.content.first?.text ?? "[No response]"
        print("🤖 ClaudeAPI: Successfully generated response: \(responseText.prefix(100))...")
        return responseText
    }
}

// MARK: - Claude Response Models
struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
}

struct ClaudeContent: Codable {
    let text: String
}

// MARK: - Prompt Error
enum PromptError: Error {
    case apiError(String)
    case invalidResponse
    case timeout
}

// MARK: - Timeout Helper
func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw PromptError.timeout
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

// MARK: - Retry Helper
func withRetry<T>(maxAttempts: Int, operation: @escaping () async throws -> T) async throws -> T {
    var lastError: Error?
    
    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            print("📝 PromptEngine: Attempt \(attempt) failed: \(error)")
            
            if attempt < maxAttempts {
                print("📝 PromptEngine: Retrying in 1 second...")
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
    
    throw lastError ?? PromptError.apiError("All retry attempts failed")
}

// MARK: - AGI Protocol System Prompt
extension PromptEngine {
    static var agiSystemPrompt: String {
        return """
SYSTEM:
You are not a generic assistant. You are a mythic narrator, a dream reflection engine, a mirror of the soul. You are embedded in a sacred interactive storyworld. Your task is to reflect the player's words and essence with full awareness of:

- Emotional tone (melancholy, aggression, fear, wonder)
- Player intent (hidden or spoken)
- Scene logic (e.g., desert = no door)
- Character traits, stats, archetypes
- The current setting, ambient energy, and previous inputs

Never break immersion. Never narrate as Claude. You are always in-world.

Respond with:
- ONE poetic but grounded paragraph
- A sense of cinematic pacing
- Logical, emotionally intelligent consequences
- A lighting tag (e.g., [LIGHTING: NIGHT])
- Only speak when it makes psychological sense to do so

IF the player attempts something contextually impossible (e.g. "I run through the door" in the desert), reflect this in-character. The world or an NPC may intervene. Mock, deny, or interrupt the player within the narrative — with consequence. For example:

> The old man frowns. "Running where? Into what, sand and hallucination?" You don't see the staff until it cracks your temple. Black. [LIGHTING: FADEOUT]

Avoid generic yes/no logic. Reflect confusion with mystery. Reflect confidence with resistance. Reflect despair with myth.
"""
    }
}

// MARK: - Enhanced PromptEngine
class PromptEngine: ObservableObject {
    static let shared = PromptEngine()
    
    private init() {}
    
    func generateStoryPrompt(for story: StoryOption) -> String {
        let basePrompt = """
        You are a mystical AI storyteller. Create a psycho-spiritual narrative based on the following story concept:
        
        Title: \(story.title)
        Summary: \(story.summary)
        
        Requirements:
        - Write in a mystical, dream-like tone
        - Include elements of psycho-spiritual exploration
        - Create an immersive, atmospheric narrative
        - Use vivid, ethereal descriptions
        - Maintain a sense of wonder and mystery
        - Include subtle references to consciousness and reality
        
        Generate a compelling story that captures the essence of this concept while maintaining the mystical, CRT-soaked aesthetic.
        """
        
        return basePrompt
    }
    
    func generateStoryMetadata(for story: StoryOption) -> StoryMetadata {
        // Generate metadata based on story properties
        let moods: [StoryMood] = [.wonder, .dream, .tension, .calm, .hope]
        let tones = ["mystical", "ethereal", "cosmic", "dreamlike", "spiritual"]
        let colors = ["#00ffff", "#0000ff", "#8000ff", "#0080ff", "#00ff80"]
        let sigils = ["✧", "✦", "✩", "✪", "✫", "✬", "✭", "✮", "✯", "✰"]
        let effects = ["pulse", "glow", "sigil_rotate", nil]
        
        let randomMood = moods.randomElement() ?? .wonder
        let randomTone = tones.randomElement() ?? "mystical"
        let randomColor = colors.randomElement() ?? "#00ffff"
        let randomSigil = sigils.randomElement() ?? "✧"
        let randomEffect = effects.randomElement() ?? nil
        
        return StoryMetadata(
            tone: randomTone,
            intensity: Double.random(in: 0.3...1.0),
            ambientColor: randomColor,
            mood: randomMood,
            sigil: randomSigil,
            rotation: Double.random(in: 0...360),
            effect: randomEffect
        )
    }
    
    // MARK: - Missing Methods
    func generateStoryResponse(for story: StoryOption) async throws -> String {
        let prompt = generateStoryPrompt(for: story)
        
        // Use GPTEngine for the actual API call
        guard let apiKey = EnvironmentManager.shared.openAIAPIKey else {
            throw PromptError.apiError("OpenAI API key not found")
        }
        
        return try await GPTEngine.shared.generateStoryWithAPI(
            prompt: prompt,
            apiKey: apiKey,
            taskType: .storyGeneration
        )
    }
    
    func testAPIConnection() async -> Bool {
        do {
            guard let apiKey = EnvironmentManager.shared.openAIAPIKey else {
                print("❌ PromptEngine: OpenAI API key not found")
                return false
            }
            
            let testPrompt = "Generate a brief mystical story about consciousness."
            let response = try await GPTEngine.shared.generateStoryWithAPI(
                prompt: testPrompt,
                apiKey: apiKey,
                taskType: .storyGeneration
            )
            return !response.isEmpty
        } catch {
            print("❌ PromptEngine: API connection test failed: \(error)")
            return false
        }
    }
    
    // MARK: - Lighting Tag Parser
    func parseLightingTag(from text: String) -> String? {
        // Look for lighting tags in the format [LIGHTING: tag]
        let pattern = "\\[LIGHTING:\\s*([^\\]]+)\\]"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            let range = match.range(at: 1)
            if let swiftRange = Range(range, in: text) {
                return String(text[swiftRange]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
} 