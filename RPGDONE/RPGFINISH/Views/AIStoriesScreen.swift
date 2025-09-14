import SwiftUI
import Foundation

// Coil loader removed (no large circle visuals)

// MARK: - SignullAssets
enum SignullAssets {
    static let schema: [String: Any] = {
        func log(_ s: String) {
            let fm = FileManager.default
            let docs = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let out = docs.appendingPathComponent("schema_load_log.txt")
            let line = (try? String(contentsOf: out)) ?? ""
            try? (line + s + "\n").write(to: out, atomically: true, encoding: .utf8)
        }

        let fm = FileManager.default
        var tried: [URL] = []

        // A) Normal lookup (case sensitive differs on APFS vs sim)
        if let u = Bundle.main.url(forResource: "SignullSchema", withExtension: "json"),
           let d = try? Data(contentsOf: u),
           let obj = try? JSONSerialization.jsonObject(with: d) as? [String:Any] {
            log("Loaded via Bundle.main.url: \(u.path)")
            return obj
        }

        // B) Brute-force search in bundle
        if let enumr = fm.enumerator(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil) {
            for case let u as URL in enumr where u.lastPathComponent.lowercased() == "signullschema.json" {
                tried.append(u)
                if let d = try? Data(contentsOf: u),
                   let obj = try? JSONSerialization.jsonObject(with: d) as? [String:Any] {
                    log("Loaded via brute-force path: \(u.path)")
                    return obj
                }
            }
        }

        // C) If you ever move it to a resource bundle, load that bundle explicitly
        if let rb = Bundle.main.urls(forResourcesWithExtension: "bundle", subdirectory: nil)?
            .first(where: { $0.lastPathComponent.contains("RPGFINISH") }),
           let resBundle = Bundle(url: rb),
           let u = resBundle.url(forResource: "SignullSchema", withExtension: "json"),
           let d = try? Data(contentsOf: u),
           let obj = try? JSONSerialization.jsonObject(with: d) as? [String:Any] {
            log("Loaded via nested bundle: \(u.path)")
            return obj
        }

        log("FAILED to load. Tried: \(tried.map{$0.path}.joined(separator: "; "))")
        return [:]
    }()
}

// MARK: - Temporary API (until files are added to Xcode project)
            struct AIChoice: Codable {
                let id, text, hint, consequence: String
            }
            
            // MARK: - Using external StoryUniqueness.swift

import AVFoundation

// Top-level safe extractor to ensure visibility across scopes
fileprivate func extractLeadingJSONAndAfter(from raw: String) -> ([String: Any], String)? {
    var depth = 0
    var start: String.Index? = nil
    var end: String.Index? = nil
    for i in raw.indices {
        let c = raw[i]
        if c == "{" { if depth == 0 { start = i }; depth += 1 }
        else if c == "}" { depth -= 1; if depth == 0 { end = i; break } }
    }
    guard let s = start, let e = end else { return nil }
    let jsonText = String(raw[s...e])
    guard let data = jsonText.data(using: .utf8),
          let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
    let tail = raw[raw.index(after: e)...].trimmingCharacters(in: .whitespacesAndNewlines)
    let afterLine = tail.split(separator: "\n").first(where: { $0.hasPrefix("AFTER:") })
    let after = afterLine.map { $0.replacingOccurrences(of: "AFTER:", with: "").trimmingCharacters(in: .whitespaces) } ?? ""
    return (obj, after)
}

// MARK: - Story Mood System (imported from StoryEnums.swift)

// MARK: - Lightweight Idea + ViewModel for selection-driven nav
struct Idea: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let hook: String
    let description: String
    let tags: [String]
}

enum StoriesPhase: Equatable {
    case idle
    case preparing(startedAt: Date)
    case generating(active: Int)
    case ready
    case error(String)
}

@MainActor
final class IdeasVM: ObservableObject {
    @Published private(set) var ideas: [Idea] = []
    @Published var phase: StoriesPhase = .idle
    @Published var progress: Double = 0.0
    private let defaultTargetCount = 3
    private var userBrief: String = ""

    private func desiredCount() -> Int {
        return userBrief.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? defaultTargetCount : 1
    }

    var skeletonCount: [Int] {
        let remaining = max(0, desiredCount() - ideas.count)
        return Array(0..<remaining)
    }
    func icon(for idea: Idea) -> String { "🌙" }
    func commitList() { /* persist if needed */ }

    func generateTriple(prompt: String? = nil) async {
        if let p = prompt { userBrief = p }
        ideas.removeAll()
        progress = 0
        phase = .generating(active: 0)
        let minShowUntil = Date()
        var collected: [Idea] = []
        let count = desiredCount()
        
        // Generate all cards in parallel
        await withTaskGroup(of: Idea?.self) { group in
            for i in 0..<count {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    let seed = await self.seed(for: i)
                    
                    // Try API first, then fallback
                    if let idea = try? await self.fetchIdeaViaResponses(seed: seed) {
                        return idea
                    }
                    
                    // Fallback to LiveAPI
                    if let idea = try? await self.fetchIdeaViaLiveAPI(seed: seed) {
                        return idea
                    }
                    
                    // Final fallback to hardcoded content
                    return await self.fallbackIdea(seed: seed)
                }
            }
            
            phase = .generating(active: count)
            
            for await maybe in group {
                if let idea = maybe {
                    // Ensure we don't have duplicate titles
                    if !collected.contains(where: { $0.title == idea.title }) {
                    collected.append(idea)
                    } else {
                        // If duplicate, create a variation
                        let variation = await self.createVariation(of: idea)
                        collected.append(variation)
                    }
                }
                progress = min(0.95, progress + 0.18)
                if case .generating(let a) = phase { 
                    phase = .generating(active: max(0, a-1)) 
            }
        }
        }
        
        let delay = max(0, minShowUntil.timeIntervalSinceNow)
        if delay > 0 { try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) }
        
        // Ensure we have exactly targetCount ideas
        while collected.count < count {
            let additionalSeed = seed(for: collected.count)
            let additionalIdea = fallbackIdea(seed: additionalSeed)
            collected.append(additionalIdea)
        }
        
        ideas = Array(collected.prefix(count))
        progress = 1.0
        try? await Task.sleep(nanoseconds: 240_000_000)
        phase = .ready
    }

    private func fetchIdeaViaLiveAPI(seed: String) async throws -> Idea? {
        guard let live = SignullAPI.shared.api as? LiveAPI else { return nil }
        
            do {
                let stub = try await live.generate(tier: .stub, timeoutSec: 10)
                let title = stub.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let hook = (stub.openingHook.isEmpty ? stub.summary : stub.openingHook)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            let description = stub.summary.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Ensure we have valid content
            guard !title.isEmpty, !hook.isEmpty, !description.isEmpty else { 
                return nil
            }
            
            print("✅ IdeasVM: Generated via LiveAPI → \(title)")
            let idea = alignedIdeaFrom(title: title, hook: String(hook.prefix(280)), description: String(description.prefix(500)), brief: userBrief)
            return idea
            } catch {
            print("❌ LiveAPI error: \(error)")
                return nil
            }
        }

    private static func generateTitleFallback(from text: String) -> String {
        return cleanTitle(text)
    }

    private static func cleanTitle(_ raw: String) -> String {
        // Replace separators with spaces
        var s = raw.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        // Remove digits
        s = s.replacingOccurrences(of: "[0-9]+", with: "", options: .regularExpression)
        // Keep only letters and spaces
        s = s.replacingOccurrences(of: "[^A-Za-z\\s]", with: "", options: .regularExpression)
        // Collapse whitespace and trim
        s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
        // Capitalize words and clamp length (2-5 words)
        let words = s.split(separator: " ").map { String($0).capitalized }
        let clamped = words.prefix(5)
        let title = clamped.joined(separator: " ")
        return title.isEmpty ? "Signal Story" : title
    }

    private static func cleanSnippet(_ raw: String) -> String {
        var s = raw.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        s = s.replacingOccurrences(of: "\\n+", with: " ", options: .regularExpression)
        s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return s
    }

    // Comprehensive guidance for the LLM (used across requests)
    private func llmGuide() -> String {
        return """
        GUIDE (follow strictly):
        - Always align to USER BRIEF; use its concrete nouns and actions. No boilerplate.
        - Output ONLY the requested JSON for idea generation; for scenes, output JSON per schema. After the JSON, add one single line starting with 'AFTER:' that advises the next beat. No extra prose before/after.
        - Title: 2–5 words, Title Case, not equal to the brief, no leading articles (A/The), no numbers/underscores/emoji. Prefer concrete nouns from the brief. Ban tokens: Echo, Midnight, Whispers, Veil, Dreamer, Bazaar, Strange Night.
        - Hook/Description: 1–2 sentences (28–60 words), second‑person vibe (you), not generic. Include at least two specific details from the brief. No meta, no vague phrases ("a strange night", "mysterious forces").
        - Scene Text: two short paragraphs (4–7 sentences total), first‑person present. Max 2 short dialogue lines with speaker names. ASCII only. Keep internal logic consistent. If the brief implies SCP, lean numbered Sites, intercoms, blast doors, card readers.
        - Player name usage: Address the player as [Name]. If a concrete name (Samson) is present in context, use Samson consistently; otherwise keep [Name].
        - Choices: 2–4 items; label is a specific action; hint is a subtle consequence. No spoilers, no generic verbs.
        - Never invent generic harbors/markets/villages unless the brief demands it.
        - Be original; avoid clichés. Never repeat the brief verbatim as the title.
        """
    }

    // Extract meaningful keywords from a brief for alignment and tags
    private func extractKeywords(from brief: String) -> [String] {
        let banned: Set<String> = ["the","and","a","an","of","to","in","on","at","with","for","from","that","this","these","those","night","strange","harbor","market","village","story","idea","prompt","write","about","make","scene","scenes","begin","begins"]
        return brief.lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count > 2 && !banned.contains($0) }
    }

    // Ensure idea content aligns with the brief; repair if generic
    private func alignedIdeaFrom(title rawTitle: String, hook rawHook: String, description rawDesc: String, brief: String) -> Idea {
        let kw = extractKeywords(from: brief)
        let title = Self.cleanTitle(rawTitle)
        let hook = Self.cleanSnippet(rawHook)
        let description = Self.cleanSnippet(rawDesc)
        func containsKW(_ s: String) -> Bool { kw.first(where: { s.lowercased().contains($0) }) != nil }
        var fixedTitle = title
        var fixedHook = hook
        var fixedDesc = description

        if !brief.isEmpty {
            if !containsKW(fixedTitle) {
                let titleWords = Array(kw.prefix(4)).map { String($0).capitalized }
                let candidate = titleWords.joined(separator: " ")
                if !candidate.isEmpty { fixedTitle = Self.cleanTitle(candidate) }
            }
            if !containsKW(fixedHook) {
                let a = kw.first.map { String($0) } ?? "signal"
                let b = kw.dropFirst().first.map { String($0) } ?? "room"
                fixedHook = "You move through \(a), keyed to \(b), the air tight with consequence."
            }
            if fixedDesc.count < 40 || !containsKW(fixedDesc) {
                let a = kw.first.map { String($0) } ?? "signal"
                let b = kw.dropFirst().first.map { String($0) } ?? "control"
                fixedDesc = "You act inside \(a) protocols while \(b) pressure climbs; specific details in the brief shape each step."
            }
        }

        let tags = generateTags(from: fixedTitle, hook: fixedHook, description: fixedDesc, brief: brief)
        return Idea(title: fixedTitle, hook: fixedHook, description: fixedDesc, tags: tags)
    }

    private func fetchIdeaViaResponses(seed: String) async throws -> Idea? {
        let base = SignullConfig.proxyURL
        let url = base.appendingPathComponent("v1/aistories/idea")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        SignullAuth.apply(to: &req)

        let brief = userBrief.trimmingCharacters(in: .whitespacesAndNewlines)
        let body: [String: Any] = [
            "seed": brief.isEmpty ? seed : brief
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await SignullClient.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else { return nil }
        guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let title = (dict["title"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let hook  = (dict["hook"]  as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, !hook.isEmpty else { return nil }
        let tags = generateTags(from: title, hook: hook, description: hook)
        return Idea(title: title, hook: String(hook.prefix(280)), description: hook, tags: tags)
    }

    private func createVariation(of idea: Idea) async -> Idea {
        let variations = [
            ("The Echo of \(idea.title)", "A reflection of the original story with new depths."),
            ("Beyond \(idea.title)", "What lies beyond the boundaries of the known."),
            ("The Shadow of \(idea.title)", "A darker version of the tale that haunts the edges."),
            ("\(idea.title) Reborn", "The story continues in unexpected ways.")
        ]
        
        let (newTitle, newDescription) = variations.randomElement()!
        let tags = generateTags(from: newTitle, hook: idea.hook, description: newDescription)
        
        return Idea(
            title: newTitle,
            hook: idea.hook,
            description: newDescription,
            tags: tags
        )
    }

    private func generateTags(from title: String, hook: String, description: String, brief: String? = nil) -> [String] {
        let text = (title + " " + hook + " " + description + " " + (brief ?? "")).lowercased()
        var tags: [String] = []
        
        // Energy tags
        if text.contains("dream") || text.contains("vision") { tags.append("mystical") }
        else if text.contains("clear") || text.contains("glass") || text.contains("mirror") { tags.append("lucid") }
        else if text.contains("storm") || text.contains("ashes") || text.contains("shadow") { tags.append("ominous") }
        else { tags.append("mystical") }
        
        // Theme tags
        if text.contains("harbor") || text.contains("sea") || text.contains("lighthouse") { tags.append("coastal") }
        else if text.contains("clock") || text.contains("glass") { tags.append("clockwork") }
        else if text.contains("market") || text.contains("station") { tags.append("market") }
        else { tags.append("etheric") }
        
        // Add brief-derived keywords as tags (top 2)
        let kws = extractKeywords(from: brief ?? "")
        tags.append(contentsOf: kws.prefix(2))
        return Array(Set(tags))
    }

    // MARK: - Safe extractor: leading JSON + trailing AFTER:
    private func extractLeadingJSONAndAfter(from raw: String) -> ([String: Any], String)? {
        var depth = 0
        var start: String.Index? = nil
        var end: String.Index? = nil
        for i in raw.indices {
            let c = raw[i]
            if c == "{" { if depth == 0 { start = i }; depth += 1 }
            else if c == "}" { depth -= 1; if depth == 0 { end = i; break } }
        }
        guard let s = start, let e = end else { return nil }
        let jsonText = String(raw[s...e])
        guard let data = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let tail = raw[raw.index(after: e)...].trimmingCharacters(in: .whitespacesAndNewlines)
        let afterLine = tail.split(separator: "\n").first(where: { $0.hasPrefix("AFTER:") })
        let after = afterLine.map { $0.replacingOccurrences(of: "AFTER:", with: "").trimmingCharacters(in: .whitespaces) } ?? ""
        return (obj, after)
    }

    // MARK: - Scene JSON validation & repair
    private func validateSceneDict(_ dict: [String: Any], brief: String) -> Bool {
        guard let text = dict["text"] as? String else { return false }
        if text.count < 300 { return false }
        let kws = extractKeywords(from: brief)
        if !kws.isEmpty {
            let lower = text.lowercased()
            let hasKW = kws.contains { lower.contains($0) }
            if !hasKW { return false }
        }
        return true
    }

    private func repairSceneIfNeeded(dict: [String: Any], brief: String) async -> [String: Any] {
        if validateSceneDict(dict, brief: brief) { return dict }
        var req = URLRequest(url: SignullConfig.proxyURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("RPGFINISH/1.0 (iOS; Simulator)", forHTTPHeaderField: "User-Agent")
        req.setValue("signull-ios", forHTTPHeaderField: "X-App-Client")
        SignullAuth.apply(to: &req)

        let fixPrompt = """
        FIX ONLY violations to pass the rubric; preserve valid parts.
        Return ONLY corrected JSON plus one AFTER line.

        USER BRIEF: \(brief)

        JSON TO REPAIR:
        \(dict)

        SCHEMA:
        \(LocalSchema.twoParaChoicesJSON)
        """
        let system = llmGuide()
        let body: [String: Any] = [
            "model": "gpt-5-mini-2025-08-07",
            "input": fixPrompt,
            "text": [
                "format": [
                    "type": "json_schema",
                    "json_schema": [
                        "name": "SignullScene",
                        "strict": true,
                        "schema": LocalSchema.twoParaChoicesJSON
                    ]
                ],
                "verbosity": "medium"
            ],
            "max_output_tokens": 600,
            "parallel_tool_calls": false,
            "messages": [
                ["role": "system", "content": system]
            ]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
        let (data, resp) = try await SignullClient.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else { return dict }
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let output = root["output"] as? [[String: Any]] else { return dict }
            let msg = output.first(where: { ($0["type"] as? String) == "message" }) ?? output.last
            if let content = msg?["content"] as? [[String: Any]] {
        if let jsonItem = content.first(where: { ($0["type"] as? String) == "output_json" }),
                   let repaired = jsonItem["json"] as? [String: Any] {
                    return repaired
                }
        if let textItem = content.first(where: { ($0["type"] as? String) == "output_text" }),
                   let raw = textItem["text"] as? String,
                   let (repaired, _) = extractLeadingJSONAndAfter(from: raw) {
                    return repaired
                }
            }
        } catch {}
        return dict
    }

    private func fallbackIdea(seed: String) -> Idea {
        // No hardcoded fallback; create a minimal placeholder only if API fails entirely
        let title = Self.generateTitleFallback(from: seed)
        return Idea(title: title, hook: "You stand where signals cross.", description: "Threads of a scene form around your request.", tags: ["mystical"]) 
    }

    private func seed(for i: Int) -> String {
        let base = ["Blackout","Aftershock","Neon Bazaar","Safehouse","Orbital","Cathedral","Underpass","Relay","Vault","Grid"]
        let t = Int(Date().timeIntervalSince1970) % 1000
        return "\(base[i % base.count])_\(t)_\(i)"
    }
}

// MARK: - Story Metadata System (imported from StoryEnums.swift)

struct AIStoriesScreen: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var audioManager = AudioManager.shared
    

    @Environment(\.dismiss) private var dismiss
    
    @State private var storyOptions: [StoryOption] = []
    @State private var stories: [StoryOption] = []
    @State private var isLoading: Bool = true
    @State private var isGeneratingBatch: Bool = false // coalesce guard
    @State private var selectedStory: StoryOption?
    @State private var showStoryView: Bool = false
    @State private var isGeneratingStory: Bool = false
    @State private var currentStoryImage: String = ""
    @State private var storyTheme: String = ""
    @State private var generatedStory: StoryData?
    @State private var isNavigatingToStory: Bool = false
    @State private var userPrompt: String = ""
    
    // Progression and Prewarming
    @StateObject private var progression = Progression.shared
    @StateObject private var prewarmStore = PrewarmStore.shared
    @StateObject private var worldStore = WorldStore.shared

    
    // 🎯 ENHANCED LOADING STATES
    @State private var gearRotation: Double = 0.0
    @State private var gearOpacity: Double = 0.0
    @State private var pageOffset: CGFloat = 100.0 // Start down, move up
    @State private var pageOpacity: Double = 0.0
    @State private var loadingComplete: Bool = false
    @State private var loadingProgress: Double = 0.0
    
    // 🤖 AI THINKING STATES (simplified for now)
    @State private var isThinking: Bool = false
    @State private var thinkingIntensity: Double = 0.0
    @State private var thinkingPhase: String = "idle"
    
    // CRT Rainbow States
    @State private var scanlineOffset: CGFloat = 0
    @State private var breathingSun: Double = 0.0
    @State private var sunRotation: Double = 0.0
    @State private var rainbowHue: Double = 0.0
    @State private var metastaticField: Double = 0.0
    @State private var aiThinking: Bool = false
    @State private var glowIntensity: Double = 0.0
    
    // 🧬 UNIFIED ENVIRONMENTAL CONTROL
    @State private var ambientColor: Color = .black
    @State private var storyIntensity: CGFloat = 0.0
    @State private var moodTone: StoryMood = .neutral
    @State private var backgroundPulse: Bool = true
    @State private var activeSigil: String?
    @State private var sigilRotation: Double = 0.0
    @State private var currentMetadata: StoryMetadata?
    
    // 🔮 PSYCHO-SPIRITUAL UPGRADES
    @State private var crtBloom: Double = 0.0
    @State private var chromaticAberration: Double = 0.0
    @State private var mysticalAura: Double = 0.0
    @State private var storyCardGlow: Double = 0.0
    @State private var sigilPulse: Double = 0.0
    @State private var ambientPulse: Double = 0.0
    
    // 🎯 OPTIMIZED SCANLINE STATES
    @State private var scanlinePulse: Double = 0.0
    @State private var scanlineIntensity: Double = 0.0
    @State private var promptSweepX: CGFloat = -120
    @State private var hueAngle: Double = 0.0
    
    // 🌙 ENHANCED DREAM BUTTON STATES
    @State private var dreamButtonGlow: Double = 0.0
    @State private var dreamButtonPulse: Double = 0.0
    @State private var dreamButtonRotation: Double = 0.0
    
    // 🎯 INITIATE BUTTON STATE
    @State private var showInitiateButton: Bool = false
    
    // 🌙 ICON ASSIGNMENT SYSTEM
    @State private var assignedIcons: [String: String] = [:]
    @State private var usedIcons: Set<String> = []
    @State private var availableIcons: [String] = []
    @State private var didAssignIcons = false
    

    
    // Using SignullAPI for all story generation via Cloudflare Worker proxy
    @StateObject private var ideasVM = IdeasVM()
    @State private var selectedIdea: Idea? = nil
    @State private var goPlay: Bool = false
    @State private var isDreamGenerating: Bool = false
    @State private var generatedInitial: String? = nil
    
    // 🧠 INTERFACE LOOP - Apply metadata to update environment
    func applyMetadata(_ metadata: StoryMetadata) {
        withAnimation(.easeInOut(duration: 1.0)) {
            self.ambientColor = Color.black // Default color since hex conversion isn't available
            self.moodTone = metadata.mood
            self.storyIntensity = CGFloat(metadata.intensity)
            self.activeSigil = metadata.sigil
            self.sigilRotation = metadata.rotation
            self.currentMetadata = metadata
        }
        
        // 🕯️ REACTIVE EVENT TRIGGERS
        if let effect = metadata.effect {
            handleReactiveEffect(effect, intensity: metadata.intensity)
        }
        
        print("🎭 Applied metadata: \(metadata.mood.rawValue), intensity: \(metadata.intensity), sigil: \(metadata.sigil), effect: \(metadata.effect ?? "none")")
    }
    
    private func handleReactiveEffect(_ effect: String, intensity: Double) {
        switch effect {
        case "pulse":
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                ambientPulse = 1.0
            }
        case "glow":
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                storyCardGlow = 1.0
            }
        case "sigil_rotate":
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: false)) {
                sigilRotation = 360.0
            }
        default:
            break
        }
    }
    
    var body: some View {
        NavigationStack {
        ZStack {
                backgroundView
                mainContentView
            }
            .onAppear {
            // Test bundle loading immediately
            print("🔍 DEBUG: Testing bundle loading on app appear...")
            let testURL = Bundle.main.url(forResource: "SignullSchema", withExtension: "json")
            print("🔍 DEBUG: Bundle.main.url result: \(testURL?.absoluteString ?? "nil")")
            
            if let url = testURL {
                print("🔍 DEBUG: File exists at: \(url)")
                if let data = try? Data(contentsOf: url) {
                    print("🔍 DEBUG: File size: \(data.count) bytes")
                } else {
                    print("🔍 DEBUG: Failed to read data from file")
                }
            } else {
                print("🔍 DEBUG: File not found in bundle")
                print("🔍 DEBUG: Bundle path: \(Bundle.main.bundlePath)")
                print("🔍 DEBUG: Available JSON files:")
                if let resources = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
                    for resource in resources {
                        print("  - \(resource.lastPathComponent)")
                    }
                } else {
                    print("  - No JSON files found")
                }
            }
            
            // Start ambient music for AI stories
            if !audioManager.isPlaying {
                audioManager.playAmbientMusic()
            }
            
            // Daily progression check
            progression.dailyClaimIfNeeded()
            
            // Reset states
            isLoading = false
            showInitiateButton = false
            selectedStory = nil
            loadingProgress = 0.0
            pageOffset = 100.0
            pageOpacity = 0.0
            
            startCRTRainbowAnimation()
            startPsychoSpiritualEffects()
            startOptimizedScanlines()
            
            // Prewarm the API with a test call
            do {
                let api = SignullAPI.shared
                let _ = try api.schemaJSON()
                // Note: prewarmSeed method doesn't exist, so we'll skip this for now
                print("🔍 DEBUG: Schema loaded successfully")
            } catch {
                print("🔍 DEBUG: Failed to load schema: \(error)")
            }
            startEnhancedDreamButtonEffects()
            // Do not auto-generate; wait for user brief submission
            // Ensure the grid slides in and becomes visible
            withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                self.pageOffset = 0.0
                self.pageOpacity = 1.0
            }
            }
            .navigationDestination(isPresented: $goPlay) {
                let fallback: String = {
                    guard let idea = selectedIdea else { return "" }
                    return "\(idea.title)\n\n\(idea.description)"
                }()
                StoryView(initialStory: generatedInitial ?? fallback)
                    .environmentObject(gameState)
            }
            .onChange(of: ideasVM.ideas.count) { _, count in
                if count > 0 {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.pageOffset = 0.0
                        self.pageOpacity = 1.0
                    }
                }
            }
        }
        .sheet(isPresented: $gameState.showingSettings) {
            SettingsView()
        }
    }

    // MARK: - Factored Views to reduce compile complexity
    private var backgroundView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            // Removed large radial glows to eliminate the big circle
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.height / 3), id: \.self) { index in
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cyan.opacity(0.05 + (scanlinePulse * 0.02)))
                            .offset(x: scanlineOffset + CGFloat(index % 3) * 1.5)
                            .opacity(0.3 + (scanlineIntensity * 0.2))
                    }
                }
                .offset(y: -100)
                .clipped()
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true), value: scanlineOffset)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: scanlinePulse)
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: scanlineIntensity)
            
            // Suppress mystical aura pulse
        }
    }
            
    private var mainContentView: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                backButtonSection
                aiPortalHeaderSection
                    .offset(y: -60)
                // User prompt input bar
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                accentBase(for: moodTone).opacity(0.9),
                                                Color.purple.opacity(0.9),
                                                Color.blue.opacity(0.9),
                                                Color.cyan.opacity(0.9),
                                                accentBase(for: moodTone).opacity(0.9)
                                            ]),
                                            center: .center,
                                            angle: .degrees(hueAngle)
                                        ), lineWidth: 1.4
                                    )
                                    .animation(.linear(duration: 6.0).repeatForever(autoreverses: false), value: hueAngle)
                            )
                            // Remove gray mask; use subtle scanlines only
                            .overlay(
                                GeometryReader { geo in
                                    Canvas { ctx, size in
                                        for y in stride(from: 0.0, to: size.height, by: 4.0) {
                                            ctx.stroke(
                                                Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                                                with: .color(Color.white.opacity(0.08))
                                            )
                                        }
                                    }
                                }
                            )
                            // Removed center sweep shimmer to eliminate gray loading band
                        
                        TextField("What story do you want generated? (e.g., SCP-Δ lab breach)", text: $userPrompt)
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                            .tint(.cyan)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .submitLabel(.go)
                            .onSubmit { Task { await triggerPromptedIdeas() } }
                    }
                    .frame(height: 36)
                    
                    Button(action: { Task { await triggerPromptedIdeas() } }) {
                        Image(systemName: "paperplane.fill").font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(.cyan.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
                .offset(y: -42)
                Spacer(minLength: 20)
                ideaGridView
                    .offset(y: -40)
                    .offset(y: pageOffset)
                        .opacity(pageOpacity)
                Spacer(minLength: 25)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            
            simpleDreamButton
            
            // Removed top preparing overlay – show content without blocking HUD
            
            VStack {
                HStack {
                    DailyBadge()
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                Spacer()
            }
        }
    }
    
    // 🎯 SIMPLIFIED LOADING VIEW
    private var enhancedLoadingView: some View { EmptyView() }
    
    // 🌙 ENHANCED DREAM BUTTON EFFECTS
    private func startEnhancedDreamButtonEffects() {
        // Dream button glow
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            dreamButtonGlow = 1.0
        }
        
        // Dream button pulse
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            dreamButtonPulse = 1.0
        }
        
        // Dream button rotation
        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: false)) {
            dreamButtonRotation = 360.0
        }
    }
    
    // 🎯 SIMPLIFIED LOADING WITH PROGRESS
    private func loadStoryOptionsWithAnimation() {
        isLoading = true
        showInitiateButton = false // Reset initiate button state
        loadingProgress = 0.0
        
        // Initialize icon system
        initializeIconSystem()
        
        // Simulate progress updates
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if loadingProgress < 0.9 {
                withAnimation(.easeInOut(duration: 0.1)) {
                    loadingProgress += 0.05
                }
            } else {
                timer.invalidate()
            }
        }
        
        // Generate stories using ChatGPT API
        Task {
            await generateStoriesWithChatGPT()
            DispatchQueue.main.async {
                // Complete loading
                withAnimation(.easeInOut(duration: 0.3)) {
                    loadingProgress = 1.0
                }
                
                // Hide loading after brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isLoading = false
                        self.loadingComplete = true
                    }
                    
                    // Animate page sliding up with motion blur effect
                    withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                        self.pageOffset = 0.0
                        self.pageOpacity = 1.0
                    }
                }
            }
        }
    }
    
    // 🌙 INITIALIZE ICON SYSTEM
    private func initializeIconSystem() {
        availableIcons = getAllMysticalIcons()
        usedIcons.removeAll()
        assignedIcons.removeAll()
        print("🎯 Initialized icon system with \(availableIcons.count) icons")
    }
    
    // 🔮 PSYCHO-SPIRITUAL EFFECTS
    private func startPsychoSpiritualEffects() {
        // CRT Bloom and Chromatic Aberration
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            crtBloom = 1.0
            chromaticAberration = 1.0
        }
        
        // Mystical Aura
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            mysticalAura = 1.0
        }
    }
    
    // 🎯 OPTIMIZED SCANLINE EFFECTS
    private func startOptimizedScanlines() {
        // Asymmetric pulse with different timing
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            scanlinePulse = 1.0
        }
        
        // Scanline intensity with offset timing
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) {
            scanlineIntensity = 1.0
        }
        
        // Subtle horizontal movement
        withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
            scanlineOffset = 2.0
        }
    }
    
    // MARK: - BACK BUTTON AND HOME Section
    private var backButtonSection: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    gameState.showingAIStories = false
                    gameState.showingMainMenu = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                    Text("Home")
                        .font(.custom("SF Mono", size: 12).weight(.medium))
                }
                .foregroundColor(Color.cyan.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 0.5)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Settings button
            Button(action: {
                HapticManager.shared.impact(.light)
                gameState.showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.cyan.opacity(0.8))
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 0.5)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    // MARK: - AI PORTAL HEADER Section
    private var aiPortalHeaderSection: some View {
        VStack(spacing: 12) {
            // AI Thinking Indicator
            ZStack {
                // Rainbow CRT essence field
                rainbowEssenceField
                
                // AI Core with thinking animation
                aiCore
                
                // Thinking indicator
                if aiThinking {
                    thinkingIndicator
                }
            }
            .padding(.top, -400) // Push icon up to -400
            
            // Cyan-themed title
            Text("AI STORIES")
                .font(.custom("SF Mono", size: 18).weight(.bold))
                .foregroundColor(Color.cyan)
                .tracking(2)
                .shadow(color: Color.cyan.opacity(0.6), radius: 2, x: 0, y: 1)
        }
        .padding(.top, 25)
        .padding(.bottom, 15)
    }
    
    // MARK: - STORY SELECTION Area (ENHANCED)
    private var storySelectionArea: some View {
        VStack(spacing: 15) {
            ForEach(stories, id: \.id) { story in
                enhancedMysticalStoryCard(for: story)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Idea Grid (Rail System with Enhanced Spacing)
    private var ideaGridView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("AI STORIES")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.cyan)
                Spacer()
                Button { Task { await triggerPromptedIdeas() } } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered).tint(.blue.opacity(0.25))
            }
            .padding(.horizontal, 20)
            
            // Rail System - Horizontal scrolling segments
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(ideasVM.ideas) { idea in
                        StoryCard(
                            title: idea.title,
                            hook: idea.description,
                            tags: idea.tags,
                            isSelected: (selectedIdea == idea)
                        )
                        .frame(width: 280, height: 200)
                        .onTapGesture { selectedIdea = idea }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .frame(height: 220)
            
            // Bottom spacing for Dream button
            Spacer(minLength: 20)
        }
    }

    // MARK: - Idea Grid Components
    private struct IdeaCard: View {
        let idea: Idea
        var isSelected: Bool
        let icon: String
        let onSelect: () -> Void
        var body: some View {
            Button(action: onSelect) {
                VStack(spacing: 0) {
                    // Cinematic header with subtle texture and moon
                    ZStack(alignment: .topLeading) {
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.22), Color.blue.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        // Subtle scanline theme overlay
                        .overlay(
                            VStack(spacing: 0) {
                                ForEach(0..<36, id: \.self) { idx in
                                    Rectangle()
                                        .fill(Color.white.opacity(idx % 3 == 0 ? 0.06 : 0.02))
                                        .frame(height: 1)
                                    Spacer(minLength: 2)
                                }
                            }.padding(.vertical, 6)
                        )
                        .overlay(
                            AngularGradient(gradient: Gradient(colors: [
                                .white.opacity(0.04), .clear, .white.opacity(0.03), .clear
                            ]), center: .center)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                        Text(icon)
                            .font(.system(size: 40))
                            .padding(10)
                            .shadow(color: .black.opacity(0.45), radius: 6, y: 4)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)

                    // Lower content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(idea.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(idea.hook)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(3)
                            .minimumScaleFactor(0.9)
                        HStack(spacing: 8) {
                            TagPill(text: energyLabel(), color: .purple)
                            TagPill(text: themeLabel(), color: .cyan)
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(12)
                }
                .frame(height: 230)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(colors: [
                                        .white.opacity(isSelected ? 0.55 : 0.18),
                                        .white.opacity(0.08)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .shadow(color: Color.cyan.opacity(isSelected ? 0.35 : 0.18), radius: isSelected ? 14 : 8, y: 8)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .scaleEffect(isSelected ? 1.02 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isSelected)
            }
            .buttonStyle(.plain)
        }
        
        // Local heuristics for tags
        private func energyLabel() -> String {
            let text = (idea.title + " " + idea.hook).lowercased()
            if text.contains("dream") || text.contains("vision") { return "mystical" }
            if text.contains("clear") || text.contains("glass") || text.contains("mirror") { return "lucid" }
            if text.contains("storm") || text.contains("ashes") || text.contains("shadow") { return "ominous" }
            return "mystical"
        }
        
        private func themeLabel() -> String {
            let text = (idea.title + " " + idea.hook).lowercased()
            if text.contains("harbor") || text.contains("sea") || text.contains("lighthouse") { return "coastal" }
            if text.contains("clock") || text.contains("glass") { return "clockwork" }
            if text.contains("market") || text.contains("station") { return "market" }
            return "etheric"
        }
    }

    // MARK: - LLM Guidance (scoped to AIStoriesScreen)
    private func llmGuide() -> String {
        """
        GUIDE (follow strictly):
        - Align to USER BRIEF; use its concrete nouns/actions. No boilerplate.
        - JSON-first output. After JSON, add one line prefixed `AFTER:` with a 1-sentence tip.
        - Title: 2–5 Title-Case words; not equal to brief; no leading articles; no numbers/underscores/emoji; avoid Echo/Midnight/Whispers/Veil/Dreamer/Bazaar/Strange Night.
        - Description/Hook: 1–2 sentences (28–60 words), second-person vibe; include ≥2 concrete details from brief; ASCII only.
        - Scene text: two short paragraphs (4–7 sentences total), first-person present; ≤2 short dialogue lines with speaker names; keep internal logic.
        - If SCP implied: numbered Sites, intercoms, blast doors, card readers, labs; modern tone.
        - Player name: use [Name]; if Samson present, use Samson consistently.
        - Choices: 2–4 items; label = specific action; hint = subtle consequence; no spoilers.
        """
    }

    // MARK: - Full-scene initial generator via strict proxy
    private func generateInitialSceneFromIdea(_ idea: Idea) async -> String {
        let base = SignullConfig.proxyURL
        let url = base.appendingPathComponent("v1/aistories/opening")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        SignullAuth.apply(to: &req)

        let brief = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let body: [String: Any] = [
            "brief": brief.isEmpty ? idea.hook : brief,
            "context_hints": ""
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, resp) = try await SignullClient.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, http.statusCode == 200,
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let title = dict["title"] as? String,
                  let text = dict["text"] as? String else {
                let fallbackTitle = idea.title.isEmpty ? "Mysterious Tale" : idea.title
                let fallbackContent = idea.hook.isEmpty ? idea.description : idea.hook
                return "\(fallbackTitle)\n\n\(fallbackContent)"
            }
            return "\(title)\n\n\(text)"
        } catch {
            let fallbackTitle = idea.title.isEmpty ? "Mysterious Tale" : idea.title
            let fallbackContent = idea.hook.isEmpty ? idea.description : idea.hook
            return "\(fallbackTitle)\n\n\(fallbackContent)"
        }
    }

    private struct TagPill: View {
        let text: String
        let color: Color
        var body: some View {
            Text(text)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.18))
                .foregroundColor(color)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
        }
    }



    private struct SkeletonCard: View {
        var body: some View {
            VStack(spacing: 0) {
                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 120)
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.15)).frame(height: 16)
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.10)).frame(height: 12)
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.10)).frame(height: 12)
                    HStack { Spacer(); RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.2)).frame(width: 80, height: 30) }
                }
                .padding(12)
            }
            .frame(height: 220)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .redacted(reason: .placeholder)
        }
    }

    // MARK: - Scan Progress Bar (inline to ensure target linkage)
    private struct ScanProgressBar: View {
        var progress: Double
        @State private var sweepX: CGFloat = -120
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                GeometryReader { geo in
                    let w = max(0, min(geo.size.width, geo.size.width * progress))
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.35), Color.blue.opacity(0.35)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: w)
                        .mask(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.45), .clear],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: 90, height: geo.size.height - 4)
                                .offset(x: sweepX)
                                .blur(radius: 2)
                                .blendMode(.screen)
                                .allowsHitTesting(false),
                            alignment: .leading
                        )
                        .onAppear {
                            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                                sweepX = geo.size.width + 120
                            }
                        }
                }
                .padding(2)
            }
            .frame(height: 16)
            .shadow(color: Color.cyan.opacity(0.25), radius: 8, y: 2)
        }
    }

    // MARK: - Enhanced Mystical Story Card
    private struct StoryCard: View {
        let title: String
        let hook: String
        let tags: [String]
        var isSelected: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.cyan)
                Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    .lineLimit(2)
                }
                Text(hook)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
                HStack(spacing: 6) {
                    ForEach(tags.prefix(3), id: \.self) { t in
                        Text(t)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.06), in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                    Spacer()
                }
            }
            .padding(16)
            .frame(width: 280, height: 200)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [.white.opacity(0.06), .white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
                .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.cyan.opacity(0.5) : Color.white.opacity(0.10), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: (isSelected ? Color.cyan : Color.black).opacity(isSelected ? 0.35 : 0.5), radius: isSelected ? 18 : 10, y: isSelected ? 8 : 4)
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: isSelected)
        }
    }

    private struct ScanLines: View {
        @State private var phase: CGFloat = 0
        var body: some View {
            GeometryReader { geo in
                let h = geo.size.height
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white.opacity(0.08), location: 0.0),
                        .init(color: .clear, location: 0.5),
                        .init(color: .white.opacity(0.08), location: 1.0)
                    ]),
                    startPoint: .top, endPoint: .bottom
                )
                .mask(
                    Canvas { ctx, size in
                        for y in stride(from: phase.truncatingRemainder(dividingBy: 6), to: h, by: 6) {
                            ctx.stroke(
                                Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                                with: .color(.white),
                                lineWidth: 1
                            )
                        }
                    }
                )
                .onAppear {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        phase = 6
                    }
                }
            }
        }
    }
    private struct HeaderBar: View {
        let loadingCount: Int
        let totalNeeded: Int
        var body: some View {
            HStack {
                Spacer()
                Text("AI STORIES")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.cyan)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }

    private struct DreamSetupViewCompat: View {
        let idea: Idea
        @EnvironmentObject var gameState: GameState
        @State private var isLoading = true
        @State private var error: String?
        @State private var bodyText: String = ""
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(idea.title).font(.title2.bold())
                    Text(idea.hook).foregroundStyle(.secondary)
                    if isLoading { ProgressView("Spinning up dream…") }
                    if let error { Text(error).foregroundStyle(.red) }
                    if !bodyText.isEmpty { Text(bodyText) }
                }.padding(16)
            }
            .task {
                bodyText = idea.hook
                isLoading = false
            }
        }
    }
    
    private func enhancedMysticalStoryCard(for story: StoryOption) -> some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            selectedStory = story
            withAnimation(.easeInOut(duration: 0.5)) {
                showInitiateButton = true
            }
        }) {
            enhancedMysticalStoryCardContent(for: story)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(story.unavailable)
    }
    
    private func enhancedMysticalStoryCardContent(for story: StoryOption) -> some View {
        ZStack {
            enhancedMysticalStoryCardBackground(for: story)
            enhancedMysticalStoryCardScanlines()
            enhancedMysticalStoryCardInnerContent(for: story)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selectedStory?.title == story.title ? Color.cyan.opacity(0.8) : Color.cyan, lineWidth: selectedStory?.title == story.title ? 2 : 1)
        )
        .shadow(color: Color.cyan.opacity(selectedStory?.title == story.title ? 0.8 : 0.6), radius: selectedStory?.title == story.title ? 8 : 6)
        .shadow(color: Color.cyan.opacity(storyCardGlow * 0.4), radius: 12)
        .scaleEffect(getStoryCardScale(for: story))
        .opacity(story.unavailable ? 0.5 : (story.risk ? 0.7 : 1.0))
    }
    
    // 🎯 VARYING STORY CARD SIZES
    private func getStoryCardScale(for story: StoryOption) -> CGFloat {
        if story.weight > 0.9 {
            return 1.08 // Largest cards for highest weight stories
        } else if story.weight > 0.7 {
            return 1.05 // Medium-large for high weight
        } else if story.weight > 0.5 {
            return 1.02 // Slightly larger for medium weight
        } else if story.weight > 0.3 {
            return 0.98 // Slightly smaller for low weight
        } else {
            return 0.95 // Smallest for lowest weight
        }
    }
    
    private func enhancedMysticalStoryCardBackground(for story: StoryOption) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.9),
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(enhancedCyanGradient, lineWidth: 2)
            )
    }
    
    private var enhancedCyanGradient: LinearGradient {
        let cyan = Color.cyan.opacity(0.7)
        let blue = Color.blue.opacity(0.5)
        let purple = Color.purple.opacity(0.4)
        let cyan2 = Color.cyan.opacity(0.5)
        
        let colors = [cyan, blue, purple, cyan2, cyan]
        return LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var enhancedScanlineGradient: LinearGradient {
        let cyan = Color.cyan.opacity(0.04)
        let blue = Color.blue.opacity(0.04)
        let purple = Color.purple.opacity(0.04)
        let clear = Color.clear
        
        let colors = [cyan, blue, purple, clear]
        return LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private func enhancedScanlineRow(for line: Int) -> some View {
        Rectangle()
            .fill(enhancedScanlineGradient)
            .frame(height: 1)
            .offset(y: CGFloat(line * 3) + scanlineOffset)
            .opacity(0.5)
    }
    
    private func enhancedMysticalStoryCardScanlines() -> some View {
        VStack(spacing: 0) {
            ForEach(0..<20, id: \.self) { line in
                enhancedScanlineRow(for: line)
            }
        }
        .clipped()
    }
    
    private func enhancedMysticalStoryCardInnerContent(for story: StoryOption) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 🌙 ENHANCED MYSTICAL SIGIL ICON
                enhancedMysticalSigilIcon(for: story)
                
                VStack(alignment: .leading, spacing: 6) {
                                                        Text(story.title.isEmpty || story.title.localizedCaseInsensitiveContains("untitled")
                                         ? TitleForge.synth(openingHook: nil, theme: story.theme, setting: nil)
                                         : story.title)
                        .font(.custom("SF Mono", size: 16).weight(.bold))
                        .foregroundColor(story.unavailable ? .gray : Color.cyan)
                        .tracking(1)
                        .shadow(color: story.unavailable ? .gray.opacity(0.6) : Color.cyan.opacity(0.8), radius: 3)
                    
                    if !story.summary.isEmpty {
                        Text(story.summary)
                            .font(.custom("SF Mono", size: 12).weight(.medium))
                            .foregroundColor(story.unavailable ? .gray.opacity(0.8) : .white.opacity(0.9))
                            .lineLimit(3)
                            .shadow(color: story.unavailable ? .gray.opacity(0.3) : .white.opacity(0.4), radius: 1)
                    }
                }
                
                Spacer()
                
                // Enhanced weight indicator
                if story.weight > 0.8 {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.cyan)
                        .shadow(color: Color.cyan.opacity(0.7), radius: 2)
                }
                
                // Enhanced risk indicator
                if story.risk {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.7), radius: 2)
                }
                
                // Enhanced cyan arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(story.unavailable ? .gray : Color.cyan)
                    .shadow(color: story.unavailable ? .gray.opacity(0.5) : Color.cyan.opacity(0.7), radius: 3)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // 🌙 ENHANCED MYSTICAL SIGIL ICON WITH VARIED REALISTIC ICONS
    private func enhancedMysticalSigilIcon(for story: StoryOption) -> some View {
        ZStack {
            // Enhanced sigil background with glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.cyan.opacity(0.4),
                            Color.blue.opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .scaleEffect(1.0 + (sigilPulse * 0.15))
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: sigilPulse)
            
            // Enhanced sigil symbol with varied realistic icons
            Text(enhancedSigilSymbol(for: story))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.cyan)
                .rotationEffect(.degrees(sigilRotation))
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: false), value: sigilRotation)
                .shadow(color: Color.cyan.opacity(0.6), radius: 2)
        }
    }
    
    private func enhancedSigilSymbol(for story: StoryOption) -> String {
        // Pure, deterministic pick based on title hash to avoid state mutation during render
        let icons = getAllMysticalIcons()
        guard !icons.isEmpty else { return "🌙" }
        let idx = abs(story.title.hashValue) % icons.count
        return icons[idx]
    }
    
    // 🌙 COMPREHENSIVE MYSTICAL ICON SYSTEM (30 UNIQUE ICONS)
    private func getAllMysticalIcons() -> [String] {
        return [
            "🌙", "⭐", "✨", "🌟", "💫", "🌠", "⚡", "🔥", "💎", "🔮",
            "🌌", "🌊", "🌪️", "⚔️", "🛡️", "🏹", "🗡️", "⚜️", "🎭", "🎪",
            "🌺", "🌹", "🌸", "🌼", "🌻", "🌷", "🌱", "🌿", "🍃", "🌾"
        ]
    }
    
    // 🎯 ENHANCED DREAM BUTTON (at bottom of screen)
    private var simpleDreamButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    HapticManager.shared.impact(.heavy)
                    // If no selection, pick the first idea
                    if selectedIdea == nil, let first = ideasVM.ideas.first { selectedIdea = first }
                    guard let idea = selectedIdea else { return }
                    // Immediate fallback text and navigation via global route to avoid any nav blockage
                    let fallbackTitle = idea.title.isEmpty ? "Mysterious Tale" : idea.title
                    let fallbackContent = idea.hook.isEmpty ? idea.description : idea.hook
                    let initial = "\(fallbackTitle)\n\n\(fallbackContent)"
                    let option = StoryOption(title: fallbackTitle, summary: idea.description, fullStory: initial, theme: "mystical")
                    gameState.selectedStory = option
                    gameState.showingAIStories = false
                    gameState.showingStoryView = true
                    // Generate richer scene in background and update when ready
                    isDreamGenerating = true
                    Task {
                        let generated = await generateInitialSceneFromIdea(idea)
                        await MainActor.run {
                            if var current = gameState.selectedStory {
                                current.fullStory = generated
                                gameState.selectedStory = current
                            }
                            self.generatedInitial = generated
                            self.isDreamGenerating = false
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.cyan)
                            .shadow(color: Color.cyan.opacity(0.6), radius: 2)
                        Text("Dream")
                            .font(.custom("SF Mono", size: 14).weight(.medium))
                            .foregroundColor(Color.cyan)
                            .shadow(color: Color.cyan.opacity(0.6), radius: 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.cyan.opacity(0.6),
                                                Color.blue.opacity(0.4),
                                                Color.cyan.opacity(0.6)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    )
                    .shadow(color: Color.cyan.opacity(0.4), radius: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Prompt-triggered idea generation
    private func triggerPromptedIdeas() async {
        await ideasVM.generateTriple(prompt: userPrompt)
    }
    
    // MARK: - AI Portal Components
    private var rainbowEssenceField: some View {
        Group {
            rainbowLayer0
            rainbowLayer1
            rainbowLayer2
            rainbowLayer3
        }
    }
    
    private func rainbowLayerGradient(opacity: Double) -> AngularGradient {
        let baseOpacity = opacity
        let cyan = Color.cyan.opacity(baseOpacity)
        let blue = Color.blue.opacity(baseOpacity - 0.05)
        let purple = Color.purple.opacity(baseOpacity - 0.1)
        let cyan2 = Color.cyan.opacity(baseOpacity - 0.15)
        
        let colors = [cyan, blue, purple, cyan2, cyan]
        return AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center
        )
    }
    
    private var rainbowLayer0: some View {
        Circle()
            .stroke(rainbowLayerGradient(opacity: 0.3), lineWidth: 1.0)
            .frame(width: 45, height: 45)
            .rotationEffect(.degrees(sunRotation * 0.3))
            .scaleEffect(1.0 + breathingSun * 0.1)
            .blur(radius: 1.5)
            .opacity(0.7)
    }
    
    private var rainbowLayer1: some View {
        Circle()
            .stroke(rainbowLayerGradient(opacity: 0.3), lineWidth: 1.5)
            .frame(width: 57, height: 57)
            .rotationEffect(.degrees(sunRotation * 0.3 + 15))
            .scaleEffect(1.0 + breathingSun * 0.1 + 0.02)
            .blur(radius: 3.0)
            .opacity(0.5)
    }
    
    private var rainbowLayer2: some View {
        Circle()
            .stroke(rainbowLayerGradient(opacity: 0.3), lineWidth: 2.0)
            .frame(width: 69, height: 69)
            .rotationEffect(.degrees(sunRotation * 0.3 + 30))
            .scaleEffect(1.0 + breathingSun * 0.1 + 0.04)
            .blur(radius: 4.5)
            .opacity(0.4)
    }
    
    private var rainbowLayer3: some View {
        Circle()
            .stroke(rainbowLayerGradient(opacity: 0.3), lineWidth: 2.5)
            .frame(width: 81, height: 81)
            .rotationEffect(.degrees(sunRotation * 0.3 + 45))
            .scaleEffect(1.0 + breathingSun * 0.1 + 0.06)
            .blur(radius: 6.0)
            .opacity(0.25)
    }
    
    private func coreEnergyGradient() -> RadialGradient {
        let white = Color.white.opacity(0.8)
        let cyan = Color.cyan.opacity(0.6)
        let blue = Color.blue.opacity(0.4)
        let purple = Color.purple.opacity(0.3)
        let cyan2 = Color.cyan.opacity(0.2)
        let clear = Color.clear
        
        let colors = [white, cyan, blue, purple, cyan2, clear]
        return RadialGradient(
            colors: colors,
            center: .center,
            startRadius: 0,
            endRadius: 25
        )
    }
    
    private var aiCore: some View {
        ZStack {
            // Core energy field
            Circle()
                .fill(coreEnergyGradient())
                .frame(width: 50, height: 50)
                .scaleEffect(1.0 + breathingSun * 0.2)
                .blur(radius: 2.0)
                .opacity(0.8)
            
            // Inner core
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 30, height: 30)
                .scaleEffect(1.0 + breathingSun * 0.1)
                .blur(radius: 1.0)
                .opacity(0.9)
            
            // AI symbol
            Text("AI")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.black)
                .opacity(0.8)
        }
    }
    
    private var thinkingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.cyan)
                    .frame(width: 4, height: 4)
                    .scaleEffect(aiThinking ? 1.2 : 0.8)
                    .opacity(aiThinking ? 1.0 : 0.5)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: aiThinking)
            }
        }
        .offset(y: 35)
    }
    
    // MARK: - ANIMATION FUNCTIONS
    private func startCRTRainbowAnimation() {
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            breathingSun = 1.0
        }
        
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: false)) {
            sunRotation = 360.0
        }
        
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            rainbowHue = 1.0
        }
        
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            metastaticField = 1.0
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            aiThinking = true
        }
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
        
        // Start sigil pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            sigilPulse = 1.0
        }
    }
    
    // MARK: - STORY LOADING WITH CHATGPT INTEGRATION
    private func loadStoryOptions() {
        guard !isGeneratingBatch else { return }
        isGeneratingBatch = true
        isLoading = true
        
        // Generate stories using ChatGPT API
        Task {
            await generateStoriesWithChatGPT()
            await MainActor.run {
                self.isLoading = false
                self.isGeneratingBatch = false
            }
        }
    }
    
    @MainActor
    private func generateStoriesWithChatGPT() async {
        print("🔍 DEBUG: Starting optimized story generation...")
        Telemetry.logStoryStart()
        
        // Start AI thinking state
        thinkingPhase = "thinking"
        thinkingIntensity = 0.3
        
        Task.detached(priority: .userInitiated) {
            let limit = 3 // parallel limit
            var results: [StoryOption] = []
            results.reserveCapacity(6)
            
            try await withThrowingTaskGroup(of: StoryOption?.self) { group in
                var inFlight = 0
                var queued = 0
                
                func enqueue() {
                    guard queued < 6 else { return }
                    let currentQueued = queued
                    queued += 1; inFlight += 1
                    group.addTask {
                        await withTaskCancellationHandler(operation: {
                            do {
                                // Quick stub (fast)
                                let api = SignullAPI.shared.api as! LiveAPI
                                let stub = try await api.generate(tier: .stub, timeoutSec: 8)
                                var mutableStub = stub
                                mutableStub.ensureTitle()
                                
                                // Capture values before async operations
                                let stubTitle = mutableStub.title
                                let stubTheme = mutableStub.theme
                                
                                // Show stub immediately on main thread
                                await MainActor.run {
                    let storyOption = StoryOption(
                                        title: stubTitle,
                                        summary: "Generating...",
                                        fullStory: "Generating full story...",
                                        theme: stubTheme,
                                        weight: Double.random(in: 0.3...1.0),
                                        risk: stubTheme.contains("apocalypse") || stubTheme.contains("void"),
                        unavailable: false
                    )
                                    self.stories.append(storyOption)
                                }
                                
                                // Start full in parallel
                                async let full = api.generate(tier: .full, timeoutSec: 22)
                                let scene = try await full
                                var mutableScene = scene
                                mutableScene.ensureTitle()
                                
                                let storyOption = StoryOption(
                                    title: scene.title,
                                    summary: scene.summary,
                                    fullStory: scene.fullStory,
                                    theme: scene.theme,
                                    weight: Double.random(in: 0.3...1.0),
                                    risk: scene.theme.contains("apocalypse") || scene.theme.contains("void"),
                                    unavailable: false
                                )
                                
                                // Replace stub with full story
                                await MainActor.run {
                                    var updatedStories = self.stories
                                    for (index, story) in updatedStories.enumerated() {
                                        if story.title == stubTitle {
                                            updatedStories[index] = storyOption
                                            break
                                        }
                                    }
                                    self.stories = updatedStories
                                }
                                
                                return storyOption
            } catch {
                                print("🔍 DEBUG: Story generation failed: \(error)")
                                // Append a visible fallback so UI advances
                                await MainActor.run {
                                    let fallback = self.createFallbackStory(index: currentQueued)
                                    self.stories.append(fallback)
                                }
                                return nil
                            }
                        }, onCancel: {
                            // Handle cancellation if needed
                        })
                    }
                }
                
                for _ in 0..<min(limit, 6) { enqueue() }
                
                for try await story in group {
                    if let s = story { results.append(s) }
                    inFlight -= 1
                    if queued < 6 { enqueue() }
                }
            }
            await MainActor.run {
                if self.stories.isEmpty {
                    // Ensure at least one card so UI advances
                    self.stories.append(self.createFallbackStory(index: 0))
                }
                self.isLoading = false
            self.thinkingPhase = "complete"
                self.thinkingIntensity = 1.0
            }
        }
    }
    
    // Generate fallback story with simulated delay
    private func generateFallbackStory(index: Int) async -> StoryOption {
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        return createFallbackStory(index: index)
    }
    
    // Timeout wrapper for async operations
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    struct TimeoutError: Error {}
    
    // Helper function to call ChatGPT API
    private func callChatGPT(prompt: String) async throws -> String {
        print("🔍 DEBUG: Making API call to ChatGPT...")
        
        // For now, use a fallback approach to avoid API key exposure
        // TODO: Implement secure proxy as suggested
        return try await generateFallbackStoryContent()
    }
    
    // Temporary fallback story generator (until we implement secure proxy)
    private func generateFallbackStoryContent() async throws -> String {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let fallbackStories = [
            """
            {
                "title": "The Quantum Mirror",
                "summary": "A mysterious artifact that reflects not just light, but time itself.",
                "fullStory": "You stand before an ancient mirror, its surface shimmering with otherworldly energy. The glass doesn't reflect your image—instead, it shows fragments of moments that never were, possibilities that dance just beyond reach. The air around you crackles with temporal distortion as you reach out to touch its surface. What secrets does this mirror hold?",
                "theme": "mystical",
                "weight": 0.8,
                "risk": true
            }
            """,
            """
            {
                "title": "Echoes of Tomorrow",
                "summary": "Fragments of a future that never was, scattered across reality.",
                "fullStory": "The wind carries whispers of what might have been. You find yourself in a place where time has fractured, where echoes of futures that never came to pass drift through the air like autumn leaves. Each step you take sends ripples through the fabric of possibility, and you begin to understand that your choices here will reshape not just your own destiny, but the very nature of reality itself.",
                "theme": "mystical",
                "weight": 0.7,
                "risk": false
            }
            """,
            """
            {
                "title": "The Last Dreamer",
                "summary": "The final dreamer holds the key to humanity's salvation.",
                "fullStory": "In a world where dreams have become scarce commodities, you are the last true dreamer. Your mind holds the power to weave new realities, to create hope where none exists. But with this power comes a terrible responsibility—the fate of all who have forgotten how to dream rests in your hands. The shadows are gathering, and they hunger for the light of imagination.",
                "theme": "mystical",
                "weight": 0.9,
                "risk": true
            }
            """,
            """
            {
                "title": "Beyond the Veil",
                "summary": "A thin barrier separates our world from infinite possibilities.",
                "fullStory": "The veil between worlds is thinner here than anywhere else. You can feel the presence of other realms pressing against the fabric of reality, their inhabitants watching, waiting. Some seek to help, others to harm, but all are drawn to the power that flows through this place. You must choose whether to strengthen the barrier or tear it down completely.",
                "theme": "mystical",
                "weight": 0.6,
                "risk": false
            }
            """,
            """
            {
                "title": "The Memory Collector",
                "summary": "Memories are currency in a world where time is the ultimate luxury.",
                "fullStory": "You are a collector of memories, trading in the most precious commodity of all—time itself. Each memory you gather holds power, but at what cost? The more you collect, the more you begin to lose yourself in the echoes of others' lives. Soon you must decide whether to continue your collection or risk everything to forge your own path.",
                "theme": "mystical",
                "weight": 0.75,
                "risk": true
            }
            """,
            """
            {
                "title": "Whispers in the Void",
                "summary": "Ancient voices speak of truths that challenge everything we know.",
                "fullStory": "The void speaks to you in whispers that carry the weight of forgotten ages. These voices tell of truths so profound they could shatter the foundations of reality itself. But knowledge comes at a price—the more you listen, the more you begin to question everything you thought you knew. The void offers power beyond imagination, but demands your sanity in return.",
                "theme": "mystical",
                "weight": 0.85,
                "risk": true
            }
            """
        ]
        
        // Return a random story from the fallback list
        return fallbackStories.randomElement() ?? fallbackStories[0]
    }
    
    // Helper function to parse story response
    private func parseStoryResponse(_ response: String) -> StoryData? {
        // Try to extract JSON from the response
        let jsonStart = response.firstIndex(of: "{")
        let jsonEnd = response.lastIndex(of: "}")
        
        guard let start = jsonStart, let end = jsonEnd else { return nil }
        let jsonString = String(response[start...end])
        
        do {
            let data = jsonString.data(using: .utf8)!
            let storyData = try JSONDecoder().decode(StoryData.self, from: data)
            return storyData
        } catch {
            print("🔍 DEBUG: Failed to parse story response: \(error)")
            return nil
        }
    }
    
    // Fallback story creation
    private func createFallbackStory(index: Int) -> StoryOption {
        let fallbackTitles = [
            "The Quantum Mirror",
            "Echoes of Tomorrow", 
            "The Last Dreamer",
            "Beyond the Veil",
            "The Memory Collector",
            "Whispers in the Void"
        ]
        
        let fallbackSummaries = [
            "A mysterious artifact that reflects not just light, but time itself.",
            "Fragments of a future that never was, scattered across reality.",
            "The final dreamer holds the key to humanity's salvation.",
            "A thin barrier separates our world from infinite possibilities.",
            "Memories are currency in a world where time is the ultimate luxury.",
            "Ancient voices speak of truths that challenge everything we know."
        ]
        
        let title = fallbackTitles[index % fallbackTitles.count]
        let summary = fallbackSummaries[index % fallbackSummaries.count]
        
        return StoryOption(
            title: title,
            summary: summary,
            fullStory: "This is the beginning of \(title). \(summary) The story unfolds with mystical elements and psychological depth, exploring the boundaries between reality and imagination...",
            theme: "mystical",
            weight: Double.random(in: 0.3...1.0),
            risk: Bool.random(),
            unavailable: false
        )
    }
    
    // Old StoryData removed - using the one defined at top of file
    
    // Generate a story when Dream button is clicked
    private func generateStoryForDream() async {
        print("🔍 DEBUG: Attempting live API call for dream story...")
        
        // Health check first
        let isHealthy = await SignullAPI.shared.healthCheck()
        if !isHealthy {
            print("🔴 HEALTH CHECK FAILED - Using fallback")
            useFallback()
            return
        }
        
        // Health probe for debugging
        Task {
            do {
                let data = try await SignullAPI.shared.api.generate(prompt: "ping", systemPrompt: "You are a test system. Respond with 'pong'.", temperature: 1.0, presencePenalty: 0.0)
                print("✅ Health probe OK (\(data.count) bytes)")
            } catch {
                print("❌ Health probe FAIL: \(error)")
            }
        }
        
        // Manual API test button (debug only)
        // Button("🔧 Test API") {
        //     Task {
        //         await testAPI()
        //     }
        // }
        
        do {
            // Use PromptComposer to generate proper prompt
            let composer = PromptComposer()
            let seed = composer.nextSeed(.rotate)
            let ws = worldStore.state
            let npcs = worldStore.npcs
            let userPrompt = composer.storyUserPrompt(seed: seed, ws: ws, npcs: npcs)
            
            print("🔍 DEBUG: Generated prompt: \(userPrompt)")
            
            let storyData = try await SignullAPI.generateStory(
                prompt: userPrompt, // Use the generated user prompt
                onPhase: { phase in
                    DispatchQueue.main.async {
                        self.thinkingPhase = phase
                    }
                },
                onIntensity: { intensity in
                    DispatchQueue.main.async {
                        self.thinkingIntensity = intensity
                    }
                }
            )
            
            DispatchQueue.main.async {
                self.generatedStory = storyData
                self.showStoryView = true
            }
            
        } catch let err as SignullAPIError {
            print("🔴 LIVE API ERROR -> \(err)")
            useFallback()
        } catch {
            print("🔴 LIVE API ERROR -> \(error)")
            useFallback()
        }
    }
    
    // Test API function for debugging
    private func testAPI() async {
        print("🔧 TESTING API...")
        
        // Test 1: Health check
        let isHealthy = await SignullAPI.shared.healthCheck()
        print("🔧 Health check result: \(isHealthy)")
        
        // Test 2: Auth methods test
        // Test auth methods if we have a LiveAPI instance
        if let liveAPI = SignullAPI.shared.api as? LiveAPI {
            await liveAPI.testAuthMethods()
        } else {
            print("⚠️ Cannot test auth methods - not using LiveAPI")
        }
        
        // Test 3: Simple ping
        do {
            let data = try await SignullAPI.shared.api.generate(prompt: "ping", systemPrompt: "You are a test system. Respond with 'pong'.", temperature: 1.0, presencePenalty: 0.0)
            print("🔧 Ping test OK: \(data.count) bytes")
            if let response = String(data: data, encoding: .utf8) {
                print("🔧 Response: \(response)")
            }
        } catch {
            print("🔧 Ping test FAILED: \(error)")
        }
        
        // Test 4: Schema validation
        do {
            let schema = try SignullAPI.shared.schemaJSON()
            print("🔧 Schema loaded: \(schema.count) keys")
        } catch {
            print("🔧 Schema test FAILED: \(error)")
        }
    }
    
    // Fallback story generation
    private func runFallbackStoryGeneration() async {
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        DispatchQueue.main.async {
            self.thinkingPhase = "generating"
            self.thinkingIntensity = 0.8
        }
        
        // Create a fallback dream story
        let fallbackDreamStory = StoryOption(
            title: "The Dreamweaver's Loom",
            summary: "A mysterious weaver creates dreams from threads of possibility.",
            fullStory: "You find yourself in a vast chamber where dreams are woven from threads of pure imagination. The Dreamweaver, a figure shrouded in starlight, works tirelessly at a loom that spans the boundaries of reality itself. Each thread represents a possibility, a choice, a moment that could be. The weaver offers you a chance to weave your own dream, but warns that every creation comes with a price. What will you choose to manifest?",
            theme: "mystical",
            weight: 0.9,
            risk: true,
            unavailable: false
        )
        
        DispatchQueue.main.async {
            self.selectedStory = fallbackDreamStory
            self.thinkingPhase = "complete"
            self.thinkingIntensity = 0.0
            
            withAnimation(.easeInOut(duration: 0.8)) {
                self.gameState.showingAIStories = false
                self.gameState.showingStoryView = true
            }
        }
    }
    
    // Assign icons to stories only once
    private func assignIconsOnce(_ stories: [StoryOption]) {
        availableIcons = getAllMysticalIcons()
        usedIcons.removeAll()
        assignedIcons.removeAll()
        
        for story in stories {
            let unusedIcons = availableIcons.filter { !usedIcons.contains($0) }
            if let newIcon = unusedIcons.first {
                assignedIcons[story.title] = newIcon
                usedIcons.insert(newIcon)
                print("🎯 Assigned icon \(newIcon) to story: \(story.title)")
            }
        }
    }
    
    // Fallback function for when schema is missing
    private func useFallback() {
        print("🔄 Using fallback story generation")
        // Create a simple fallback story
        let fallbackStory = StoryData(
            title: "The Mysterious Gateway",
            summary: "A tale of discovery and wonder in the depths of the unknown.",
            fullStory: "In the quiet hours before dawn, you find yourself standing before an ancient gateway. Its weathered stone surface bears symbols that seem to shift and change as you look at them. The air around you hums with an energy that feels both familiar and utterly alien.\n\nAs you reach out to touch the gateway, the symbols begin to glow with a soft, ethereal light. The stone beneath your fingertips feels warm, almost alive. A gentle breeze carries whispers of forgotten languages, and you sense that this moment holds the power to change everything.\n\nThe gateway stands as a threshold between worlds, between possibilities. What lies beyond is unknown, but the choice to step forward or turn away is yours alone. The symbols pulse with increasing intensity, as if urging you to make your decision.",
            theme: "mystical",
            setting: "ancient gateway",
            openingHook: "You wake to find yourself standing before an ancient gateway.",
            choices: [
                APIStoryChoice(id: "1", text: "Step through the gateway", hint: "Embrace the unknown", consequence: "You cross the threshold into a new reality."),
                APIStoryChoice(id: "2", text: "Study the symbols first", hint: "Knowledge before action", consequence: "The symbols reveal hidden meanings."),
                APIStoryChoice(id: "3", text: "Wait and observe", hint: "Patience brings clarity", consequence: "Time reveals the gateway's true nature.")
            ],
            cliffhanger: "The symbols pulse with increasing intensity, as if urging you to make your decision.",
            uniqueTags: ["gateway", "symbols", "threshold"],
            worldStateRef: "fallback_world",
            npcsRef: "fallback_npcs",
            style: StoryData.StoryStyle(
                voice: "mythic-register",
                sensoryFocus: "tactile",
                narrativeDevice: "second-person imperative",
                weirdness: 3,
                seed: UUID().uuidString,
                forbiddenPhrases: [],
                microMotif: "ancient gateway symbols",
                palette: ["weathered stone", "ethereal light", "whispers"]
            )
        )
        
        DispatchQueue.main.async {
            self.generatedStory = fallbackStory
            self.showStoryView = true
            print("✅ Fallback story loaded and view shown")
        }
    }
} 

// MARK: - Local Prompt Pack + Schema (inlined to avoid project ref issues)
private enum LocalSchema {
    static var twoParaChoicesJSON: String {
        let obj: [String: Any] = [
            "type": "object",
            "properties": [
                "title": ["type": "string", "minLength": 12, "maxLength": 60],
                "text": ["type": "string", "minLength": 300, "maxLength": 1200],
                "choices": [
                    "type": "array",
                    "minItems": 2,
                    "maxItems": 4,
                    "items": [
                        "type": "object",
                        "properties": [
                            "label": ["type": "string", "minLength": 3, "maxLength": 48],
                            "hint": ["type": "string", "minLength": 6, "maxLength": 80]
                        ],
                        "required": ["label", "hint"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["title", "text", "choices"],
            "additionalProperties": false
        ]
        let data = try? JSONSerialization.data(withJSONObject: obj)
        let str = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        return str.replacingOccurrences(of: "\n", with: "")
    }
}

private func systemFor(seed: String) -> String {
    let s = seed.lowercased()
    if s.contains("scp") {
        return """
        Write interactive scenes in a modern containment setting. First-person present, tight and clinical but human; short vivid sentences. Environments: numbered Site corridors, observation rooms, blast doors, red card readers, negative-pressure labs. NPCs sound like stressed professionals; include ≤2 short lines of dialogue. BAN: harbors/markets/villages/taverns, fog clichés, "ancient curse/virus/salt". Output JSON ONLY (schema provided).
        """
    }
    if s.contains("tlou") || s.contains("last of us") {
        return """
        Grounded post-pandemic survival. First-person present; tactile gear, scarcity, urban rot. Keep threats human or specified by player; avoid generic zombie beats unless the player said so. Include ≤2 lines of terse dialogue. BAN: melodrama, cinematic monologues, tropey safehouses. Output JSON ONLY (schema provided).
        """
    }
    if s.contains("apoc") || s.contains("end of the world") || s.contains("post-") {
        return """
        Contemporary collapse vibe (infrastructure failing, improvised logistics). First-person present; concrete details (dead cell towers, siphoned gas, ration math). Show danger through environment and choices. ≤2 short lines of dialogue. BAN: vague wasteland clichés, sandstorm boilerplate, "we wander for days" filler. JSON ONLY per schema.
        """
    }
    if s.contains("sci fi") || s.contains("scifi") || s.contains("space") || s.contains("star") {
        return """
        Near/outer-future sci‑fi. First-person present; precise tech language (airlocks, delta‑v, coilguns, cryo seals, station manifests). Use real constraints (power, pressure, comms latency). ≤2 lines of clipped dialogue. BAN: vague technobabble; generic "warp" unless brief says so. JSON ONLY per schema.
        """
    }
    if s.contains("cyber") || s.contains("noir") || s.contains("netrunner") {
        return """
        Cyber‑noir city, rain and neon but grounded. First-person present; sensory micro‑details (OSD flicker, cheap optics bloom, graphite grips). Dialogue is razor and short. Themes: tradeoffs, surveillance, debt. BAN: purple monologues, trenchcoat clichés. JSON ONLY per schema.
        """
    }
    if s.contains("fantasy") || s.contains("mage") || s.contains("sword") || s.contains("guild") {
        return """
        Low‑to‑mid fantasy, modern tone. First-person present; concrete craft details (charms, sigils, steel, terrain). Magic feels like physics with costs. ≤2 lines of dialogue. BAN: ye olde diction, tavern/market openers, prophecy clichés. JSON ONLY per schema.
        """
    }
    if s.contains("urban horror") || s.contains("paranormal") || s.contains("occult") {
        return """
        Present‑day urban horror. First-person present; ordinary settings turning wrong via small factual shifts (sound, timing, geometry). Keep it intimate; dread from observation. ≤2 short lines of dialogue. BAN: overwrought gore, Latin‑chant clichés. JSON ONLY per schema.
        """
    }
    return """
    Interactive scene from player intent. First‑person present. Short, vivid, modern tone. React precisely to PLAYER INPUT. BAN: generic harbors/markets/villages/taverns and stale clichés. Output JSON ONLY (schema provided).
    """
}

private func openingUserPrompt(seed: String, title: String) -> String {
    """
    Continue with an OPENING SCENE.

    Brief: \(seed)
    Title: \(title)

    Return:
    {
      "text": "two short paragraphs (4–7 sentences total), first‑person present, includes at most 2 short lines of NPC dialogue, no meta",
      "choices": [
        {"label":"specific action", "hint":"subtle consequence"},
        {"label":"specific action", "hint":"subtle consequence"}
      ]
    }

    Rules:
    - Do not repeat or echo the brief.
    - Modern tone; ASCII only; no clichés; no generic locales unless brief said so.
    - If brief implies SCP, lean containment site (labs, intercom, blast doors).
    """
}

private func accentBase(for mood: StoryMood) -> Color {
    switch mood {
    case .dream, .wonder, .hope: return .cyan
    case .fear, .panic, .dread: return .red
    case .resolve, .calm: return .blue
    case .tension: return .orange
    default: return .cyan
    }
}

// MARK: - AIStoriesScreen 