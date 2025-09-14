import Foundation
import SwiftUI

class GPTEngine: ObservableObject {
    static let shared = GPTEngine()
    
    private let apiKey: String? = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    // 🎯 AI THINKING STATES FOR LIGHTING CONTROL
    @Published var isThinking: Bool = false
    @Published var thinkingIntensity: Double = 0.0
    @Published var thinkingPhase: String = "idle" // idle, thinking, generating, complete
    
    private init() {
        // Initialize with API key
        print("🤖 GPTEngine initialized with API key: \(apiKey?.prefix(20) ?? "Not found")...")
    }
    
    // MARK: - Claude + GPT Routing Logic
    enum TaskType {
        case story          // Use Claude for long-form AI stories
        case storyGeneration // Use GPT for story generation
        case dialogue       // Use GPT for character dialogue
        case system         // Use GPT for custom system instructions
        case stats          // Use GPT for stats integration
        case gameplay       // Use GPT for reactive gameplay moments
        case feedback       // Use GPT for button feedback
        case branching      // Use GPT for branching logic
    }
    
    // 🎯 THINKING STATE MANAGEMENT
    func startThinking() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isThinking = true
            thinkingPhase = "thinking"
            thinkingIntensity = 0.3
        }
        
        // Gradually increase intensity
        withAnimation(.easeInOut(duration: 2.0)) {
            thinkingIntensity = 0.7
        }
    }
    
    func startGenerating() {
        withAnimation(.easeInOut(duration: 0.3)) {
            thinkingPhase = "generating"
            thinkingIntensity = 1.0
        }
    }
    
    func completeThinking() {
        withAnimation(.easeInOut(duration: 0.8)) {
            thinkingPhase = "complete"
            thinkingIntensity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.isThinking = false
                self.thinkingPhase = "idle"
            }
        }
    }
    
    func generateStory(
        theme: String,
        playerStats: PlayerStats,
        activeAbilities: [Ability],
        taskType: TaskType = .story
    ) async -> String {
        // Start thinking state
        DispatchQueue.main.async {
            self.startThinking()
        }
        
        // Route to appropriate model based on task type
        let result: String
        switch taskType {
        case .story:
            // Use Claude for long-form stories
            result = await generateWithClaude(theme: theme, playerStats: playerStats, activeAbilities: activeAbilities)
        case .storyGeneration, .dialogue, .system, .stats, .gameplay, .feedback, .branching:
            // Use GPT for specific tasks
            result = await generateWithGPT(theme: theme, playerStats: playerStats, activeAbilities: activeAbilities, taskType: taskType)
        }
        
        // Complete thinking state
        DispatchQueue.main.async {
            self.completeThinking()
        }
        
        return result
    }
    
    // MARK: - Claude Generation (Long-form Stories)
    private func generateWithClaude(
        theme: String,
        playerStats: PlayerStats,
        activeAbilities: [Ability]
    ) async -> String {
        let promptEngine = PromptEngine.shared
        
        _ = [
            "Shadow Veil", "Echo Pulse", "Chromatic Shield", "Quantum Dash"
        ]
        _ = [
            "Blend into darkness to avoid detection.",
            "Emit a wave that reveals hidden paths.",
            "Project a shifting barrier of light.",
            "瞬間移動"
        ]
        
        // Note: Using PromptEngine for Claude generation instead of direct prompt
        
        do {
            // Create a temporary StoryOption for the prompt
            let tempStory = StoryOption(
                title: "Generated Story",
                summary: theme,
                fullStory: "",
                theme: "mystical"
            )
            let response = try await promptEngine.generateStoryResponse(for: tempStory)
            return response
        } catch {
            print("❌ GPTEngine: Claude generation failed: \(error)")
            return generateFallbackStory(theme: theme)
        }
    }
    
    // MARK: - GPT Generation (Specific Tasks)
    private func generateWithGPT(
        theme: String,
        playerStats: PlayerStats,
        activeAbilities: [Ability],
        taskType: TaskType
    ) async -> String {
        guard let apiKey = self.apiKey else {
            return generateFallbackResponse(for: taskType, theme: theme)
        }
        
        let prompt = buildTaskSpecificPrompt(theme: theme, playerStats: playerStats, activeAbilities: activeAbilities, taskType: taskType)
        
        do {
            let story = try await withTimeout(seconds: 15) { [self] in
                try await self.generateStoryWithAPI(prompt: prompt, apiKey: apiKey, taskType: taskType)
            }
            return story
        } catch {
            print("❌ GPTEngine: Error generating with GPT: \(error)")
            return generateFallbackResponse(for: taskType, theme: theme)
        }
    }
    
    private func buildTaskSpecificPrompt(
        theme: String,
        playerStats: PlayerStats,
        activeAbilities: [Ability],
        taskType: TaskType
    ) -> String {
        let abilityNames = activeAbilities.map { $0.displayName }.joined(separator: ", ")
        
        switch taskType {
        case .dialogue:
            return """
            You are generating character dialogue for a dark fantasy RPG. The player has these stats: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity).
            
            Theme: \(theme)
            Active Abilities: \(abilityNames)
            
            Generate 2-3 lines of atmospheric dialogue that reflects the player's stats and abilities. Make it feel natural and immersive.
            """
            
        case .system:
            return """
            You are generating custom system instructions for a dark fantasy RPG. The player is in a \(theme) setting with these stats: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity).
            
            Active Abilities: \(abilityNames)
            
            Generate a brief system instruction that guides the player's next action based on their current situation and abilities.
            """
            
        case .stats:
            return """
            You are integrating player stats into the narrative. The player has: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity).
            
            Theme: \(theme)
            Active Abilities: \(abilityNames)
            
            Generate a brief narrative moment that reflects how the player's stats affect their current situation.
            """
            
        case .gameplay:
            return """
            You are creating reactive gameplay moments for a dark fantasy RPG. The player is in a \(theme) setting with these stats: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity).
            
            Active Abilities: \(abilityNames)
            
            Generate a brief gameplay moment that responds to the player's current situation and abilities.
            """
            
        case .feedback:
            return """
            You are providing button feedback for a dark fantasy RPG. The player has these stats: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity).
            
            Theme: \(theme)
            Active Abilities: \(abilityNames)
            
            Generate a brief feedback message for a player action that reflects their stats and abilities.
            """
            
        case .branching:
            return """
            You are creating branching logic for a dark fantasy RPG. The player is in a \(theme) setting with these stats: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity).
            
            Active Abilities: \(abilityNames)
            
            Generate a brief narrative branch that offers the player a choice based on their current situation and abilities.
            """
            
        case .story:
            // This should not be called for GPT, but included for completeness
            return buildStoryPrompt(theme: theme, playerStats: playerStats, activeAbilities: activeAbilities)
            
        case .storyGeneration:
            return """
            You are generating a mystical story for a dark fantasy RPG. The player is in a \(theme) setting with these stats: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity).
            
            Active Abilities: \(abilityNames)
            
            Generate a mystical, atmospheric story that reflects the player's current situation and abilities.
            """
        }
    }
    
    func generateStoryWithAPI(prompt: String, apiKey: String, taskType: TaskType) async throws -> String {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = getSystemPrompt(for: taskType)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": getMaxTokens(for: taskType),
            "temperature": getTemperature(for: taskType),
            "top_p": 0.9
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GPTError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ GPTEngine: HTTP Error \(httpResponse.statusCode)")
            print("❌ GPTEngine: Error response: \(errorString)")
            throw GPTError.httpError(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw GPTError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func getSystemPrompt(for taskType: TaskType) -> String {
        switch taskType {
        case .dialogue:
            return "You are a character dialogue generator for a dark fantasy RPG. Create natural, atmospheric dialogue that reflects the player's stats and abilities."
        case .system:
            return "You are a system instruction generator for a dark fantasy RPG. Create brief, clear instructions that guide the player's next action."
        case .stats:
            return "You are a stats integration generator for a dark fantasy RPG. Create brief narrative moments that reflect how the player's stats affect their situation."
        case .gameplay:
            return "You are a reactive gameplay generator for a dark fantasy RPG. Create brief gameplay moments that respond to the player's current situation."
        case .feedback:
            return "You are a button feedback generator for a dark fantasy RPG. Create brief feedback messages for player actions."
        case .branching:
            return "You are a branching logic generator for a dark fantasy RPG. Create brief narrative branches that offer player choices."
        case .story:
            return "You are an atmospheric storyteller for a dark fantasy RPG. Create immersive, dreamlike narratives with dark fantasy elements and CRT/retro aesthetics."
        case .storyGeneration:
            return "You are a mystical AI storyteller creating psycho-spiritual narratives. Write in a mystical, dream-like tone with elements of psycho-spiritual exploration, vivid ethereal descriptions, and subtle references to consciousness and reality."
        }
    }
    
    private func getMaxTokens(for taskType: TaskType) -> Int {
        switch taskType {
        case .story, .storyGeneration:
            return 500
        case .dialogue, .system, .stats, .gameplay, .feedback, .branching:
            return 200
        }
    }
    
    private func getTemperature(for taskType: TaskType) -> Double {
        switch taskType {
        case .story, .storyGeneration:
            return 0.8
        case .dialogue:
            return 0.7
        case .system:
            return 0.5
        case .stats:
            return 0.6
        case .gameplay:
            return 0.7
        case .feedback:
            return 0.6
        case .branching:
            return 0.7
        }
    }
    
    private func generateFallbackResponse(for taskType: TaskType, theme: String) -> String {
        switch taskType {
        case .dialogue:
            return "The air whispers secrets only you can hear. Your abilities pulse with ancient power."
        case .system:
            return "Choose your path wisely. Your abilities may guide you to hidden truths."
        case .stats:
            return "Your stats reflect your journey. Each choice shapes your destiny."
        case .gameplay:
            return "The world responds to your presence. Your actions ripple through reality."
        case .feedback:
            return "Your choice echoes through the void. The path ahead awaits."
        case .branching:
            return "Two paths diverge before you. Each leads to different truths."
        case .story, .storyGeneration:
            return generateFallbackStory(theme: theme)
        }
    }
    
    // MARK: - Legacy Methods (for backward compatibility)
    private func buildStoryPrompt(
        theme: String,
        playerStats: PlayerStats,
        activeAbilities: [Ability]
    ) -> String {
        let abilityNames = activeAbilities.map { $0.displayName }.joined(separator: ", ")
        let abilityDescriptions = activeAbilities.map { $0.description }.joined(separator: "\n")
        
        return """
        You are an AI storyteller creating immersive, atmospheric narratives for a dark fantasy RPG called "Signull". 
        
        Theme: \(theme)
        Player Stats: Health \(playerStats.health), Magic \(playerStats.magic), Intelligence \(playerStats.intelligence), Charisma \(playerStats.charisma), Sanity \(playerStats.sanity)
        Active Abilities: \(abilityNames)
        Ability Effects: \(abilityDescriptions)
        
        Create a 2-3 paragraph story that:
        1. Immerses the player in the \(theme) setting
        2. Reflects their character stats and abilities
        3. Uses atmospheric, dreamlike prose with dark fantasy elements
        4. Ends with a choice or decision point
        5. Maintains the CRT/retro aesthetic tone
        
        Write in present tense, second person perspective. Be evocative and mysterious.
        """
    }
    
    private func generateFallbackStory(theme: String) -> String {
        let fallbackStories: [String: String] = [
            "desert": """
            The wasteland stretches before you like a forgotten dream. Dust devils dance across the cracked earth, carrying whispers of ancient civilizations that once thrived here. Your footsteps echo in the emptiness, each one a reminder of the choices that brought you to this desolate place.
            
            In the distance, a ruined tower pierces the horizon, its silhouette black against the setting sun. Something glints from its heights—perhaps a signal, or a trap. The wind carries the scent of something metallic, something that doesn't belong in this dead world.
            
            Your abilities pulse within you, ready to be unleashed. The wasteland awaits your decision: do you approach the tower and risk whatever lies within, or do you follow the ancient road that winds toward the mountains? The choice is yours, but remember—in this world, every decision echoes through reality itself.
            """,
            
            "forest": """
            Ancient trees loom overhead, their branches weaving a canopy that filters the moonlight into ethereal patterns on the forest floor. The air hums with a strange energy, as if the very essence of magic flows through every leaf and root. You can feel the forest breathing, watching, waiting.
            
            A path of glowing mushrooms leads deeper into the woods, while a clearing bathed in silver light offers a moment of respite. The trees seem to whisper secrets, their voices carried on the wind. Your abilities resonate with the forest's energy, creating harmonies that echo through the night.
            
            Do you follow the mushroom path into the heart of the forest, where ancient magic awaits? Or do you rest in the clearing and commune with the spirits that dwell here? The forest holds many secrets, and your choice will determine which ones are revealed to you.
            """,
            
            "city": """
            Neon lights flicker and pulse like the heartbeat of a dying machine. The city stretches endlessly upward, its towers piercing the perpetual twilight that hangs over this cyberpunk metropolis. Technology and humanity blur together in a dance of light and shadow, each street corner hiding a story waiting to be told.
            
            A holographic advertisement flickers to life, its message distorted by interference. In the distance, the sound of hovercraft engines echoes through the canyons of steel and glass. Your abilities interface with the city's systems, creating ripples in the digital fabric that surrounds you.
            
            Will you investigate the flickering advertisement and uncover the truth behind the city's artificial intelligence? Or do you follow the sound of the hovercrafts to the industrial district, where the real power in this city lies? The choice will determine your place in this digital dreamscape.
            """,
            
            "mountain": """
            The mountain looms before you like a sentinel of stone, its peak hidden in swirling clouds that seem to pulse with an otherworldly light. Each step upward brings you closer to answers, but the path is fraught with danger and discovery. The thin air carries whispers of ancient knowledge.
            
            A cave mouth yawns in the mountainside, its depths promising secrets and treasures beyond imagination. Above, a narrow path winds toward the summit, where the clouds themselves seem to gather in anticipation. Your abilities resonate with the mountain's ancient power, creating harmonies that echo through the stone.
            
            Do you enter the cave and explore the depths of the mountain's secrets? Or do you continue upward toward the summit, where the clouds themselves might reveal the truth about this world? The mountain holds the answers you seek, but the path you choose will determine what you discover.
            """,
            
            "temple": """
            Ancient stone rises from the earth like the bones of a forgotten god, its weathered surface covered in runes that pulse with a faint, otherworldly light. The temple stands as a testament to civilizations long dead, its halls echoing with the whispers of countless souls who came before you.
            
            A massive door stands partially open, revealing glimpses of treasures and horrors within. Above, a tower reaches toward the heavens, its windows glowing with an unnatural light. Your abilities resonate with the temple's ancient magic, creating harmonies that echo through the stone corridors.
            
            Do you enter the temple and face whatever lies within its sacred halls? Or do you climb the tower to commune with whatever power dwells at its heights? The temple holds the secrets of forgotten civilizations, and your choice will determine which secrets are revealed to you.
            """,
            
            "ocean": """
            The ocean stretches before you like a living dream, its surface reflecting the stars in patterns that seem to tell stories of their own. Beneath the waves lies a world of wonder and danger, where ancient creatures dwell in the depths and forgotten cities sleep beneath the surface.
            
            A shipwreck protrudes from the waves, its broken hull promising treasures and secrets from ages past. In the distance, an island rises from the sea, its shores bathed in an ethereal light that seems to pulse with its own rhythm. Your abilities resonate with the ocean's ancient power, creating harmonies that echo through the depths.
            
            Do you explore the shipwreck and uncover the secrets that lie within its broken halls? Or do you swim toward the island, where ancient magic awaits those brave enough to seek it? The ocean holds many mysteries, and your choice will determine which ones are revealed to you.
            """
        ]
        
        return fallbackStories[theme] ?? fallbackStories["desert"]!
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withTaskCancellationHandler {
            try await operation()
        } onCancel: {
            // Handle cancellation
        }
    }
}

// MARK: - GPT Error Types

enum GPTError: Error {
    case invalidResponse
    case httpError(Int)
    case networkError
    case timeout
} 