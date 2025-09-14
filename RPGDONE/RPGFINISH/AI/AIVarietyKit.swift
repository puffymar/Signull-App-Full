import Foundation
import AVFoundation

// MARK: - Variety Presets / Motifs / Palettes

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

// MARK: - Trigram Ban List

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
        // return top N trigrams deterministically
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

// MARK: - Similarity Guard (Jaccard + optional TF-IDF hook)

struct SimilarityGuard {
    var trigramThreshold: Double = 0.38 // conservative; lower than 0.5 to catch near clones
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

// MARK: - Prompt Builder

struct PromptBundle {
    let system: String
    let user: String
    let jsonSchemaBase64: String
}

enum TitleUniqueness {
    static func ensureUniqueConcreteNoun(title: String, usedTokens: Set<String>) -> String {
        // ensure at least one uncommon noun-ish token not used in recent titles
        let words = title.split(separator: " ").map(String.init)
        let candidates = words.filter { $0.count > 3 && $0.first?.isLetter == true }
        if candidates.contains(where: { !usedTokens.contains($0.lowercased()) }) {
            return title
        }
        // append a random concrete noun token
        let extras = ["anemometer", "sinkstone", "tideglass", "ratchet", "lantern", "turnstile", "valve"]
        return title + " " + extras.randomElement()!
    }
}

final class PromptBuilder {
    // NOTE: Your SignullScene JSON Schema (already in bundle) should be loaded elsewhere.
    // Here we accept the base64-encoded schema string you already compute.
    func make(systemPrefix: String,
              contextBlock: String,
              pick: VarietyPick,
              forbidden: [String],
              jsonSchemaB64: String,
              lengthHint: String = "3–4 paragraphs. End on a sharp cliffhanger.",
              choicesHint: String = "Provide 3–4 consequential choices with hints and concrete consequences."
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
        voice=\(pick.preset.voice) | sensoryFocus=\(pick.preset.sensoryFocus) | narrativeDevice=\(pick.preset.narrativeDevice) | weirdness=\(pick.preset.weirdness) | seed=\(pick.seed)
        microMotif: \(pick.microMotif)
        palette: \(pick.palette.joined(separator: ", "))
        forbiddenPhrases=\(forbidden)

        Length: \(lengthHint)
        \(choicesHint)

        \(contextBlock)
        """
        return .init(system: system, user: user, jsonSchemaBase64: jsonSchemaB64)
    }

    // Text-only variant for paragraph continuation in StoryView
    func makeText(systemPrefix: String,
                  contextBlock: String,
                  pick: VarietyPick,
                  forbidden: [String],
                  playerNameToken: String = "[Samson]",
                  lengthHint: String = "3–4 paragraphs. End decisively.") -> PromptBundle {
        let system = """
        \(systemPrefix)
        You are a text generator. Respond ONLY with story paragraphs.
        Do not include JSON, metadata, code fences, or explanations.
        End your response with the token <EOT>.
        """

        let user = """
        You are SIGNULL — an atmospheric, psycho-spiritual story engine.

        Constraints:
        - Output MUST be plain text paragraphs only (no JSON, no lists).
        - Address the player as \(playerNameToken) when relevant; incorporate their actions directly.
        - Avoid phrases in forbiddenPhrases (rewrite if needed).
        - Keep style consistent with the provided style line.

        Style:
        voice=\(pick.preset.voice) | sensoryFocus=\(pick.preset.sensoryFocus) | narrativeDevice=\(pick.preset.narrativeDevice) | weirdness=\(pick.preset.weirdness) | seed=\(pick.seed)
        microMotif: \(pick.microMotif)
        palette: \(pick.palette.joined(separator: ", "))
        forbiddenPhrases=\(forbidden)

        Length: \(lengthHint)

        \(contextBlock)

        Finish with <EOT>.
        """

        // jsonSchemaBase64 is unused in text mode
        return .init(system: system, user: user, jsonSchemaBase64: "")
    }
}

// MARK: - Parameter allow-list

// Duplicate in SignullAPI; do not redeclare here
// enum ParameterSanitizer { }

// MARK: - Silent Audio (graceful degrade)

// Duplicate in SignullAPI; do not redeclare here
// final class SilentAudio { }
