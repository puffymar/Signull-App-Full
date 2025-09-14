import Foundation

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
}

struct SimilarityGuard {
    init() {}
}

struct PromptBundle {
    var text: String = ""
    var json: String = ""
}

final class PromptBuilder {
    init() {}
    func build() -> PromptBundle { return PromptBundle() }
}
