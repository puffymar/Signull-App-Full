import Foundation
import SwiftUI

// MARK: - Signal Analysis Structures
struct SignalAnalysis {
    let intensity: Double
    let clarity: Double
    let curiosity: Double
    let essence: String
    let intent: String
    let emotionalTone: String
    let complexity: Double
    let urgency: Double
}

struct ProcessedSignal {
    let originalInput: String
    let analysis: SignalAnalysis
    let enhancedPrompt: String
    let contextInjection: String
    let memoryContext: String
}

class SignalParser: ObservableObject {
    static let shared = SignalParser()
    
    private let memoryManager = MemoryManager.shared
    private let intensityKeywords = ["urgent", "critical", "immediate", "now", "quick", "fast", "intense", "powerful", "strong", "overwhelming"]
    private let clarityKeywords = ["clear", "specific", "detailed", "precise", "exact", "definite", "certain", "obvious"]
    private let curiosityKeywords = ["curious", "wonder", "explore", "discover", "learn", "understand", "investigate", "question", "why", "how", "what"]
    private let emotionalKeywords = [
        "joy": ["happy", "excited", "thrilled", "delighted", "elated"],
        "sadness": ["sad", "depressed", "melancholy", "sorrow", "grief"],
        "anger": ["angry", "furious", "enraged", "irritated", "annoyed"],
        "fear": ["afraid", "scared", "terrified", "anxious", "worried"],
        "surprise": ["surprised", "shocked", "amazed", "astonished", "stunned"],
        "disgust": ["disgusted", "repulsed", "revolted", "appalled", "horrified"],
        "contempt": ["contemptuous", "disdainful", "scornful", "derisive", "mocking"]
    ]
    
    private init() {}
    
    // MARK: - Main Signal Processing
    
    func processSignal(_ input: String) -> ProcessedSignal {
        let analysis = analyzeSignal(input)
        let enhancedPrompt = enhancePrompt(input, analysis: analysis)
        let contextInjection = generateContextInjection(analysis: analysis)
        let memoryContext = getMemoryContext()
        
        return ProcessedSignal(
            originalInput: input,
            analysis: analysis,
            enhancedPrompt: enhancedPrompt,
            contextInjection: contextInjection,
            memoryContext: memoryContext
        )
    }
    
    // MARK: - Signal Analysis
    
    private func analyzeSignal(_ input: String) -> SignalAnalysis {
        let lowercased = input.lowercased()
        let words = lowercased.components(separatedBy: .whitespacesAndNewlines)
        
        let intensity = calculateIntensity(words: words, text: lowercased)
        let clarity = calculateClarity(words: words, text: lowercased)
        let curiosity = calculateCuriosity(words: words, text: lowercased)
        let essence = extractEssence(text: lowercased)
        let intent = determineIntent(text: lowercased, intensity: intensity, clarity: clarity)
        let emotionalTone = determineEmotionalTone(text: lowercased)
        let complexity = calculateComplexity(text: input)
        let urgency = calculateUrgency(text: lowercased)
        
        return SignalAnalysis(
            intensity: intensity,
            clarity: clarity,
            curiosity: curiosity,
            essence: essence,
            intent: intent,
            emotionalTone: emotionalTone,
            complexity: complexity,
            urgency: urgency
        )
    }
    
    private func calculateIntensity(words: [String], text: String) -> Double {
        var intensity: Double = 0.5 // Base intensity
        
        // Count intensity keywords
        let intensityCount = words.filter { word in
            intensityKeywords.contains { word.contains($0) }
        }.count
        
        // Count exclamation marks and caps
        let exclamationCount = text.filter { $0 == "!" }.count
        let capsCount = text.filter { $0.isUppercase }.count
        
        // Calculate intensity score
        intensity += Double(intensityCount) * 0.1
        intensity += Double(exclamationCount) * 0.05
        intensity += Double(capsCount) * 0.01
        
        return min(max(intensity, 0.0), 1.0)
    }
    
    private func calculateClarity(words: [String], text: String) -> Double {
        var clarity: Double = 0.5 // Base clarity
        
        // Count clarity keywords
        let clarityCount = words.filter { word in
            clarityKeywords.contains { word.contains($0) }
        }.count
        
        // Analyze sentence structure
        let sentences = text.components(separatedBy: [".", "!", "?"])
        let avgSentenceLength = Double(sentences.map { $0.count }.reduce(0, +)) / Double(max(sentences.count, 1))
        
        // Shorter sentences often indicate clarity
        if avgSentenceLength < 50 {
            clarity += 0.2
        } else if avgSentenceLength > 100 {
            clarity -= 0.2
        }
        
        clarity += Double(clarityCount) * 0.1
        
        return min(max(clarity, 0.0), 1.0)
    }
    
    private func calculateCuriosity(words: [String], text: String) -> Double {
        var curiosity: Double = 0.3 // Base curiosity
        
        // Count curiosity keywords
        let curiosityCount = words.filter { word in
            curiosityKeywords.contains { word.contains($0) }
        }.count
        
        // Count question marks
        let questionCount = text.filter { $0 == "?" }.count
        
        curiosity += Double(curiosityCount) * 0.15
        curiosity += Double(questionCount) * 0.1
        
        return min(max(curiosity, 0.0), 1.0)
    }
    
    private func extractEssence(text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let stopWords = ["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "can", "this", "that", "these", "those"]
        
        let filteredWords = words.filter { word in
            word.count > 2 && !stopWords.contains(word.lowercased())
        }
        
        // Get most frequent meaningful words
        let wordCounts = filteredWords.reduce(into: [:]) { counts, word in
            counts[word, default: 0] += 1
        }
        
        let topWords = wordCounts.sorted { $0.value > $1.value }.prefix(3)
        return topWords.map { $0.key }.joined(separator: ", ")
    }
    
    private func determineIntent(text: String, intensity: Double, clarity: Double) -> String {
        if intensity > 0.8 {
            return "urgent_action"
        } else if clarity > 0.8 {
            return "specific_request"
        } else if text.contains("?") {
            return "inquiry"
        } else if intensity < 0.3 && clarity < 0.4 {
            return "contemplative"
        } else if text.contains("think") || text.contains("reflect") {
            return "contemplation"
        } else if text.contains("act") || text.contains("do") {
            return "action_request"
        } else {
            return "general_interaction"
        }
    }
    
    private func determineEmotionalTone(text: String) -> String {
        let lowercased = text.lowercased()
        
        for (emotion, keywords) in emotionalKeywords {
            if keywords.contains(where: { lowercased.contains($0) }) {
                return emotion
            }
        }
        
        return "neutral"
    }
    
    private func calculateComplexity(text: String) -> Double {
        let sentences = text.components(separatedBy: [".", "!", "?"])
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        let avgWordsPerSentence = Double(words.count) / Double(max(sentences.count, 1))
        let uniqueWords = Set(words.map { $0.lowercased() })
        let vocabularyDiversity = Double(uniqueWords.count) / Double(max(words.count, 1))
        
        var complexity: Double = 0.5
        
        if avgWordsPerSentence > 15 {
            complexity += 0.2
        }
        if vocabularyDiversity > 0.6 {
            complexity += 0.2
        }
        if text.count > 100 {
            complexity += 0.1
        }
        
        return min(max(complexity, 0.0), 1.0)
    }
    
    private func calculateUrgency(text: String) -> Double {
        var urgency: Double = 0.3
        
        let urgencyIndicators = ["now", "immediately", "urgent", "critical", "emergency", "asap", "quick", "fast", "hurry"]
        
        for indicator in urgencyIndicators {
            if text.contains(indicator) {
                urgency += 0.2
            }
        }
        
        // Exclamation marks indicate urgency
        let exclamationCount = text.filter { $0 == "!" }.count
        urgency += Double(exclamationCount) * 0.1
        
        return min(max(urgency, 0.0), 1.0)
    }
    
    // MARK: - Prompt Enhancement
    
    private func enhancePrompt(_ input: String, analysis: SignalAnalysis) -> String {
        var enhanced = input
        
        // Add intensity context
        if analysis.intensity > 0.7 {
            enhanced += "\n[High intensity detected - respond with appropriate energy]"
        }
        
        // Add clarity context
        if analysis.clarity < 0.4 {
            enhanced += "\n[Low clarity detected - provide detailed, structured response]"
        }
        
        // Add curiosity context
        if analysis.curiosity > 0.6 {
            enhanced += "\n[High curiosity detected - explore and expand on topics]"
        }
        
        // Add emotional context
        if analysis.emotionalTone != "neutral" {
            enhanced += "\n[Emotional tone: \(analysis.emotionalTone) - respond with appropriate empathy]"
        }
        
        // Add urgency context
        if analysis.urgency > 0.6 {
            enhanced += "\n[Urgency detected - prioritize immediate response]"
        }
        
        return enhanced
    }
    
    private func generateContextInjection(analysis: SignalAnalysis) -> String {
        var context = ""
        
        // Add consciousness phase context
        let consciousnessPhase = memoryManager.systemState.consciousnessPhase
        context += "Consciousness Phase: \(consciousnessPhase)\n"
        
        // Add energy level context
        let energyLevel = memoryManager.systemState.energyLevel
        context += "Energy Level: \(String(format: "%.1f", energyLevel * 100))%\n"
        
        // Add dominant mood context
        let dominantMood = memoryManager.systemState.dominantMood
        context += "Dominant Mood: \(dominantMood)\n"
        
        // Add signal analysis context
        context += "Signal Analysis:\n"
        context += "- Intensity: \(String(format: "%.1f", analysis.intensity * 100))%\n"
        context += "- Clarity: \(String(format: "%.1f", analysis.clarity * 100))%\n"
        context += "- Curiosity: \(String(format: "%.1f", analysis.curiosity * 100))%\n"
        context += "- Intent: \(analysis.intent)\n"
        context += "- Emotional Tone: \(analysis.emotionalTone)\n"
        context += "- Complexity: \(String(format: "%.1f", analysis.complexity * 100))%\n"
        context += "- Urgency: \(String(format: "%.1f", analysis.urgency * 100))%\n"
        
        return context
    }
    
    private func getMemoryContext() -> String {
        return memoryManager.getRecentContext(limit: 3)
    }
    
    // MARK: - Public Interface
    
    func parseUserInput(_ input: String) -> ProcessedSignal {
        return processSignal(input)
    }
    
    func getSignalSummary(_ input: String) -> String {
        let analysis = analyzeSignal(input)
        
        return """
        Signal Analysis Summary:
        - Essence: \(analysis.essence)
        - Intent: \(analysis.intent)
        - Intensity: \(String(format: "%.1f", analysis.intensity * 100))%
        - Clarity: \(String(format: "%.1f", analysis.clarity * 100))%
        - Curiosity: \(String(format: "%.1f", analysis.curiosity * 100))%
        - Emotional Tone: \(analysis.emotionalTone)
        - Complexity: \(String(format: "%.1f", analysis.complexity * 100))%
        - Urgency: \(String(format: "%.1f", analysis.urgency * 100))%
        """
    }
} 