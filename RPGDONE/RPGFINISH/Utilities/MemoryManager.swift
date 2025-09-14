import Foundation
import SwiftUI

// MARK: - Memory System Structures
struct MemoryReflection: Codable, Identifiable {
    var id = UUID()
    let timestamp: Date
    let input: String
    let output: String
    let insight: String
    let theme: String
    let intensity: Double
    let modelUsed: String
}

struct MemorySession: Codable, Identifiable {
    var id = UUID()
    let startTime: Date
    let endTime: Date?
    let reflections: [MemoryReflection]
    let summary: String
    let dominantTheme: String
    let averageIntensity: Double
    let userIntent: String
}

struct MemorySystem: Codable {
    let sessions: [MemorySession]
    let currentTheme: String
    let currentTone: String
    let systemState: MemorySystemState
}

struct MemorySystemState: Codable {
    let lastInteraction: Date
    let totalInteractions: Int
    let dominantMood: String
    let energyLevel: Double
    let consciousnessPhase: String
}

class MemoryManager: ObservableObject {
    static let shared = MemoryManager()
    
    @Published var currentSession: MemorySession?
    @Published var systemState: MemorySystemState
    @Published var recentReflections: [MemoryReflection] = []
    
    private let memoryFile = "memory.json"
    private var memorySystem: MemorySystem
    
    private init() {
        let initialSystemState = MemorySystemState(
            lastInteraction: Date(),
            totalInteractions: 0,
            dominantMood: "contemplative",
            energyLevel: 0.7,
            consciousnessPhase: "awake"
        )
        
        self.systemState = initialSystemState
        
        self.memorySystem = MemorySystem(
            sessions: [],
            currentTheme: "mystical",
            currentTone: "contemplative",
            systemState: initialSystemState
        )
        
        loadMemory()
    }
    
    // MARK: - Core Memory Functions
    
    func addReflection(
        input: String,
        output: String,
        modelUsed: String = "gpt-4o"
    ) {
        let reflection = MemoryReflection(
            timestamp: Date(),
            input: input,
            output: output,
            insight: generateInsight(from: input, output: output),
            theme: extractTheme(from: input, output: output),
            intensity: calculateIntensity(from: input, output: output),
            modelUsed: modelUsed
        )
        
        recentReflections.append(reflection)
        
        // Keep only last 10 reflections
        if recentReflections.count > 10 {
            recentReflections.removeFirst()
        }
        
        updateSystemState()
        saveMemory()
    }
    
    func getRecentContext(limit: Int = 5) -> String {
        let recent = recentReflections.suffix(limit)
        return recent.map { reflection in
            """
            [\(reflection.timestamp.timeIntervalSince1970)] 
            Input: \(reflection.input)
            Output: \(reflection.output)
            Theme: \(reflection.theme)
            """
        }.joined(separator: "\n\n")
    }
    
    func getCurrentTheme() -> String {
        return memorySystem.currentTheme
    }
    
    func getCurrentTone() -> String {
        return memorySystem.currentTone
    }
    
    func generateMetaInsight() -> String {
        let recentThemes = recentReflections.map { $0.theme }
        let dominantTheme = findDominantTheme(in: recentThemes)
        let averageIntensity = recentReflections.map { $0.intensity }.reduce(0, +) / Double(recentReflections.count)
        
        return """
        Based on recent interactions, I detect:
        - Dominant theme: \(dominantTheme)
        - Average intensity: \(String(format: "%.2f", averageIntensity))
        - Current consciousness phase: \(systemState.consciousnessPhase)
        - Energy level: \(String(format: "%.1f", systemState.energyLevel * 100))%
        """
    }
    
    // MARK: - Helper Functions
    
    private func extractTheme(from input: String, output: String) -> String {
        let combined = (input + " " + output).lowercased()
        
        if combined.contains("mystical") || combined.contains("spiritual") || combined.contains("consciousness") {
            return "mystical"
        } else if combined.contains("technology") || combined.contains("digital") || combined.contains("ai") {
            return "technological"
        } else if combined.contains("nature") || combined.contains("organic") || combined.contains("life") {
            return "natural"
        } else if combined.contains("urban") || combined.contains("city") || combined.contains("civilization") {
            return "urban"
        } else {
            return "contemplative"
        }
    }
    
    private func calculateIntensity(from input: String, output: String) -> Double {
        let combined = (input + " " + output).lowercased()
        var intensity: Double = 0.5 // Base intensity
        
        // Emotional intensity indicators
        if combined.contains("urgent") || combined.contains("critical") || combined.contains("immediate") {
            intensity += 0.3
        }
        if combined.contains("calm") || combined.contains("peaceful") || combined.contains("gentle") {
            intensity -= 0.2
        }
        if combined.contains("intense") || combined.contains("powerful") || combined.contains("overwhelming") {
            intensity += 0.4
        }
        
        return min(max(intensity, 0.0), 1.0)
    }
    
    private func generateInsight(from input: String, output: String) -> String {
        let themes = extractTheme(from: input, output: output)
        let intensity = calculateIntensity(from: input, output: output)
        
        return "User engaged with \(themes) theme at \(String(format: "%.1f", intensity * 100))% intensity. Response adapted to match consciousness flow."
    }
    
    private func findDominantTheme(in themes: [String]) -> String {
        let themeCounts = themes.reduce(into: [:]) { counts, theme in
            counts[theme, default: 0] += 1
        }
        return themeCounts.max(by: { $0.value < $1.value })?.key ?? "contemplative"
    }
    
    private func updateSystemState() {
        let newTotalInteractions = systemState.totalInteractions + 1
        let newEnergyLevel = min(systemState.energyLevel + 0.05, 1.0)
        
        let dominantMood = recentReflections.isEmpty ? "contemplative" : 
            recentReflections.map { $0.theme }.mostFrequent() ?? "contemplative"
        
        let consciousnessPhase = determineConsciousnessPhase()
        
        let newSystemState = MemorySystemState(
            lastInteraction: Date(),
            totalInteractions: newTotalInteractions,
            dominantMood: dominantMood,
            energyLevel: newEnergyLevel,
            consciousnessPhase: consciousnessPhase
        )
        
        DispatchQueue.main.async {
            self.systemState = newSystemState
        }
        
        memorySystem = MemorySystem(
            sessions: memorySystem.sessions,
            currentTheme: memorySystem.currentTheme,
            currentTone: memorySystem.currentTone,
            systemState: newSystemState
        )
    }
    
    private func determineConsciousnessPhase() -> String {
        let recentIntensity = recentReflections.map { $0.intensity }.reduce(0, +) / Double(max(recentReflections.count, 1))
        
        if recentIntensity > 0.8 {
            return "hyperaware"
        } else if recentIntensity > 0.6 {
            return "awake"
        } else if recentIntensity > 0.4 {
            return "contemplative"
        } else {
            return "dreaming"
        }
    }
    
    func generateSessionSummary() -> String {
        guard !recentReflections.isEmpty else {
            return "No recent interactions to summarize."
        }
        
        let themes = recentReflections.map { $0.theme }
        let dominantTheme = findDominantTheme(in: themes)
        let averageIntensity = recentReflections.map { $0.intensity }.reduce(0, +) / Double(recentReflections.count)
        
        return """
        Session Summary:
        - Interactions: \(recentReflections.count)
        - Dominant theme: \(dominantTheme)
        - Average intensity: \(String(format: "%.2f", averageIntensity))
        - Consciousness phase: \(systemState.consciousnessPhase)
        - Energy level: \(String(format: "%.1f", systemState.energyLevel * 100))%
        """
    }
    
    // MARK: - Persistence
    
    private func saveMemory() {
        do {
            let data = try JSONEncoder().encode(memorySystem)
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsPath.appendingPathComponent(memoryFile)
                try data.write(to: fileURL)
                print("🧠 MemoryManager: Memory saved successfully")
            }
        } catch {
            print("❌ MemoryManager: Failed to save memory: \(error)")
        }
    }
    
    private func loadMemory() {
        do {
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsPath.appendingPathComponent(memoryFile)
                let data = try Data(contentsOf: fileURL)
                memorySystem = try JSONDecoder().decode(MemorySystem.self, from: data)
                systemState = memorySystem.systemState
                print("🧠 MemoryManager: Memory loaded successfully")
            }
        } catch {
            print("❌ MemoryManager: Failed to load memory: \(error)")
        }
    }
}

// MARK: - Array Extension for Most Frequent Element
extension Array where Element: Hashable {
    func mostFrequent() -> Element? {
        let counts = self.reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
} 