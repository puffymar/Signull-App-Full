import Foundation
import UIKit
import AVFoundation
import Network

// MARK: - Stub implementations for missing classes

struct VarietyPreset: Codable, Hashable {
    var voice: String = "default"
    var sensoryFocus: String = "default"
    var narrativeDevice: String = "default"
    var weirdness: Int = 2
}

struct VarietyPick {
    var preset: VarietyPreset = VarietyPreset()
    var microMotif: String = "default"
    var palette: [String] = ["default"]
    var seed: String = "default"
}

enum VarietyLevel { case calm, medium, wild }

final class VarietyManager {
    init(level: VarietyLevel = .medium) {}
    func nextPick() -> VarietyPick { return VarietyPick() }
}

final class TrigramBanList {
    init() {}
    static func clean(_ s: String) -> String { return s }
    func phrases(limit: Int = 12) -> [String] { return [] }
    func ingest(_ text: String) {}
}

struct SimilarityGuard {
    init() {}
    func isTooSimilar(candidate: String, vs: [String], tfidfSim: Double) -> Bool { return false }
}

struct PromptBundle {
    var text: String = ""
    var json: String = ""
    var system: String = ""
    var user: String = ""
    var jsonSchemaBase64: String = ""
}

final class PromptBuilder {
    init() {}
    func build() -> PromptBundle { return PromptBundle() }
    func makeText(_ text: String, systemPrefix: String, contextBlock: String, pick: String, forbidden: String, playerNameToken: String, lengthHint: String) -> PromptBuilder { return self }
    func make(_ system: String, user: String, schemaB64: String? = nil) -> PromptBuilder { return self }
}

final class SignullClient {
    static let shared = SignullClient()
    private init() {}
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await URLSession.shared.data(for: request)
    }
}

struct TitleUniqueness {
    static func ensureUniqueConcreteNoun(title: String, usedTokens: Set<String>) -> String {
        return title
    }
}

// Minimal, inline parser to avoid target-membership issues.
// Converts flexible Responses payloads into [StoryIdea]
private enum SignullResponseParser {
    // Returns array of (title, hook)
    static func parseStoryIdeas(from data: Data) -> [(String, String)]? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }

        // 1) response.output[].content[].text -> JSON string with {title, hook/opening_hook}
        if let output = root["output"] as? [[String: Any]] {
            let contents = output.compactMap { $0["content"] as? [[String: Any]] }.flatMap { $0 }
            if let text = contents.first(where: { ($0["type"] as? String) == "output_text" })?["text"] as? String,
               let idea = ideaFromTextJSON(text) { return [idea] }
            if let jsonObj = contents.first(where: { ($0["type"] as? String) == "output_json" })?["json"] as? [String: Any],
               let idea = ideaFromDict(jsonObj) { return [idea] }
        }

        // 2) response.message.content[0].text
        if let message = root["message"] as? [String: Any],
           let content = message["content"] as? [[String: Any]],
           let text = content.first?["text"] as? String,
           let idea = ideaFromTextJSON(text) { return [idea] }

        // 3) top-level already an idea
        if let idea = ideaFromDict(root) { return [idea] }

        // 4) choices[].message.content (string)
        if let choices = root["choices"] as? [[String: Any]] {
            var out: [(String, String)] = []
            for c in choices {
                if let msg = c["message"] as? [String: Any],
                   let content = msg["content"] as? String,
                   let idea = ideaFromTextJSON(content) { out.append(idea) }
            }
            if !out.isEmpty { return out }
        }
        return nil
    }

    private static func ideaFromTextJSON(_ text: String) -> (String, String)? {
        guard let data = text.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return ideaFromDict(obj)
    }

    private static func ideaFromDict(_ obj: [String: Any]?) -> (String, String)? {
        guard let o = obj else { return nil }
        let title = (o["title"] as? String)
            ?? (o["storyTitle"] as? String)
            ?? (o["name"] as? String)
            ?? "Untitled"
        let hook = (o["opening_hook"] as? String)
            ?? (o["openingHook"] as? String)
            ?? (o["hook"] as? String)
            ?? (o["opening"] as? String)
            ?? "A strange night begins at the harbor."
        return (
            title.trimmingCharacters(in: .whitespacesAndNewlines),
            hook.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

// MARK: - Variety System (Temporary - will move to separate file)
#if false
struct VarietyPreset: Codable, Hashable {
    var voice: String
    var sensoryFocus: String
    var narrativeDevice: String
    var weirdness: Int
}

struct VarietyPick {
    var preset: VarietyPreset
    var microMotif: String
    var palette: [String]
    var seed: String
}

enum VarietyLevel { case calm, medium, wild }

final class VarietyManager {
    private let presets: [VarietyPreset]
    private let motifs: [String]
    private let palettes: [[String]]
    private var idx: Int = 0
    private let level: VarietyLevel

    init(level: VarietyLevel = .medium,
         presets: [VarietyPreset]? = nil,
         motifs: [String]? = nil,
         palettes: [[String]]? = nil) {
        self.level = level
        self.presets = presets ?? [
            .init(voice: "lyrical-minimal", sensoryFocus: "auditory", narrativeDevice: "prayer", weirdness: 3),
            .init(voice: "reportage", sensoryFocus: "tactile", narrativeDevice: "stage directions", weirdness: 2),
            .init(voice: "mythic-register", sensoryFocus: "olfactory", narrativeDevice: "found log", weirdness: 4),
            .init(voice: "noir-clipped", sensoryFocus: "kinesthetic", narrativeDevice: "second-person imperative", weirdness: 3),
        ]
        self.motifs = motifs ?? [
            #"cracked cassette labeled "CHOIR A—TWILIGHT""#,
            "bell with a hairline fracture",
            "service bell that rings on its own",
            "silt-wet key on red string",
            "polaroid that never dries"
        ]
        self.palettes = palettes ?? [
            ["iodine", "candle smoke", "seaweed"],
            ["diesel", "hot plastic", "alley citrus"],
            ["iron filings", "wet limestone", "cold mint"],
            ["ozone", "old vellum", "cobalt"]
        ]
    }

    func nextPick() -> VarietyPick {
        let p = presets[idx % presets.count]
        idx += 1
        let motif = motifs.randomElement()!
        let palette = palettes.randomElement()!
        let seed = UUID().uuidString.uppercased()
        var adjusted = p
        switch level {
        case .calm: adjusted.weirdness = max(1, p.weirdness - 1)
        case .wild: adjusted.weirdness = min(5, p.weirdness + 1)
        default: break
        }
        return .init(preset: adjusted, microMotif: motif, palette: palette, seed: seed)
    }
}

final class TrigramBanList {
    private var trigrams: Set<String> = []
    private let maxItems: Int
    private var queue: [String] = []

    init(maxItems: Int = 10) { self.maxItems = maxItems }

    func ingest(_ text: String) {
        let cleaned = TrigramBanList.clean(text)
        let tris = TrigramBanList.trigrams(cleaned)
        queue.append(cleaned)
        if queue.count > maxItems { queue.removeFirst() }
        trigrams.formUnion(tris)
    }

    func phrases(limit: Int = 12) -> [String] {
        return Array(trigrams.prefix(limit))
    }

    static func clean(_ s: String) -> String {
        s
            .lowercased()
            .replacingOccurrences(of: #"[""'']"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[^a-z0-9\s-]"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func trigrams(_ s: String) -> [String] {
        let tokens = s.split(separator: " ").map(String.init)
        guard tokens.count >= 3 else { return [] }
        return (0..<(tokens.count-2)).map { "\(tokens[$0]) \(tokens[$0+1]) \(tokens[$0+2])" }
    }
}

struct SimilarityGuard {
    var trigramThreshold: Double = 0.38
    var tfidfThreshold: Double = 0.85

    func jaccardTrigram(_ a: String, _ b: String) -> Double {
        let A = Set(TrigramBanList.trigrams(TrigramBanList.clean(a)))
        let B = Set(TrigramBanList.trigrams(TrigramBanList.clean(b)))
        if A.isEmpty || B.isEmpty { return 0 }
        return Double(A.intersection(B).count) / Double(A.union(B).count)
    }

    func isTooSimilar(candidate: String, vs lastTexts: [String], tfidfSim: ((String,String)->Double)? = nil) -> Bool {
        for prev in lastTexts {
            let jac = jaccardTrigram(candidate, prev)
            if jac >= trigramThreshold { return true }
            if let t = tfidfSim, t(candidate, prev) >= tfidfThreshold { return true }
        }
        return false
    }
}

struct PromptBundle {
    let system: String
    let user: String
    let jsonSchemaBase64: String
}

enum TitleUniqueness {
    static func ensureUniqueConcreteNoun(title: String, usedTokens: Set<String>) -> String {
        let words = title.split(separator: " ").map(String.init)
        let candidates = words.filter { $0.count > 3 && $0.first?.isLetter == true }
        if candidates.contains(where: { !usedTokens.contains($0.lowercased()) }) {
            return title
        }
        let extras = ["anemometer", "sinkstone", "tideglass", "ratchet", "lantern", "turnstile", "valve"]
        return title + " " + extras.randomElement()!
    }
}

final class PromptBuilder {
    func make(systemPrefix: String,
              contextBlock: String,
              pick: VarietyPick,
              forbidden: [String],
              jsonSchemaB64: String,
              lengthHint: String = SignullConfig.lengthHint(),
              choicesHint: String = SignullConfig.choicesHint()
    ) -> PromptBundle {
        let system = """
        \(systemPrefix)
        Return ONLY a JSON object that matches the schema named SignullScene. No extra keys. No prose.
        """
        let user = """
        You are SIGNULL — an atmospheric, psycho-spiritual story engine.

        Constraints:
        - Output MUST conform to the SignullScene schema.
        - Avoid every phrase in style.forbiddenPhrases (rewrite if needed).
        - Use the style.voice, style.sensoryFocus, and style.narrativeDevice consistently.
        - Include the microMotif and palette elements naturally in the scene.
        - Ensure title includes a unique concrete noun.
        - Make choices consequential with specific hints and consequences.

        Style:
        voice=\(SignullConfig.gen.voiceOverride ?? pick.preset.voice) | sensoryFocus=\(pick.preset.sensoryFocus) | narrativeDevice=\(SignullConfig.gen.narrativeDeviceOverride ?? pick.preset.narrativeDevice) | weirdness=\(SignullConfig.gen.weirdnessOverride ?? pick.preset.weirdness) | seed=\(pick.seed)
        microMotif: \(pick.microMotif)
        palette: \(pick.palette.joined(separator: ", "))
        forbiddenPhrases=\(forbidden)

        Length: \(lengthHint)
        \(choicesHint)

        \(contextBlock)
        """
        return .init(system: system, user: user, jsonSchemaBase64: jsonSchemaB64)
    }
}
#endif

enum ParameterSanitizer {
    static func requestBody(model: String,
                            system: String,
                            user: String,
                            maxOutputTokens: Int,
                            schemaB64: String) -> [String: Any] {
        return [
            "model": model,
            "max_output_tokens": maxOutputTokens,
            "input": [
                ["role": "system", "content": system],
                ["role": "user",   "content": user]
            ],
            "text": [
                "format": [
                    "type": "json_schema",
                    "json_schema": [
                        "name": "SignullScene",
                        "strict": true,
                        "schema": schemaB64
                    ]
                ]
            ]
        ]
    }

    // Text-only body (no JSON schema), with stop tokens
    static func requestBodyText(model: String,
                                system: String,
                                user: String,
                                maxOutputTokens: Int,
                                stop: [String]) -> [String: Any] {
        return [
            "model": model,
            "max_output_tokens": maxOutputTokens,
            "input": [
                ["role": "system", "content": system],
                ["role": "user",   "content": user]
            ],
            "stop_sequences": stop
        ]
    }
}

final class SilentAudio {
    private var player: AVAudioPlayer?
    private var hasLoggedMissing: Set<String> = []

    func play(named baseName: String, exts: [String] = ["mp3","m4a","wav"], volume: Float = 0.6, loops: Int = 0) {
        for ext in exts {
            if let url = Bundle.main.url(forResource: baseName, withExtension: ext) {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.numberOfLoops = loops
                    player?.volume = volume
                    player?.prepareToPlay()
                    player?.play()
                    return
                } catch {
                    // fall through to try next extension
                }
            }
        }
        // Log once; then fail silently
        if !hasLoggedMissing.contains(baseName) {
            print("❔ Audio missing (silenced): \(baseName) (tried: \(exts.joined(separator: ", ")))")
            hasLoggedMissing.insert(baseName)
        }
    }

    func stop() { player?.stop() }
}

// MARK: - Shared URLSession Client
// This definition is duplicated in `Utilities/NetworkClient.swift`. Use that one.
// Keeping a stub here disabled to avoid duplicate symbol/type errors.
#if false
actor SignullClient {
    static let shared = SignullClient()
    private let session: URLSession
    private init() { fatalError("Use Utilities/NetworkClient.SignullClient") }
    func data(for req: URLRequest) async throws -> (Data, URLResponse) { fatalError() }
}
#endif

// MARK: - Lightweight Reachability Gate (local to SignullAPI)
final class ReachGate {
    static let shared = ReachGate()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "reachgate.monitor")
    private var reachable: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.reachable = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    func waitIfNeeded(timeoutSec: Double = 8) async {
        if reachable { return }
        let deadline = Date().addingTimeInterval(timeoutSec)
        while !reachable && Date() < deadline {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s backoff
        }
    }
}

// MARK: - Authentication Helper
enum SignullAuth {
    static func apply(to request: inout URLRequest) {
        guard let host = request.url?.host else { return }
        
        if host.contains("api.signullrift.com") {
            // Our proxy holds the OpenAI key server-side. Use app token.
            request.setValue(SignullConfig.appToken, forHTTPHeaderField: "x-signull-auth")
            request.setValue(nil, forHTTPHeaderField: "Authorization") // ensure no Bearer remains
        } else if host.contains("openai.com") {
            // Only if you call OpenAI directly
            let key = EnvironmentManager.shared.openAIAPIKeyRequired
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
    }
}

// MARK: - Centralized Schema Store
enum SignullSchemaStore {
    static let shared = SignullSchemaStore.load()
    
    private static func load() -> [String: Any] {
        guard let url = Bundle.main.url(forResource: "SignullSchema", withExtension: "json") else {
            print("❌ CRITICAL: SignullSchema.json not found in bundle")
            return [:]
        }
        
        do {
            let data = try Data(contentsOf: url)
            let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            print("✅ SCHEMA: Loaded once at startup (\(data.count) bytes)")
            return obj
        } catch {
            print("❌ CRITICAL: Failed to parse SignullSchema.json: \(error)")
            return [:]
        }
    }
}

// MARK: - Simplified Request Structure
struct LiveRequest: Encodable {
    let model: String
    let messages: [Message]
    let response_format: ResponseFormat
    let max_tokens: Int
    let stream: Bool
    
    struct Message: Encodable {
        let role: String
        let content: String
    }
    
    struct ResponseFormat: Encodable {
        let type: String
        let schema: [String: Any]
        
        enum CodingKeys: String, CodingKey {
            case type
            case schema
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            
            // Encode schema as a JSON string - this is what the API expects
            let schemaData = try JSONSerialization.data(withJSONObject: schema)
            let schemaString = String(data: schemaData, encoding: .utf8) ?? "{}"
            try container.encode(schemaString, forKey: .schema)
        }
    }
}

// MARK: - Request Structure
struct SignullRequest: Encodable {
    let model: String
    let input: [[String: String]]
    let text: TextFormat
    let max_output_tokens: Int
    let reasoning: Reasoning
    let temperature: Double?
    let top_p: Double?
    
    struct TextFormat: Encodable {
        let format: Schema
        
        struct Schema: Encodable {
            let type: String = "json_schema"
            let json_schema: ModelSchema
        }
        
        struct ModelSchema: Encodable {
            let name: String = "SignullScene"
            let strict: Bool = true
            let schema: String // SignullSchema.json as single-line string
        }
    }
    
    struct Reasoning: Encodable {
        let effort: String
    }
}

// MARK: - Scene Generation Tiers
enum SceneTier {
    case stub  // title, openingHook only
    case full  // complete scene
}

// MARK: - Schema Generation
func makeSchema(tier: SceneTier) -> String {
    switch tier {
    case .stub:
        // Compact schema for stub generation
        return """
        {"type":"object","additionalProperties":false,
         "required":["title","openingHook"],
         "properties":{
           "title":{"type":"string","maxLength":80},
           "openingHook":{"type":"string","maxLength":160}
         }}
        """
    case .full:
        // Load the full schema from SignullSchema.json
        guard let schemaURL = Bundle.main.url(forResource: "SignullSchema", withExtension: "json"),
              let schemaData = try? Data(contentsOf: schemaURL),
              let schemaString = String(data: schemaData, encoding: .utf8) else {
            print("⚠️ Failed to load SignullSchema.json, using fallback")
            return """
            {"type":"object","additionalProperties":false,
             "required":["title","summary","fullStory","theme","setting","openingHook","choices","cliffhanger","uniqueTags","worldStateRef","npcsRef","style"],
             "properties":{
               "title":{"type":"string","maxLength":100},
               "summary":{"type":"string","maxLength":200},
               "fullStory":{"type":"string","maxLength":2000},
               "theme":{"type":"string","maxLength":50},
               "setting":{"type":"string","maxLength":100},
               "openingHook":{"type":"string","maxLength":200},
               "choices":{"type":"array","items":{"type":"object","properties":{"id":{"type":"string"},"text":{"type":"string"},"hint":{"type":"string"},"consequence":{"type":"string"}}}},
               "cliffhanger":{"type":"string","maxLength":300},
               "uniqueTags":{"type":"array","items":{"type":"string"}},
               "worldStateRef":{"type":"string"},
               "npcsRef":{"type":"string"},
               "style":{"type":"object","properties":{"voice":{"type":"string"},"sensoryFocus":{"type":"string"},"narrativeDevice":{"type":"string"},"weirdness":{"type":"integer"},"seed":{"type":"string"},"forbiddenPhrases":{"type":"array","items":{"type":"string"}},"microMotif":{"type":"string"},"palette":{"type":"array","items":{"type":"string"}}}}
             }}
            """
        }
        
        // Convert to single-line string for API
        return schemaString.replacingOccurrences(of: "\n", with: "")
                          .replacingOccurrences(of: " ", with: "")
    }
}

// MARK: - Response Structure
struct SignullResponse: Codable {
    let id: String
    let object: String
    let status: String
    let output: [OutputItem]?
    let incomplete_details: IncompleteDetails?
    let usage: Usage?
    
    struct IncompleteDetails: Codable {
        let reason: String?
    }
    
    struct OutputItem: Codable {
        let type: String
        let content: [ContentItem]?
        
        struct ContentItem: Codable {
            let type: String
            let text: String
        }
    }
    
    struct Usage: Codable {
        let input_tokens: Int
        let output_tokens: Int
        let total_tokens: Int
    }
}

// MARK: - StoryData Extensions
extension StoryData {
    func encode() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

// MARK: - Live API Client with Full Diagnostics
final class LiveAPI: StoryAPI {
    private let baseURL: URL
    private let session: URLSession? // optional, used for stubbed sessions
    
    init(baseURL: URL, session: URLSession? = nil) {
        self.baseURL = baseURL
        self.session = session
        print("🔧 LIVE API: Initialized with endpoint \(baseURL)")
    }

    private func send(_ req: URLRequest) async throws -> (Data, URLResponse) {
        if let s = session {
            return try await s.data(for: req)
        }
        return try await SignullClient.shared.data(for: req)
    }
    
    // Check if model supports temperature parameter
    private func modelAllowsTemperature(_ model: String) -> Bool {
        // gpt-5-mini doesn't support temperature, but other models might
        return ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo"].contains(model)
    }
    
    // Build request payload with JSON schema and optimized parameters
    private func buildPayload(
        prompt: String,
        systemPrompt: String,
        schema: String,
        tier: SceneTier
    ) -> SignullRequest {
        let textFormat = SignullRequest.TextFormat(
            format: SignullRequest.TextFormat.Schema(
                json_schema: SignullRequest.TextFormat.ModelSchema(
                    schema: schema
                )
            )
        )
        
        let request = SignullRequest(
            model: "gpt-5-mini",
            input: [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            text: textFormat,
            max_output_tokens: tier == .stub ? 1600 : 4000,
            reasoning: SignullRequest.Reasoning(effort: "none"),
            temperature: nil,
            top_p: nil
        )
        
        return request
    }

    // Build strict, tiny idea request body for Responses API
    private func buildIdeaRequest() -> [String: Any] {
        return [
            "model": "gpt-5-mini-2025-08-07",
            "input": "Generate exactly ONE story idea as JSON with fields {title,hook}. No other fields.",
            "text": [
                "format": [
                    "type": "json_schema",
                    "json_schema": [
                        "name": "StoryIdea",
                        "strict": true,
                        "schema": [
                            "type": "object",
                            "properties": [
                                "title": ["type": "string", "maxLength": 80],
                                "hook": ["type": "string", "maxLength": 280]
                            ],
                            "required": ["title", "hook"],
                            "additionalProperties": false
                        ]
                    ]
                ],
                "verbosity": "medium"
            ],
            "max_output_tokens": 220,
            "parallel_tool_calls": false
        ]
    }

    // MARK: - Idea Extraction (lenient)
    private struct StoryIdea: Decodable { let title: String; let hook: String }

    private func extractIdeas(from responseJSONData: Data) -> [StoryIdea] {
        // Try flat {ideas:[...]}
        struct Flat: Decodable { let ideas: [StoryIdea]? }
        if let flat = try? JSONDecoder().decode(Flat.self, from: responseJSONData), let arr = flat.ideas, !arr.isEmpty {
            return arr
        }
        
        struct Resp: Decodable {
            struct OutputItem: Decodable {
                struct ContentItem: Decodable {
                    let type: String
                    let text: String?
                    let json: [String: String]?
                }
                let type: String
                let status: String?
                let content: [ContentItem]?
                let id: String?
            }
            let object: String?
            let status: String?
            let output: [OutputItem]?
        }

        var ideas: [StoryIdea] = []
        if let resp = try? JSONDecoder().decode(Resp.self, from: responseJSONData), let outputs = resp.output {
        for o in outputs {
            guard o.type == "message", let content = o.content else { continue }
            for c in content where c.type == "output_text" || c.type == "output_json" {
                guard var text = c.text else { continue }

                // Strip code fences if present
                if text.hasPrefix("```") {
                    text = text.replacingOccurrences(of: "```json", with: "")
                                 .replacingOccurrences(of: "```", with: "")
                }

                if let j = c.json, let t = j["title"], let h = j["hook"] {
                    ideas.append(StoryIdea(title: t, hook: h))
                    continue
                }

                if let data = text.data(using: .utf8),
                   let idea = try? JSONDecoder().decode(StoryIdea.self, from: data) {
                    ideas.append(idea)
                    continue
                }

                if let data = text.data(using: .utf8),
                   var dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
                    if dict["hook"] == nil, let oh = dict["opening_hook"] as? String { dict["hook"] = oh }
                    if let title = dict["title"] as? String, let hook = dict["hook"] as? String {
                        ideas.append(StoryIdea(title: title, hook: hook))
                        continue
                    }
                }

                let title = regexCapture(text, pattern: #"\"title\"\s*:\s*\"([^\"]{1,80})\""#)
                let hook  = regexCapture(text, pattern: #"\"(hook|opening_hook)\"\s*:\s*\"([^\"]{1,280})\""#, group: 2)
                if let t = title, let h = hook {
                    ideas.append(StoryIdea(title: t, hook: h))
                }
            }
        } }
        return ideas
    }

    private func parseIdeasFlatOrNDJSON(from data: Data) -> [StoryIdea] {
        var ideas: [StoryIdea] = []
        if let s = String(data: data, encoding: .utf8) {
            let lines = s.split(separator: "\n").map(String.init)
            for line in lines {
                if let d = line.data(using: .utf8), let idea = try? JSONDecoder().decode(StoryIdea.self, from: d) {
                    ideas.append(idea)
                    continue
                }
                // loose
                if let idea = ideaFromLooseText(line) { ideas.append(idea) }
            }
        }
        return ideas
    }

    private func ideaFromLooseText(_ text: String) -> StoryIdea? {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("```") {
            t = t.replacingOccurrences(of: "```json", with: "")
                 .replacingOccurrences(of: "```", with: "")
                 .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let d = t.data(using: .utf8), let idea = try? JSONDecoder().decode(StoryIdea.self, from: d) {
            return idea
        }
        if let d = t.data(using: .utf8), var dict = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] {
            if dict["hook"] == nil, let oh = dict["opening_hook"] as? String { dict["hook"] = oh }
            if let title = dict["title"] as? String, let hook = dict["hook"] as? String {
                return StoryIdea(title: title, hook: hook)
            }
        }
        let title = regexCapture(t, pattern: #"\"title\"\s*:\s*\"([^\"]{1,120})\""#)
        let hook  = regexCapture(t, pattern: #"\"(?:hook|opening_hook)\"\s*:\s*\"([^\"]{1,400})\""#)
        if let ti = title, let ho = hook { return StoryIdea(title: ti, hook: ho) }
        return nil
    }

    private func regexCapture(_ s: String, pattern: String, group: Int = 1) -> String? {
        let r = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        guard let m = r?.firstMatch(in: s, options: [], range: range) else { return nil }
        if let rr = Range(m.range(at: group), in: s) { return String(s[rr]) }
        return nil
    }

    private func ideaToStory(_ idea: StoryIdea) -> StoryData {
        let stubChoices = [
            APIStoryChoice(id: "choice1", text: "Continue", hint: "Proceed with the idea", consequence: "The story unfolds."),
            APIStoryChoice(id: "choice2", text: "Investigate", hint: "Look deeper", consequence: "You discover a thread."),
            APIStoryChoice(id: "choice3", text: "Hold", hint: "Wait and observe", consequence: "A new angle appears.")
        ]
        return StoryData(
            title: idea.title,
            summary: String(idea.hook.prefix(200)),
            fullStory: idea.hook,
            theme: "mystery",
            setting: "unknown",
            openingHook: idea.hook,
            choices: stubChoices,
            cliffhanger: "The idea beckons...",
            uniqueTags: ["idea", "stub"],
            worldStateRef: "",
            npcsRef: "",
            style: StoryData.StoryStyle(
                voice: "reportage",
                sensoryFocus: "tactile",
                narrativeDevice: "second-person imperative",
                weirdness: 2,
                seed: UUID().uuidString,
                forbiddenPhrases: [],
                microMotif: "",
                palette: []
            )
        )
    }
    
    func generate(tier: SceneTier, timeoutSec: TimeInterval = 45) async throws -> StoryData {
        await ReachGate.shared.waitIfNeeded()
        let appToken = SignullConfig.appToken
        assert(!appToken.isEmpty, "App token is empty")
        
        // For stub ideas, call Responses API with strict, tiny schema to avoid truncation/variance
        if tier == .stub {
            let ideaDict = buildIdeaRequest()
            let data = try await postDict(ideaDict)
            // Prefer robust parser; fall back to legacy if needed
            let ideas: [StoryIdea]
            if let tuples = SignullResponseParser.parseStoryIdeas(from: data), let first = tuples.first {
                ideas = [StoryIdea(title: first.0, hook: first.1)]
            } else {
                ideas = extractIdeas(from: data) + parseIdeasFlatOrNDJSON(from: data)
            }
            if let first = ideas.first {
                return ideaToStory(first)
            }
            // fall through to legacy flow if nothing extracted
        }

        // Legacy full-scene flow (and fallback for stub if extraction failed)
        let systemPrompt = "You are a Signull scene engine. Output ONLY valid JSON matching the schema. Title 12–60 chars, no leading articles, no numbers, no underscores; hook 40–160 chars, concrete and specific; summary 80–240 chars, second‑person vibe. Strictly follow user brief."
        let userPrompt = tier == .stub ? "Generate a story stub with title and opening hook." : "Generate a complete story scene."
        
        let body = buildPayload(
            prompt: userPrompt,
            systemPrompt: systemPrompt,
            schema: makeSchema(tier: tier),
            tier: tier
        )
        
        let data = try await postJSON(body)
        
        // Decode response
        let decoder = JSONDecoder()
        
        // 🔍 DEBUG: Log the actual API response
        print("🔍 API Response Data:")
        if let responseString = String(data: data, encoding: .utf8) {
            print(responseString)
        }
        
        let response: SignullResponse
        do {
            response = try decoder.decode(SignullResponse.self, from: data)
        } catch {
            print("🔴 DECODE ERROR: \(error)")
            print("🔴 DECODE ERROR DETAILS: \(error.localizedDescription)")
            throw LiveError.invalidResponse
        }
        
        // Handle incomplete responses with retry logic
        if response.status == "incomplete" {
            print("⚠️ API Response incomplete - attempting retry with higher token limit")
            let retryBody = SignullRequest(
                model: "gpt-5-mini",
                input: body.input,
                text: body.text,
                max_output_tokens: min(body.max_output_tokens + 1000, 5000),
                reasoning: body.reasoning,
                temperature: nil,
                top_p: nil
            )
            let retryData = try await postJSON(retryBody)
            let retryResponse = try decoder.decode(SignullResponse.self, from: retryData)
            if retryResponse.status == "incomplete" {
                print("🔴 Retry also incomplete - using fallback")
                throw LiveError.invalidResponse
            }
            return try parseStoryFromResponse(retryResponse, decoder: decoder)
        }
        
        // Process successful response
        return try parseStoryFromResponse(response, decoder: decoder)
    }

    // Backoff POST using shared client
    private func postJSON<T: Encodable>(_ body: T) async throws -> Data {
        var req = URLRequest(url: baseURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("RPGFINISH/1.0 (iOS; Simulator)", forHTTPHeaderField: "User-Agent")
        req.setValue("signull-ios", forHTTPHeaderField: "X-App-Client")
        SignullAuth.apply(to: &req)
        req.httpBody = try JSONEncoder().encode(body)
        
        print("REQ start \(Date()) id=\(UUID().uuidString.prefix(6))")
        var delay: UInt64 = 250_000_000 // 0.25s
        for attempt in 0..<3 {
            do {
                let (data, resp) = try await send(req)
                guard let http = resp as? HTTPURLResponse else { throw LiveError.badServerResponse }
                let ct = (http.value(forHTTPHeaderField: "Content-Type") ?? "").lowercased()
                if !(200..<300).contains(http.statusCode) {
                    let snippet = String(data: data.prefix(512), encoding: .utf8) ?? "<non-utf8>"
                    print("\n❌ Server error: HTTP \(http.statusCode) CT=\(ct)\n\(snippet)")
                    throw LiveError.badStatus(code: http.statusCode, body: snippet)
                }
                if !ct.contains("application/json") {
                    let snippet = String(data: data.prefix(512), encoding: .utf8) ?? "<non-utf8>"
                    print("\n❌ Non-JSON content-type: \(ct)\n\(snippet)")
                    throw LiveError.invalidResponse
                }
                return data
            } catch let e as URLError where e.code == .timedOut || e.code == .cannotFindHost || e.code == .networkConnectionLost {
                if attempt == 2 { throw e }
                try await Task.sleep(nanoseconds: delay + UInt64(Int.random(in: 0...150_000_000)))
                delay *= 2
            }
        }
        throw LiveError.badServerResponse
    }

    // Post raw dictionary body (for idea endpoint)
    private func postDict(_ dict: [String: Any]) async throws -> Data {
        var req = URLRequest(url: baseURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("RPGFINISH/1.0 (iOS; Simulator)", forHTTPHeaderField: "User-Agent")
        req.setValue("signull-ios", forHTTPHeaderField: "X-App-Client")
        SignullAuth.apply(to: &req)
        req.httpBody = try JSONSerialization.data(withJSONObject: dict)
        print("REQ start \(Date()) id=\(UUID().uuidString.prefix(6))")
        let (data, resp) = try await send(req)
        guard let http = resp as? HTTPURLResponse else { throw LiveError.badServerResponse }
        let ct = (http.value(forHTTPHeaderField: "Content-Type") ?? "").lowercased()
        if !(200..<300).contains(http.statusCode) {
            let snippet = String(data: data.prefix(512), encoding: .utf8) ?? "<non-utf8>"
            print("\n❌ Server error: HTTP \(http.statusCode) CT=\(ct)\n\(snippet)")
            throw LiveError.badStatus(code: http.statusCode, body: snippet)
        }
        if !ct.contains("application/json") {
            let snippet = String(data: data.prefix(512), encoding: .utf8) ?? "<non-utf8>"
            print("\n❌ Non-JSON content-type: \(ct)\n\(snippet)")
            throw LiveError.invalidResponse
        }
        return data
    }
    
    // Helper function to parse StoryData from response
    private func parseStoryFromResponse(_ response: SignullResponse, decoder: JSONDecoder) throws -> StoryData {
        // Extract JSON content from the response
        var jsonContent = ""
        for outputItem in response.output ?? [] {
            if outputItem.type == "message" {
                for contentItem in outputItem.content ?? [] {
                    if contentItem.type == "output_text" {
                        jsonContent += contentItem.text
                    }
                }
            }
        }
        
        // If no content found, throw error
        if jsonContent.isEmpty {
            print("🔴 No JSON content found in API response")
            throw LiveError.invalidResponse
        }
        
        // Try to decode as StoryData directly
        do {
            let storyData = try decoder.decode(StoryData.self, from: jsonContent.data(using: .utf8)!)
            
            // Enforce title generation
            var mutableStory = storyData
            var title = mutableStory.title.trimmingCharacters(in: .whitespacesAndNewlines)
            if title.isEmpty || title.lowercased() == "untitled" {
                title = TitleForge.synth(
                    openingHook: mutableStory.openingHook,
                    theme: mutableStory.theme,
                    setting: mutableStory.setting
                )
            }
            mutableStory.title = title
            
            return mutableStory
        } catch {
            print("🔴 Failed to decode StoryData from JSON: \(error)")
            throw LiveError.invalidResponse
        }
    }
    // Removed stray brace that prematurely closed LiveAPI class
    
    // Legacy function for backward compatibility
    func generate(prompt: String, systemPrompt: String, temperature: Double = 1.3, presencePenalty: Double = 0.9) async throws -> Data {
        return try await self.generate(tier: .full, timeoutSec: 22).encode()
    }
    
    private func performRequest(request: SignullRequest, retryCount: Int) async throws -> Data {
        var req = URLRequest(url: self.baseURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        SignullAuth.apply(to: &req)
        
        // Encode request using JSONEncoder
        req.httpBody = try JSONEncoder().encode(request)
        
        // 🔍 ENHANCED REQUEST LOGGING
        print("➡️ \(req.httpMethod ?? "POST") \(req.url!.absoluteString)")
        req.allHTTPHeaderFields?.forEach { print("  H: \($0): \($1)") }
        if let body = req.httpBody { 
            print("  BODY:\n\(String(data: body, encoding: .utf8)!)")
        }
        
        let (data, resp) = try await self.send(req)
        guard let http = resp as? HTTPURLResponse else { 
            throw LiveError.badServerResponse 
        }
        
        if (200..<300).contains(http.statusCode) { 
            print("✅ HTTP \(http.statusCode) - SUCCESS")
            return data 
        }
        
        // Handle 400 errors with unsupported parameters
        if http.statusCode == 400 && retryCount == 0 {
            let msg = String(data: data, encoding: .utf8) ?? ""
            if msg.contains("Unsupported parameter") {
                print("⚠️ Unsupported parameter detected, retrying with simplified request...")
                // Create a minimal request without optional parameters
                // Create a minimal request without unsupported parameters
                let minimalRequest = SignullRequest(
                    model: "gpt-5-mini",
                    input: request.input,
                    text: request.text,
                    max_output_tokens: request.max_output_tokens,
                    reasoning: request.reasoning,
                    temperature: nil,
                    top_p: nil
                )
                return try await performRequest(request: minimalRequest, retryCount: 1)
            }
        }
        
        // Surface server message for errors
        let msg = String(data: data, encoding: .utf8) ?? "<no body>"
        print("🔴 HTTP \(http.statusCode) BODY:")
        print(msg)
        print("🔴 RESPONSE HEADERS: \(http.allHeaderFields)")
        throw LiveError.badStatus(code: http.statusCode, body: msg)
    }
    
    // MARK: - Health Check
    func healthCheck() async -> Bool {
        do {
            var req = URLRequest(url: self.baseURL)
            req.httpMethod = "POST" // most proxies won't expose GET; use a tiny POST
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            SignullAuth.apply(to: &req)
            
            // Use plain text format for health check
            let healthRequest = SignullRequest(
                model: "gpt-5-mini",
                input: [
                    ["role": "system", "content": "You are a test system. Respond with 'pong'."],
                    ["role": "user", "content": "ping"]
                ],
                text: SignullRequest.TextFormat(
                    format: SignullRequest.TextFormat.Schema(
                        json_schema: SignullRequest.TextFormat.ModelSchema(
                            schema: "{\"type\":\"string\",\"maxLength\":20}"
                        )
                    )
                ),
                max_output_tokens: 20,
                reasoning: SignullRequest.Reasoning(effort: "none"),
                temperature: nil,
                top_p: nil
            )
            
            req.httpBody = try JSONEncoder().encode(healthRequest)
            
            let (_, resp) = try await self.send(req)
            guard let http = resp as? HTTPURLResponse else { return false }
            return (200..<300).contains(http.statusCode)
        } catch {
            print("🔴 HEALTH CHECK FAILED: \(error)")
            return false
        }
    }
    
    // MARK: - Authentication Test
    func testAuthMethods() async {
        let appToken = SignullConfig.appToken
        print("🔐 TESTING AUTH METHODS with app token: \(appToken)...")
        
        // Test 1: x-signull-auth
        await testAuthMethod(name: "x-signull-auth", headers: ["x-signull-auth": appToken])
    }
    
    private func testAuthMethod(name: String, headers: [String: String]) async {
        do {
            var req = URLRequest(url: self.baseURL)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Add test headers
            for (key, value) in headers {
                req.setValue(value, forHTTPHeaderField: key)
            }
            
            let testPayload: [String: Any] = [
                "model": "gpt-4o-mini",
                "messages": [
                    ["role": "system", "content": "You are a helpful assistant."],
                    ["role": "user", "content": "ping"]
                ],
                "max_tokens": 5,
                "stream": false
            ]
            
            req.httpBody = try JSONSerialization.data(withJSONObject: testPayload, options: [])
            
            print("🧪 Testing \(name)...")
            let (data, resp) = try await self.send(req)
            guard let http = resp as? HTTPURLResponse else { return }
            
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            print("  \(name): HTTP \(http.statusCode) - \(body)")
            
        } catch {
            print("  \(name): ERROR - \(error)")
        }
    }
    
    private static func curlCommand(from request: URLRequest) -> String {
        var parts = ["curl", "-i", "-X", request.httpMethod ?? "GET", "'\(request.url!.absoluteString)'"]
        request.allHTTPHeaderFields?.forEach { parts += ["-H", "'\($0): \($1)'"] }
        if let body = request.httpBody, let s = String(data: body, encoding: .utf8) {
            parts += ["--data-raw", "'\(s.replacingOccurrences(of: "'", with: "'\\''"))'"]
        }
        return parts.joined(separator: " ")
    }
    
    enum LiveError: Error, CustomStringConvertible {
        case badStatus(code: Int, body: String)
        case badServerResponse
        case schemaNotLoaded
        case invalidResponse
        
        var description: String {
            switch self {
            case .badStatus(let code, let body): 
                return "HTTP \(code): \(body)"
            case .badServerResponse:
                return "Invalid server response"
            case .schemaNotLoaded:
                return "Schema not loaded"
            case .invalidResponse:
                return "Invalid response format"
            }
        }
    }
}







// MARK: - Mock API for Development
protocol StoryAPI {
    func generate(prompt: String, systemPrompt: String, temperature: Double, presencePenalty: Double) async throws -> Data
}

final class MockAPI: StoryAPI {
    private let variety = VarietyManager(level: .medium)
    private let bans = TrigramBanList()
    
    func generate(prompt: String, systemPrompt: String, temperature: Double, presencePenalty: Double) async throws -> Data {
        // Use the new variety system
        let pick = variety.nextPick()
        let uniqueId = UUID().uuidString.prefix(8)
        
        // Generate story content using the variety pick
        let storyContent = generateStoryContent(for: pick)
        let choices = generateChoices(for: pick)
        
        // Create a proper title with unique concrete noun
        let titleOptions = [
            "The \(pick.microMotif.replacingOccurrences(of: " ", with: " ").capitalized)",
            "Notes of \(pick.preset.voice.replacingOccurrences(of: "-", with: " ").capitalized)",
            "Whispers of \(pick.preset.narrativeDevice.capitalized)",
            "The \(pick.preset.sensoryFocus.capitalized) Threshold",
            "\(pick.preset.voice.replacingOccurrences(of: "-", with: " ").capitalized) \(pick.preset.narrativeDevice.capitalized)"
        ]
        let baseTitle = titleOptions.randomElement() ?? "The \(pick.preset.voice.capitalized) Moment"
        let title = TitleUniqueness.ensureUniqueConcreteNoun(title: baseTitle, usedTokens: Set<String>())
        
        let mockStory = """
        {
            "title": "\(title)",
            "summary": "A \(pick.preset.voice) story where \(pick.microMotif.lowercased()) reveals hidden truths",
            "fullStory": "\(storyContent)",
            "theme": "variety",
            "setting": "A \(pick.preset.sensoryFocus) landscape where \(pick.microMotif.lowercased())",
            "openingHook": "You encounter \(pick.microMotif.lowercased())",
            "choices": \(choices),
            "cliffhanger": "The world around you begins to shift and change...",
            "uniqueTags": ["\(pick.preset.voice)", "\(pick.preset.sensoryFocus)", "\(uniqueId)"],
            "worldStateRef": "mock-world-\(uniqueId)",
            "npcsRef": "mock-npcs-\(uniqueId)",
            "style": {
                "voice": "\(pick.preset.voice)",
                "sensoryFocus": "\(pick.preset.sensoryFocus)",
                "narrativeDevice": "\(pick.preset.narrativeDevice)",
                "weirdness": \(pick.preset.weirdness),
                "seed": "\(pick.seed)",
                "forbiddenPhrases": \(bans.phrases(limit: 8)),
                "microMotif": "\(pick.microMotif)",
                "palette": \(pick.palette)
            }
        }
        """
        return Data(mockStory.utf8)
    }
    
    private func generateStoryContent(for pick: VarietyPick) -> String {
        let paletteText = pick.palette.joined(separator: ", ")
        
        let storyVariants = [
            """
            The air carries \(paletteText), a sensory reminder of the \(pick.preset.sensoryFocus) that surrounds you. \(pick.microMotif.capitalized) serves as both warning and invitation, its presence speaking to the deeper currents that flow through this place.
            
            Your \(pick.preset.sensoryFocus) awareness sharpens as you move through the space, each step revealing new layers of the \(pick.preset.narrativeDevice) reality that has taken hold here. The \(pick.preset.voice) nature of your journey becomes clearer with each passing moment.
            
            At the edge of perception, something shifts. The \(pick.microMotif.lowercased()) seems to respond to your presence, its meaning changing as you approach. The landscape reveals its true nature: not a place of endings, but of transformations waiting to unfold.
            """,
            """
            \(pick.microMotif.capitalized) stands before you, a sentinel in the \(pick.preset.sensoryFocus) realm. The atmosphere is thick with \(paletteText), each breath drawing you deeper into the mystery that has gathered here like storm clouds before lightning.
            
            Through your \(pick.preset.sensoryFocus) perception, you sense the patterns that govern this place. The \(pick.preset.narrativeDevice) rhythm of your existence here becomes undeniable, each moment a verse in a larger composition that you are only beginning to understand.
            
            The \(pick.microMotif.lowercased()) pulses with an inner light, its significance shifting as you contemplate its meaning. This space is not what it first appeared—it's a crucible where possibilities are forged and destinies are rewritten.
            """,
            """
            You find yourself in the presence of \(pick.microMotif.lowercased()), an artifact of the \(pick.preset.voice) that defies simple explanation. The air is alive with \(paletteText), each sensation a thread in the tapestry of meaning that surrounds you.
            
            Your \(pick.preset.sensoryFocus) faculties reveal the hidden architecture of this place. The \(pick.preset.narrativeDevice) framework of your experience here becomes apparent, each interaction a step toward understanding the deeper truth that lies beneath the surface.
            
            The \(pick.microMotif.lowercased()) resonates with your presence, its purpose becoming clearer as you engage with it. This environment is not merely a setting—it's an active participant in the story that's unfolding around you.
            """
        ]
        
        return storyVariants.randomElement() ?? storyVariants[0]
    }
    
    private func generateChoices(for pick: VarietyPick) -> String {
        let choiceVariants = [
            [
                ("Embrace the \(pick.microMotif)", "Trust in the transformation", "You become part of the mystery"),
                ("Study the patterns", "Knowledge brings power", "You understand the deeper structure"),
                ("Create your own path", "Defy the expected", "You forge a new possibility")
            ],
            [
                ("Follow the \(pick.palette.first ?? "scent")", "Let your senses guide you", "You discover hidden truths"),
                ("Question everything", "Doubt leads to clarity", "You see through the illusions"),
                ("Accept the mystery", "Some things cannot be known", "You find peace in uncertainty")
            ],
            [
                ("Touch the \(pick.microMotif.lowercased())", "Physical contact reveals secrets", "Your fingertips tingle with ancient knowledge"),
                ("Listen to the whispers", "The air itself speaks", "You hear voices from beyond"),
                ("Meditate on the moment", "Stillness brings clarity", "Time seems to pause around you")
            ],
            [
                ("Document what you see", "Record for posterity", "Your observations become valuable"),
                ("Leave a mark", "Make your presence known", "Something remembers you were here"),
                ("Take nothing, change nothing", "Pure observation", "You become invisible to the forces at work")
            ]
        ]
        
        let choices = choiceVariants.randomElement() ?? choiceVariants[0]
        
        return """
        [
            {
                "id": "choice1",
                "text": "\(choices[0].0)",
                "hint": "\(choices[0].1)",
                "consequence": "\(choices[0].2)"
            },
            {
                "id": "choice2", 
                "text": "\(choices[1].0)",
                "hint": "\(choices[1].1)",
                "consequence": "\(choices[1].2)"
            },
            {
                "id": "choice3",
                "text": "\(choices[2].0)",
                "hint": "\(choices[2].1)",
                "consequence": "\(choices[2].2)"
            }
        ]
        """
    }
    

}

// MARK: - Stub URL Protocol for Testing
final class StubURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "api.signull.local"
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { 
        request 
    }
    
    override func startLoading() {
        let json = """
        {
            "title": "Stubbed Story",
            "summary": "A stubbed response for testing",
            "fullStory": "This is a stubbed story response that simulates the server behavior.",
            "theme": "void",
            "setting": "An empty space where possibilities exist",
            "openingHook": "You stand at the edge of everything",
            "choices": [
                {
                    "id": "stub1",
                    "text": "Step forward",
                    "hint": "Into the unknown",
                    "consequence": "You enter a new realm of existence"
                }
            ],
            "cliffhanger": "The void responds...",
            "uniqueTags": ["stub", "test"],
            "worldStateRef": "stub-world",
            "npcsRef": "stub-npcs"
        }
        """
        let data = Data(json.utf8)
        let resp = HTTPURLResponse(
            url: request.url!, 
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        
        client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

// MARK: - Concurrency Guard
actor RequestGate {
    private var inFlight = 0
    private let max = 2
    
    func acquire() async {
        while inFlight >= max { 
            try? await Task.sleep(nanoseconds: 50_000_000) 
        }
        inFlight += 1
    }
    
    func release() { 
        inFlight = Swift.max(inFlight - 1, 0) 
    }
}

// MARK: - Story Generation Controller (Prevents Race Conditions)
@MainActor
final class StoryGenController: ObservableObject {
    @Published private(set) var isGenerating = false
    private var currentTask: Task<Void, Never>?
    private let api: LiveAPI
    
    init(api: LiveAPI) {
        self.api = api
    }
    
    func generateBatch() async throws -> [StoryData] {
        guard !isGenerating else { 
            print("⚠️ Generation already in progress - coalescing request")
            return [] // Return empty array to indicate coalescing
        }
        
        isGenerating = true
        currentTask?.cancel()
        
        return try await withTaskCancellationHandler(operation: {
            defer { 
                Task { @MainActor in 
                    self.isGenerating = false 
                } 
            }
            
            // Generate stub first for immediate feedback
            let stub = try await api.generate(tier: .stub, timeoutSec: 30)
            
            // Generate full story
            let full = try await api.generate(tier: .full, timeoutSec: 45)
            
            return [stub, full]
        }, onCancel: {
            Task { @MainActor in 
                self.isGenerating = false 
            }
        })
    }
    
    func cancelGeneration() {
        currentTask?.cancel()
        isGenerating = false
    }
}

// MARK: - SignullAPI (Updated)
class SignullAPI {
    static let shared = SignullAPI()
    private let gate = RequestGate()
    
    // New variety management system
    private let variety = VarietyManager(level: .medium)
    private let bans = TrigramBanList()
    private let simGuard = SimilarityGuard()
    
    // Keep a small ring of recent normalized texts & title tokens
    private var recentBodies: [String] = []
    private var recentTitleTokens: Set<String> = []
    
    // API selection based on configuration
    private lazy var _api: StoryAPI = {
        if SignullConfig.isLiveMode() {
            return LiveAPI(baseURL: SignullConfig.proxyURL)
        } else if SignullConfig.isStubMode() {
            let cfg = URLSessionConfiguration.ephemeral
            cfg.protocolClasses = [StubURLProtocol.self]
            let stubSession = URLSession(configuration: cfg)
            return LiveAPI(baseURL: URL(string: "https://api.signull.local/responses")!, session: stubSession)
        } else {
            return MockAPI()
        }
    }()

    var api: StoryAPI { _api }
    
    // Fallback API for when live API fails
    private var fallbackAPI: StoryAPI {
        return MockAPI()
    }
    
    private init() {}
    
    // MARK: - Public API
    
    static func generateStory(
        prompt: String,
        onPhase: @escaping (String) -> Void,
        onIntensity: @escaping (Double) -> Void
    ) async throws -> StoryData {
        return try await shared.generateWithVariety(
            contextBlock: prompt,
            onPhase: onPhase,
            onIntensity: onIntensity,
            useSimilarityGuard: true
        )
    }

    // Continuation path used by paragraph page – disables similarity guard to avoid reroll loops
    static func generateContinuationStory(
        prompt: String,
        onPhase: @escaping (String) -> Void,
        onIntensity: @escaping (Double) -> Void
    ) async throws -> StoryData {
        return try await shared.generateWithVariety(
            contextBlock: prompt,
            onPhase: onPhase,
            onIntensity: onIntensity,
            useSimilarityGuard: false
        )
    }
    
    // New variety-driven generation method
    func generateWithVariety(
        contextBlock: String,
        onPhase: @escaping (String) -> Void,
        onIntensity: @escaping (Double) -> Void,
        model: String = "gpt-5-mini",
        maxOutputTokens: Int = 2400,
        maxRerolls: Int = 2,
        useSimilarityGuard: Bool = true,
        tfidfSim: ((String,String)->Double)? = nil
    ) async throws -> StoryData {
        var attempts = 0
        while attempts <= maxRerolls {
            attempts += 1
            
            onPhase("generating")
            let baseIntensity = 0.25 + Double(attempts) * 0.25
            onIntensity(min(1.0, baseIntensity))

            // pick variety
            let pick = variety.nextPick()

            // forbidden phrases = user-provided + trigram bans from recent stories
            var forbidden = bans.phrases(limit: 12)
            forbidden.append(contentsOf: ["you take a breath", "you realize that", "in this moment", "suddenly", "all at once"])
            forbidden = Array(Set(forbidden)).prefix(12).map { $0 }

            // build prompts
            let pb = PromptBuilder()
            // If the context explicitly asks for TEXT_ONLY, use the text prompt path
            let useTextOnly = contextBlock.contains("<TEXT_ONLY>")
            let bundle: PromptBundle = useTextOnly ?
                pb.makeText(
                    "",
                    systemPrefix: "You are SIGNULL — an atmospheric, psycho-spiritual story engine. Write in first-person present (I, my). NPCs speak to me with quoted dialogue and names. Keep paragraphs short (2–3 sentences). Make concepts completely original; avoid clichés, virus/salt motifs, and generic fantasy tropes.",
                    contextBlock: contextBlock.replacingOccurrences(of: "<TEXT_ONLY>", with: ""),
                    pick: "\(pick)",
                    forbidden: forbidden.joined(separator: ", "),
                    playerNameToken: "[Samson]",
                    lengthHint: "2–4 paragraphs. End decisively."
                ).build()
            :
                pb.make(
                    "You are SIGNULL — an atmospheric, psycho-spiritual story engine. Write in first-person present (I, my). NPCs speak to me with quoted dialogue and names. Keep paragraphs short (2–3 sentences). Make concepts completely original; avoid clichés, virus/salt motifs, and generic fantasy tropes.",
                    user: contextBlock
                ).build()

            // allow-listed body (prevents the "unsupported parameter" churn)
            let body: [String: Any]
            if useTextOnly {
                body = ParameterSanitizer.requestBodyText(
                    model: model,
                    system: bundle.system,
                    user: bundle.user + "\n\n<EOT>",
                    maxOutputTokens: maxOutputTokens,
                    stop: ["<EOT>"]
                )
            } else {
                body = ParameterSanitizer.requestBody(
                    model: model,
                    system: bundle.system,
                    user: bundle.user,
                    maxOutputTokens: maxOutputTokens,
                    schemaB64: bundle.jsonSchemaBase64
                )
            }

            // perform request with retries and request correlation id
            let scene = try await postSignullWithRetry(body: body)

            // Similarity check against *previous* scenes only
            let normalized = normalizeForSimilarity(scene: scene)
            if useSimilarityGuard && simGuard.isTooSimilar(candidate: normalized, vs: recentBodies, tfidfSim: 0.5) {
                print("🔄 SIMILARITY GUARD: Auto-rerolling (attempt \(attempts)/\(maxRerolls))")
                onPhase("rerolling")
                onIntensity(0.7)
                continue
            }

            // Enforce unique-ish noun in title
            let fixedTitle = TitleUniqueness.ensureUniqueConcreteNoun(title: scene.title, usedTokens: recentTitleTokens)
            var final = scene
            final.title = fixedTitle

            // update guards
            bans.ingest(scene.title)
            bans.ingest(scene.fullStory)
            recentBodies.append(normalized)
            if recentBodies.count > 10 { recentBodies.removeFirst() }
            fixedTitle.split(separator: " ").forEach { recentTitleTokens.insert($0.lowercased()) }
            if recentTitleTokens.count > 100 { recentTitleTokens = Set(recentTitleTokens.prefix(100)) }

            onPhase("complete")
            onIntensity(1.0)
            
            // Optional haptic feedback
            #if canImport(UIKit)
            await UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            #endif
            
            return final
        }

        throw NSError(domain: "SignullAPI", code: -7, userInfo: [NSLocalizedDescriptionKey: "Similarity guard exceeded rerolls"])
    }
    
    private func normalizeForSimilarity(scene: StoryData) -> String {
        // robust, avoids the "1.0" self-compare bug:
        let s = "\(scene.title)\n\(scene.summary)\n\(scene.fullStory)"
        return TrigramBanList.clean(s)
    }
    
    private func getSchemaBase64() -> String {
        let schemaObj = SignullSchemaStore.shared
        let schemaData = try! JSONSerialization.data(withJSONObject: schemaObj)
        return schemaData.base64EncodedString()
    }
    
    private func postSignull(body: [String: Any]) async throws -> StoryData {
        // Backwards-compatible single attempt (kept for internal uses)
        return try await postSignullWithRetry(body: body, maxAttempts: 1)
    }

    private func postSignullWithRetry(body: [String: Any], maxAttempts: Int = 3) async throws -> StoryData {
        let requestId = UUID().uuidString
        var attempt = 0
        var lastError: Error?
        while attempt < maxAttempts {
            attempt += 1
            do {
                let story = try await sendSignullOnce(body: body, requestId: requestId, attempt: attempt)
                if attempt > 1 {
                    Telemetry.shared.capture(event: "signull.retry_success", props: [
                        "request_id": requestId,
                        "attempt": attempt
                    ])
                }
                return story
            } catch {
                lastError = error
                let backoffSeconds = backoffDelay(forAttempt: attempt)
                let retryable = isRetryable(error)
                Telemetry.shared.capture(event: "signull.retry", props: [
                    "request_id": requestId,
                    "attempt": attempt,
                    "retryable": retryable,
                    "backoff_ms": Int(backoffSeconds * 1000)
                ])
                if !retryable || attempt >= maxAttempts {
                    break
                }
                try? await Task.sleep(nanoseconds: UInt64(backoffSeconds * 1_000_000_000))
            }
        }
        Telemetry.shared.capture(event: "signull.fail", props: [
            "request_id": requestId,
            "attempts": attempt,
        ])
        throw lastError ?? LiveAPI.LiveError.badServerResponse
    }

    private func sendSignullOnce(body: [String: Any], requestId: String, attempt: Int) async throws -> StoryData {
        await gate.acquire()
        defer { Task { await gate.release() } }
        
        var req = URLRequest(url: SignullConfig.proxyURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(requestId, forHTTPHeaderField: "x-request-id")
        SignullAuth.apply(to: &req)
        
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let bodyBytes = req.httpBody?.count ?? 0
        let bodyHash = simpleHash64Hex(req.httpBody ?? Data())
        print("➡️ POST \(req.url!.absoluteString) reqId=\(requestId) attempt=\(attempt) body=\(bodyBytes)B hash=\(bodyHash)")
        print("🔧 Using variety-driven request")
        
        let t0 = Date()
        let (data, resp) = try await SignullClient.shared.data(for: req)
        let dt = Date().timeIntervalSince(t0)
        guard let http = resp as? HTTPURLResponse else { 
            throw LiveAPI.LiveError.badServerResponse 
        }
        
        if (200..<300).contains(http.statusCode) { 
            print("✅ HTTP \(http.statusCode) - SUCCESS (\(Int(dt * 1000)) ms, \(data.count) bytes) reqId=\(requestId)")
            let story = try parseStreamResponse(data: data, onPhase: { _ in }, onIntensity: { _ in })
            Telemetry.shared.capture(event: "signull.response", props: [
                "status": http.statusCode,
                "bytes": data.count,
                "ms": Int(dt * 1000),
                "title": story.title,
                "request_id": requestId,
                "attempt": attempt
            ])
            return story
        }
        
        let msg = String(data: data, encoding: .utf8) ?? "<no body>"
        print("🔴 HTTP \(http.statusCode) BODY: \(msg) reqId=\(requestId)")
        Telemetry.shared.capture(event: "signull.error", props: [
            "status": http.statusCode,
            "body": truncate(msg, maxLen: 800),
            "request_id": requestId,
            "attempt": attempt
        ])
        throw LiveAPI.LiveError.badStatus(code: http.statusCode, body: msg)
    }

    private func isRetryable(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            // Network issues are generally retryable
            return [
                .timedOut, .cannotFindHost, .cannotConnectToHost, .networkConnectionLost,
                .dnsLookupFailed, .notConnectedToInternet, .internationalRoamingOff,
                .callIsActive, .dataNotAllowed, .secureConnectionFailed
            ].contains(urlError.code)
        }
        if let e = error as? LiveAPI.LiveError {
            if case .badStatus(let code, _) = e {
                return shouldRetry(statusCode: code)
            }
        }
        return false
    }

    private func shouldRetry(statusCode: Int) -> Bool {
        return [408, 409, 425, 429, 500, 502, 503, 504].contains(statusCode)
    }

    private func backoffDelay(forAttempt attempt: Int) -> Double {
        // Exponential backoff with jitter: 0.4, 0.8, 1.6 (+/- up to 0.2)
        let base = min(pow(2.0, Double(attempt - 1)) * 0.4, 2.5)
        let jitter = Double.random(in: -0.2...0.2)
        return max(0.2, base + jitter)
    }

    private func truncate(_ s: String, maxLen: Int) -> String {
        if s.count <= maxLen { return s }
        let idx = s.index(s.startIndex, offsetBy: maxLen)
        return String(s[..<idx]) + "…"
    }

    private func simpleHash64Hex(_ data: Data) -> String {
        // FNV-1a 64-bit
        var hash: UInt64 = 0xcbf29ce484222325
        let prime: UInt64 = 0x100000001b3
        for byte in data {
            hash ^= UInt64(byte)
            hash &*= prime
        }
        return String(format: "%016llx", hash)
    }
    
    // MARK: - Private Implementation
    

    
    private func parseStreamResponse(
        data: Data, 
        onPhase: @escaping (String) -> Void,
        onIntensity: @escaping (Double) -> Void
    ) throws -> StoryData {
        // Parse regular JSON response (non-streaming)
        onPhase("generating")
        onIntensity(0.5)
        
        do {
            var story = try decodeLastJSONObject(StoryData.self, from: data)
            // If the model omitted fullStory, try to derive it from raw payload
            if story.fullStory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if let derived = deriveFullStory(from: data) {
                    story = StoryData(
                        title: story.title,
                        summary: story.summary,
                        fullStory: derived,
                        theme: story.theme,
                        setting: story.setting,
                        openingHook: story.openingHook,
                        choices: story.choices,
                        cliffhanger: story.cliffhanger,
                        uniqueTags: story.uniqueTags,
                        worldStateRef: story.worldStateRef,
                        npcsRef: story.npcsRef,
                        style: story.style
                    )
                } else {
                    // last resort: stitch from openingHook/summary if present
                    let pieces = [story.openingHook, story.summary].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    let synthesized = pieces.joined(separator: "\n\n")
                    if !synthesized.isEmpty {
                        story = StoryData(
                            title: story.title,
                            summary: story.summary,
                            fullStory: synthesized,
                            theme: story.theme,
                            setting: story.setting,
                            openingHook: story.openingHook,
                            choices: story.choices,
                            cliffhanger: story.cliffhanger,
                            uniqueTags: story.uniqueTags,
                            worldStateRef: story.worldStateRef,
                            npcsRef: story.npcsRef,
                            style: story.style
                        )
                    }
                }
            }
            onPhase("complete")
            onIntensity(1.0)
            return story
        } catch {
            print("🔴 JSON PARSE ERROR: \(error)")
            print("🔴 RESPONSE DATA: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw SignullAPIError.invalidJSON
        }
    }
    
    // MARK: - Helper Methods
    
    private func extractTheme(from prompt: String) -> String {
        if let range = prompt.range(of: "theme:\\s*([^\\n]+)", options: .regularExpression) {
            return String(prompt[range]).replacingOccurrences(of: "theme:", with: "").trimmingCharacters(in: .whitespaces)
        }
        return "mystery"
    }
    
    private func extractSetting(from prompt: String) -> String {
        if let range = prompt.range(of: "setting:\\s*([^\\n]+)", options: .regularExpression) {
            return String(prompt[range]).replacingOccurrences(of: "setting:", with: "").trimmingCharacters(in: .whitespaces)
        }
        return "unknown location"
    }
    
    private func extractOpeningHook(from prompt: String) -> String {
        if let range = prompt.range(of: "openingHook\\s*inspiration:\\s*([^\\n]+)", options: .regularExpression) {
            return String(prompt[range]).replacingOccurrences(of: "openingHook inspiration:", with: "").trimmingCharacters(in: .whitespaces)
        }
        return "Something feels different here..."
    }
    
    private func extractWorldState(from prompt: String) -> String {
        if let range = prompt.range(of: "worldState:\\s*([^\\n]+)", options: .regularExpression) {
            return String(prompt[range]).replacingOccurrences(of: "worldState:", with: "").trimmingCharacters(in: .whitespaces)
        }
        return "season=Eclipse, timeOfDay=Twilight, tension=3"
    }
    
    private func extractTags(from text: String) -> [String] {
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let meaningfulWords = words.filter { word in
            word.count > 3 && !["the", "and", "but", "for", "with", "this", "that", "they", "have", "from"].contains(word)
        }
        
        let uniqueWords = Array(Set(meaningfulWords)).prefix(5)
        return Array(uniqueWords).map { $0.capitalized }
    }
    
    private func decodeLastJSONObject<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        
        // First try to parse as direct JSON (for mock API responses)
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("🔍 DEBUG: Direct JSON parsing failed, trying Responses API format...")
            print("🔍 DEBUG: Direct parse error: \(error)")
        }
        
        // Extract JSON string from Responses API format
        let (text, status) = extractJSONString(data)
        
        var candidate = text
        if candidate == nil || (status == "incomplete") {
            if let t = text, let fixed = salvageObject(t) {
                candidate = fixed
                print("🔍 DEBUG: Salvaged partial JSON content")
            }
        }
        
        guard let jsonString = candidate?.trimmingCharacters(in: .whitespacesAndNewlines),
              let jsonData = jsonString.data(using: .utf8)
        else {
            print("🔴 ERROR: Could not extract valid JSON string from response")
            print("🔴 RAW DATA: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw SignullAPIError.invalidJSON
        }
        
        // Now decode your SignullScene struct from jsonData
        do {
            return try decoder.decode(type, from: jsonData)
        } catch {
            print("🔴 ERROR: Failed to decode JSON: \(error)")
            print("🔴 JSON STRING: \(jsonString)")
            
            // Try to provide more specific error information
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("🔴 MISSING KEY: \(key.stringValue) at path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("🔴 TYPE MISMATCH: Expected \(type) at path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("🔴 VALUE NOT FOUND: Expected \(type) at path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("🔴 DATA CORRUPTED: \(context)")
                @unknown default:
                    print("🔴 UNKNOWN DECODING ERROR")
                }
            }
            
            throw SignullAPIError.invalidJSON
        }
    }
    
    // MARK: - Responses API Wrapper Structures
    
    private struct ResponsesEnvelope: Decodable {
        let status: String
        let output: [OutputItem]?
        
        struct OutputItem: Decodable {
            let type: String
            let content: [ContentPart]?
            
            struct ContentPart: Decodable {
                let type: String
                let text: String?
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func extractJSONString(_ data: Data) -> (jsonText: String?, status: String) {
        // Fast path using typed envelope (for messages with output_text)
        if let env = try? JSONDecoder().decode(ResponsesEnvelope.self, from: data) {
            let status = env.status
            print("🔍 DEBUG: Response status: \(status)")
            if status == "incomplete" { print("⚠️ Response incomplete: unknown reason") }

            let text = env.output?
                .first(where: { $0.type == "message" })?
                .content?
                .compactMap { $0.text }
                .joined()

            if let extractedText = text {
                print("🔍 DEBUG: Extracted text length: \(extractedText.count)")
                if !extractedText.trimmingCharacters(in: .whitespaces).hasPrefix("{") {
                    print("⚠️ Response doesn't look like JSON, attempting to normalize...")
                    if let normalized = normalizeToSchema(extractedText) {
                        return (normalized, status)
                    }
                }
                let jsonBlock = extractLargestJSONBlock(from: extractedText)
                if !jsonBlock.isEmpty { return (jsonBlock, status) }
                return (extractedText, status)
            }

            // Fallback: the response may provide output_json instead of output_text
            if let alt = extractJSONFromOutputJSON(using: data) {
                return (alt, status)
            }
            return (nil, status)
        }

        // Last resort: attempt to read output_json without the typed envelope
        if let alt = extractJSONFromOutputJSON(using: data) {
            return (alt, "unknown")
        }
        return (nil, "decode_error")
    }

    private func extractJSONFromOutputJSON(using data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let output = root["output"] as? [[String: Any]] else { return nil }
        for item in output where (item["type"] as? String) == "message" {
            if let content = item["content"] as? [[String: Any]] {
                if let jsonPart = content.first(where: { ($0["type"] as? String) == "output_json" }),
                   let dict = jsonPart["json"] as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: dict),
                   let s = String(data: data, encoding: .utf8) {
                    return s
                }
                if let textPart = content.first(where: { ($0["type"] as? String) == "output_text" }),
                   let s = textPart["text"] as? String {
                    return s
                }
            }
        }
        return nil
    }

    // Attempt to build a readable full story from raw API data
    private func deriveFullStory(from data: Data) -> String? {
        // Prefer reading the typed envelope and taking assistant message text blocks
        if let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let output = root["output"] as? [[String: Any]],
           let message = output.first(where: { ($0["type"] as? String) == "message" }),
           let content = message["content"] as? [[String: Any]] {
            // Join all output_text fragments
            let texts = content.compactMap { part -> String? in
                guard (part["type"] as? String) == "output_text" else { return nil }
                return part["text"] as? String
            }
            if let joined = texts.filter({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }).joined(separator: "\n\n").nilIfEmpty() {
                // If the text itself is a JSON story, unwrap it; otherwise treat as prose
                if let dict = try? JSONSerialization.jsonObject(with: Data(joined.utf8)) as? [String: Any] {
                    if let fs = dict["fullStory"] as? String, !fs.trimmed().isEmpty { return fs }
                    if let paras = dict["paragraphs"] as? [String], !paras.isEmpty { return paras.joined(separator: "\n\n") }
                    if let scene = dict["scene"] as? String, !scene.trimmed().isEmpty { return scene }
                }
                return joined
            }
        }

        // Regex fallback: scrape any output_text blocks directly from raw string
        if let raw = String(data: data, encoding: .utf8) {
            let texts = extractOutputTextViaRegex(from: raw)
            if let joined = texts.joined(separator: "\n\n").nilIfEmpty() {
                // If joined looks like prose JSON, unwrap first object
                if let jsonStr = extractFirstJSONObjectString(joined),
                   let dictData = jsonStr.data(using: .utf8),
                   let dict = (try? JSONSerialization.jsonObject(with: dictData)) as? [String: Any] {
                    if let fs = dict["fullStory"] as? String, !fs.trimmed().isEmpty { return fs }
                    if let paras = dict["paragraphs"] as? [String], !paras.isEmpty { return paras.joined(separator: "\n\n") }
                    if let scene = dict["scene"] as? String, !scene.trimmed().isEmpty { return scene }
                }
                return joined
            }
            // As last resort, try to carve the first JSON object out of the raw envelope
            if let jsonStr = extractFirstJSONObjectString(raw),
               let dictData = jsonStr.data(using: .utf8),
               let dict = (try? JSONSerialization.jsonObject(with: dictData)) as? [String: Any] {
                if let fs = dict["fullStory"] as? String, !fs.trimmed().isEmpty { return fs }
                if let paras = dict["paragraphs"] as? [String], !paras.isEmpty { return paras.joined(separator: "\n\n") }
                if let scene = dict["scene"] as? String, !scene.trimmed().isEmpty { return scene }
            }
        }

        // Fallback to previously extracted best-effort JSON/text
        let (jsonText, _) = extractJSONString(data)
        if let t = jsonText?.trimmed(), !t.isEmpty {
            if let dict = try? JSONSerialization.jsonObject(with: Data(t.utf8)) as? [String: Any] {
                if let fs = dict["fullStory"] as? String, !fs.trimmed().isEmpty { return fs }
                if let paras = dict["paragraphs"] as? [String], !paras.isEmpty { return paras.joined(separator: "\n\n") }
                if let scene = dict["scene"] as? String, !scene.trimmed().isEmpty { return scene }
                if let content = dict["content"] as? String, !content.trimmed().isEmpty { return content }
            }
            // If the extracted text looks like the entire envelope (many braces), suppress dumping it
            let braceCount = t.filter { $0 == "{" || $0 == "}" }.count
            if braceCount < 6 { return t }
        }
        return nil
    }

    // Find and unescape all output_text -> text strings from the envelope
    private func extractOutputTextViaRegex(from raw: String) -> [String] {
        let pattern = "\\\"type\\\"\\s*:\\s*\\\"output_text\\\"[\\s\\S]*?\\\"text\\\"\\s*:\\s*\\\"(.*?)\\\""
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let range = NSRange(location: 0, length: raw.utf16.count)
        var out: [String] = []
        regex.enumerateMatches(in: raw, options: [], range: range) { match, _, _ in
            guard let m = match, m.numberOfRanges >= 2, let r = Range(m.range(at: 1), in: raw) else { return }
            let escaped = String(raw[r])
            if let unescaped = decodeJSONString(escaped) { out.append(unescaped) }
        }
        return out
    }

    private func decodeJSONString(_ s: String) -> String? {
        // Use JSON decoder to unescape sequences
        let wrapper = "{\"v\":\"\(s)\"}"
        if let data = wrapper.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let v = dict["v"] as? String {
            return v
        }
        return s.replacingOccurrences(of: "\\\\n", with: "\n").replacingOccurrences(of: "\\\\\"", with: "\"")
    }

    // Extract the first balanced JSON object from an arbitrary string
    private func extractFirstJSONObjectString(_ s: String) -> String? {
        var depth = 0
        var inStr = false
        var escape = false
        var startIdx: String.Index? = nil
        var endIdx: String.Index? = nil
        for i in s.indices {
            let ch = s[i]
            if inStr {
                if escape { escape = false; continue }
                if ch == "\\" { escape = true; continue }
                if ch == "\"" { inStr = false }
                continue
            }
            if ch == "\"" { inStr = true; continue }
            if ch == "{" {
                if depth == 0 { startIdx = i }
                depth += 1
            } else if ch == "}" {
                if depth > 0 { depth -= 1 }
                if depth == 0, let s0 = startIdx { endIdx = i; return String(s[s0...endIdx!]) }
            }
        }
        return nil
    }
    
    // If we get truncated JSON, salvage last complete object:
    private func salvageObject(_ s: String) -> String? {
        // fast balance-based cut
        var depth = 0, lastClose = -1
        for (i, ch) in s.enumerated() {
            if ch == "{" { depth += 1 }
            if ch == "}" {
                depth -= 1
                if depth == 0 { lastClose = i }
            }
        }
        if lastClose >= 0 { return String(s.prefix(lastClose + 1)) }
        return nil
    }
    
    private func extractLargestJSONBlock(from text: String) -> String {
        // Find the largest { ... } block
        let pattern = "\\{[^{}]*(?:\\{[^{}]*\\}[^{}]*)*\\}"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, options: [], range: range)
        
        var largestBlock = ""
        for match in matches {
            if let range = Range(match.range, in: text) {
                let block = String(text[range])
                if block.count > largestBlock.count {
                    largestBlock = block
                }
            }
        }
        
        return largestBlock.isEmpty ? text : largestBlock
    }
    
    private func normalizeToSchema(_ text: String) -> String? {
        // Extract meaningful content from plain text
        let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard !lines.isEmpty else { return nil }
        
        // Extract title from first meaningful line
        let title = lines.first?.trimmingCharacters(in: .whitespaces).prefix(80).description ?? "Untitled Scene"
        
        // Extract story content
        let storyLines = lines.dropFirst().filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && !trimmed.hasPrefix("#") && !trimmed.hasPrefix("*")
        }
        let fullStory = storyLines.joined(separator: "\n\n")
        
        // Generate summary from first few sentences
        let sentences = fullStory.components(separatedBy: ". ")
        let summary = sentences.prefix(2).joined(separator: ". ").prefix(240).description
        
        // Extract theme and setting from content
        let theme = extractTheme(from: fullStory)
        let setting = extractSetting(from: fullStory)
        
        // Generate opening hook from first sentence
        let openingHook = sentences.first?.prefix(160).description ?? ""
        
        // Generate choices (placeholder)
        let choices = [
            ["id": "choice1", "text": "Continue forward", "hint": "Proceed with caution", "consequence": "unknown"],
            ["id": "choice2", "text": "Investigate further", "hint": "Look for clues", "consequence": "unknown"],
            ["id": "choice3", "text": "Take a different path", "hint": "Try another approach", "consequence": "unknown"]
        ]
        
        // Generate cliffhanger from last sentence
        let cliffhanger = sentences.last?.prefix(160).description ?? "The situation remains uncertain..."
        
        // Generate tags from content
        let uniqueTags = extractTags(from: fullStory)
        
        // Create JSON structure
        let jsonDict: [String: Any] = [
            "title": title,
            "summary": summary,
            "fullStory": fullStory,
            "theme": theme,
            "setting": setting,
            "openingHook": openingHook,
            "choices": choices,
            "cliffhanger": cliffhanger,
            "uniqueTags": uniqueTags,
            "worldStateRef": "",
            "npcsRef": ""
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("❌ Failed to create normalized JSON: \(error)")
            return nil
        }
    }
    

    
    // MARK: - Health Probe
    func healthCheck() async -> Bool {
        do {
            let data = try await self.api.generate(prompt: "ping", systemPrompt: "You are a test system. Respond with 'pong'.", temperature: 1.0, presencePenalty: 0.0)
            print("✅ HEALTH CHECK: Success (\(data.count) bytes)")
            return true
        } catch let err as LiveAPI.LiveError {
            print("❌ HEALTH CHECK FAILED -> \(err)")
            return false
        } catch {
            print("❌ HEALTH CHECK FAILED -> \(error)")
            return false
        }
    }
    
    // MARK: - Legacy Methods (for compatibility)
    
    func schemaJSON() throws -> [String: Any] {
        return SignullSchemaStore.shared
    }
}

// MARK: - Error Types
enum SignullAPIError: Error, LocalizedError {
    case liveAPIFailed(String)
    case invalidJSON
    case badStatus(Int)
    case unauthorized
    case rateLimited
    case missingSchema
    
    var errorDescription: String? {
        switch self {
        case .liveAPIFailed(let message):
            return "Live API failed: \(message)"
        case .invalidJSON:
            return "Invalid JSON response"
        case .badStatus(let code):
            return "HTTP \(code) error"
        case .unauthorized:
            return "Unauthorized"
        case .rateLimited:
            return "Rate limited"
        case .missingSchema:
            return "Schema not found"
        }
    }
}

// MARK: - Data Models
struct StoryData: Codable {
    var title: String
    let summary: String
    let fullStory: String
    let theme: String
    let setting: String
    let openingHook: String
    let choices: [APIStoryChoice]
    let cliffhanger: String
    let uniqueTags: [String]
    let worldStateRef: String
    let npcsRef: String
    let style: StoryData.StoryStyle
    
    // MARK: - Story Style
    struct StoryStyle: Codable {
        let voice: String
        let sensoryFocus: String
        let narrativeDevice: String
        let weirdness: Int
        let seed: String
        let forbiddenPhrases: [String]
        let microMotif: String
        let palette: [String]
    }
    
    // MARK: - Title Management
    mutating func ensureTitle() {
        let bad = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !bad.isEmpty, !bad.contains("untitled") else {
            title = TitleForge.synth(openingHook: openingHook, theme: theme, setting: setting)
            return
        }
    }
    
    // MARK: - Initializer
    init(
        title: String,
        summary: String,
        fullStory: String,
        theme: String,
        setting: String,
        openingHook: String,
        choices: [APIStoryChoice],
        cliffhanger: String,
        uniqueTags: [String],
        worldStateRef: String,
        npcsRef: String,
        style: StoryData.StoryStyle
    ) {
        self.title = title
        self.summary = summary
        self.fullStory = fullStory
        self.theme = theme
        self.setting = setting
        self.openingHook = openingHook
        self.choices = choices
        self.cliffhanger = cliffhanger
        self.uniqueTags = uniqueTags
        self.worldStateRef = worldStateRef
        self.npcsRef = npcsRef
        self.style = style
    }
    
    // MARK: - Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle missing title by generating one
        if let title = try? container.decode(String.self, forKey: .title) {
            self.title = title
        } else {
            self.title = "Untitled Scene"
        }
        
        // Handle missing summary by generating one
        if let summary = try? container.decode(String.self, forKey: .summary) {
            self.summary = summary
        } else {
            self.summary = ""
        }
        
        // Handle different story content field names
        var fullStoryContent = ""
        if let fullStory = try? container.decode(String.self, forKey: .fullStory) {
            fullStoryContent = fullStory
        } else if let paragraphs = try? container.decode([String].self, forKey: .paragraphs) {
            fullStoryContent = paragraphs.joined(separator: "\n\n")
        } else if let scene = try? container.decode(String.self, forKey: .scene) {
            fullStoryContent = scene
        } else {
            fullStoryContent = ""
        }
        self.fullStory = fullStoryContent
        
        // Handle theme with fallback
        if let theme = try? container.decode(String.self, forKey: .theme) {
            self.theme = theme
        } else {
            // Try to extract theme from content or use default
            let content = fullStoryContent.lowercased()
            if content.contains("wasteland") || content.contains("desert") || content.contains("glass") {
                self.theme = "wasteland"
            } else if content.contains("void") || content.contains("space") {
                self.theme = "void"
            } else if content.contains("corruption") || content.contains("dark") {
                self.theme = "corruption"
            } else {
                self.theme = ""
            }
        }
        
        // Handle setting with fallback
        if let setting = try? container.decode(String.self, forKey: .setting) {
            self.setting = setting
        } else {
            self.setting = "unknown location"
        }
        
        // Handle openingHook with fallback
        if let openingHook = try? container.decode(String.self, forKey: .openingHook) {
            self.openingHook = openingHook
        } else {
            // derive a hook from first 1-2 sentences when missing
            let sentences = fullStoryContent.split(separator: ".").map(String.init)
            let hook = sentences.prefix(2).joined(separator: ". ")
            self.openingHook = hook
        }
        
        // Handle choices with different field names
        var decodedChoices: [APIStoryChoice] = []
        if let choices = try? container.decode([APIStoryChoice].self, forKey: .choices) {
            decodedChoices = choices
        } else if let rawChoices = try? container.decode([RawChoice].self, forKey: .choices) {
            decodedChoices = rawChoices.map { raw in
                APIStoryChoice(
                    id: raw.id ?? UUID().uuidString,
                    text: raw.text,
                    hint: raw.hint ?? "Choose carefully...",
                    consequence: raw.consequence ?? "Unknown consequences await..."
                )
            }
        } else {
            decodedChoices = []
        }
        self.choices = decodedChoices
        
        // Handle cliffhanger
        if let cliffhanger = try? container.decode(String.self, forKey: .cliffhanger) {
            self.cliffhanger = cliffhanger
        } else {
            self.cliffhanger = ""
        }
        
        // Handle tags
        if let uniqueTags = try? container.decode([String].self, forKey: .uniqueTags) {
            self.uniqueTags = uniqueTags
        } else {
            self.uniqueTags = []
        }
        
        // Handle references
        self.worldStateRef = try container.decodeIfPresent(String.self, forKey: .worldStateRef) ?? ""
        self.npcsRef = try container.decodeIfPresent(String.self, forKey: .npcsRef) ?? ""
        
        // Handle missing style with fallback
        if let style = try? container.decode(StoryData.StoryStyle.self, forKey: .style) {
            self.style = style
        } else {
            // Generate a random style pack
            self.style = StoryData.StoryStyle(
                voice: ["lyrical-minimal", "noir-clipped", "mythic-register", "reportage"].randomElement() ?? "lyrical-minimal",
                sensoryFocus: ["tactile", "olfactory", "auditory", "kinesthetic"].randomElement() ?? "tactile",
                narrativeDevice: ["second-person imperative", "found log", "stage directions", "prayer"].randomElement() ?? "second-person imperative",
                weirdness: Int.random(in: 1...5),
                seed: UUID().uuidString,
                forbiddenPhrases: [],
                microMotif: "cracked metronome ticking off-beat",
                palette: ["ozone", "wet copper", "old carpet glue"]
            )
        }
    }
    
    // MARK: - Custom Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(summary, forKey: .summary)
        try container.encode(fullStory, forKey: .fullStory)
        try container.encode(theme, forKey: .theme)
        try container.encode(setting, forKey: .setting)
        try container.encode(openingHook, forKey: .openingHook)
        try container.encode(choices, forKey: .choices)
        try container.encode(cliffhanger, forKey: .cliffhanger)
        try container.encode(uniqueTags, forKey: .uniqueTags)
        try container.encode(worldStateRef, forKey: .worldStateRef)
        try container.encode(npcsRef, forKey: .npcsRef)
        try container.encode(style, forKey: .style)
    }
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case title, summary, fullStory, theme, setting, openingHook, choices, cliffhanger, uniqueTags, worldStateRef, npcsRef, style
        case paragraphs, scene // Additional fields that might be present
    }
}

enum TitleForge {
    static func synth(openingHook: String?, theme: String?, setting: String?) -> String {
        let seeds = [
          "Glass Dunes", "Salt Prophet", "Moonshard Drift", "Veil Lantern",
          "Eclipse Ledger", "Waking Choir", "The Wind That Cuts"
        ]
        let base = seeds.randomElement()!
        if let t = theme, !t.isEmpty { return "\(base): \(t.capitalized)" }
        if let s = setting, !s.isEmpty { return "\(base) of \(s.capitalized)" }
        return base
    }
}

// MARK: - Small string helpers
private extension String {
    func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
    func nilIfEmpty() -> String? { let t = trimmed(); return t.isEmpty ? nil : t }
}

// Helper struct for parsing raw choice data
private struct RawChoice: Codable {
    let id: String?
    let text: String
    let hint: String?
    let consequence: String?
    let option: String? // Alternative field name
    
    // Custom decoding to handle different field names
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.hint = try container.decodeIfPresent(String.self, forKey: .hint)
        self.consequence = try container.decodeIfPresent(String.self, forKey: .consequence)
        
        // Handle different text field names
        if let text = try? container.decode(String.self, forKey: .text) {
            self.text = text
        } else if let option = try? container.decode(String.self, forKey: .option) {
            self.text = option
        } else {
            self.text = "Continue..."
        }
        
        self.option = try container.decodeIfPresent(String.self, forKey: .option)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, text, hint, consequence, option
    }
}

struct APIStoryChoice: Codable {
    let id: String
    let text: String
    let hint: String
    let consequence: String
} 
